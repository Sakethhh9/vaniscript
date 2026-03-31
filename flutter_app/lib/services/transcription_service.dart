import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 
// ── Result model ──────────────────────────────────────────────────────────
class TranscriptionResult {
  final String text;
  final String? originalText;
  final String detectedLanguage;
  final String task;
  final double processingTimeS;
  final List<TranscriptionSegment> segments;
  final String? mode;
  final String? note;
 
  const TranscriptionResult({
    required this.text,
    required this.detectedLanguage,
    required this.task,
    required this.processingTimeS,
    required this.segments,
    this.originalText,
    this.mode,
    this.note,
  });
 
  factory TranscriptionResult.fromJson(Map<String, dynamic> j) =>
      TranscriptionResult(
        text:             j['text'] ?? '',
        originalText:     j['original_text'] as String?,
        detectedLanguage: j['detected_language'] ?? 'unknown',
        task:             j['task'] ?? 'transcribe',
        processingTimeS:  (j['processing_time_s'] as num?)?.toDouble() ?? 0.0,
        segments: (j['segments'] as List<dynamic>? ?? [])
            .map((s) => TranscriptionSegment.fromJson(s as Map<String, dynamic>))
            .toList(),
        mode: j['mode'] as String?,
        note: j['note'] as String?,
      );
}
 
class TranscriptionSegment {
  final int id;
  final double start;
  final double end;
  final String text;
 
  const TranscriptionSegment({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
  });
 
  factory TranscriptionSegment.fromJson(Map<String, dynamic> j) =>
      TranscriptionSegment(
        id:    (j['id'] as num).toInt(),
        start: (j['start'] as num).toDouble(),
        end:   (j['end'] as num).toDouble(),
        text:  j['text'] ?? '',
      );
 
  String get timeLabel {
    String fmt(double s) {
      final m   = (s ~/ 60).toString();
      final sec = (s % 60).toStringAsFixed(1).padLeft(4, '0');
      return '$m:$sec';
    }
    return '${fmt(start)} → ${fmt(end)}';
  }
}
 
// ── API client ────────────────────────────────────────────────────────────
class TranscriptionApi {
  static String baseUrl = 'http://localhost:8000';
 
  static Future<Map<String, dynamic>> health() async {
    final res = await http
        .get(Uri.parse('$baseUrl/health'))
        .timeout(const Duration(seconds: 4));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
 
  static Future<TranscriptionResult> transcribe({
    required File file,
    String sourceLanguage = 'auto',
    bool translateToEnglish = false,
    String translateTo = '',
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/transcribe/'));
    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    req.fields['source_language']      = sourceLanguage;
    req.fields['translate_to_english'] = translateToEnglish.toString();
    req.fields['translate_to']         = translateTo;
    return _send(req);
  }
 
  static Future<TranscriptionResult> transcribeBytes({
    required Uint8List bytes,
    required String filename,
    String sourceLanguage = 'auto',
    bool translateToEnglish = false,
    String translateTo = '',
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/transcribe/'));
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    req.fields['source_language']      = sourceLanguage;
    req.fields['translate_to_english'] = translateToEnglish.toString();
    req.fields['translate_to']         = translateTo;
    return _send(req);
  }
 
  static Future<TranscriptionResult> teluguToEnglish(File file) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/transcribe/telugu-to-english'));
    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    return _send(req);
  }
 
  static Future<TranscriptionResult> teluguToEnglishBytes(
      Uint8List bytes, String filename) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/transcribe/telugu-to-english'));
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    return _send(req);
  }
 
  static Future<TranscriptionResult> englishToTelugu(File file) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/transcribe/english-to-telugu'));
    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    return _send(req);
  }
 
  static Future<TranscriptionResult> englishToTeluguBytes(
      Uint8List bytes, String filename) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/transcribe/english-to-telugu'));
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    return _send(req);
  }
 
  static Future<TranscriptionResult> anyToAny({
    required Uint8List bytes,
    required String filename,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/transcribe/any-to-any'));
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    req.fields['source_language'] = sourceLanguage;
    req.fields['target_language'] = targetLanguage;
    return _send(req);
  }
 
  static Future<TranscriptionResult> _send(http.MultipartRequest req) async {
    final streamed = await req.send().timeout(const Duration(minutes: 5));
    final body     = await streamed.stream.bytesToString();
    final json     = jsonDecode(body) as Map<String, dynamic>;
    if (streamed.statusCode != 200) {
      throw Exception(json['detail'] ?? 'Server error ${streamed.statusCode}');
    }
    return TranscriptionResult.fromJson(json);
  }
}
 
// ── Provider ──────────────────────────────────────────────────────────────
enum ApiStatus { connecting, online, loading, offline }
 
class TranscriptionProvider extends ChangeNotifier {
  ApiStatus apiStatus = ApiStatus.connecting;
 
  Future<void> checkHealth() async {
    try {
      final data = await TranscriptionApi.health();
      apiStatus = (data['model_loaded'] == true)
          ? ApiStatus.online
          : ApiStatus.loading;
    } catch (_) {
      apiStatus = ApiStatus.offline;
    }
    notifyListeners();
  }
}