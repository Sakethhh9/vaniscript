import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../app_constants.dart';
import '../services/transcription_service.dart';
import '../widgets/shared_widgets.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});
  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording  = false;
  bool _hasRecording = false;
  bool _loading      = false;
  int  _seconds      = 0;

  Timer? _timer;
  Timer? _waveTimer;

  String?    _recordedPath;
  Uint8List? _recordedBytes;
  List<Uint8List> _webChunks = [];

  String _selectedLang   = 'auto';
  bool   _translateToEng = false;
  String? _error;
  TranscriptionResult? _result;

  final List<double> _bars = List.filled(28, 0.05);

  @override
  void dispose() {
    _timer?.cancel();
    _waveTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // ── Recording ──────────────────────────────────────────────────────────

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() => _error = 'Microphone permission denied. Please allow microphone in browser settings.');
      return;
    }

    setState(() {
      _isRecording   = true;
      _hasRecording  = false;
      _seconds       = 0;
      _error         = null;
      _result        = null;
      _recordedPath  = null;
      _recordedBytes = null;
      _webChunks     = [];
    });

    if (kIsWeb) {
      // Web: use stream to collect audio chunks
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.opus,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      stream.listen((chunk) {
        _webChunks.add(Uint8List.fromList(chunk));
      });
    } else {
      // Desktop/Mobile: record to WAV file
      final dir  = await getTemporaryDirectory();
      final path = '${dir.path}/vaniscript_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      _recordedPath = path;
    }

    // Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });

    // Waveform animation
    _waveTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _bars.length; i++) {
          final t = DateTime.now().millisecondsSinceEpoch / 250.0;
          final phase = t + i * 0.45;
          // Simple pseudo-sine via polynomial
          double x = phase % 6.2832;
          if (x > 3.1416) x = x - 6.2832;
          final s = x - (x * x * x) / 6.0;
          _bars[i] = (0.15 + 0.75 * ((s + 1.0) / 2.0)).clamp(0.05, 1.0);
        }
      });
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _waveTimer?.cancel();
    for (int i = 0; i < _bars.length; i++) { _bars[i] = 0.05; }

    if (kIsWeb) {
      await _recorder.stop();
      if (_webChunks.isNotEmpty) {
        final total    = _webChunks.fold<int>(0, (s, c) => s + c.length);
        final combined = Uint8List(total);
        int offset = 0;
        for (final c in _webChunks) {
          combined.setAll(offset, c);
          offset += c.length;
        }
        _recordedBytes = combined;
      }
      _webChunks = [];
    } else {
      final path = await _recorder.stop();
      if (path != null && path.isNotEmpty) {
        _recordedPath = path;
      }
    }

    final captured = kIsWeb
        ? (_recordedBytes != null && _recordedBytes!.isNotEmpty)
        : (_recordedPath  != null && _recordedPath!.isNotEmpty);

    setState(() {
      _isRecording  = false;
      _hasRecording = captured;
      if (!captured) _error = 'No audio captured — please try again.';
    });
  }

  // ── Transcription ──────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      TranscriptionResult res;

      if (kIsWeb) {
        if (_recordedBytes == null || _recordedBytes!.isEmpty) {
          throw Exception('No recording found. Please record audio first.');
        }
        res = await TranscriptionApi.transcribeBytes(
          bytes:              _recordedBytes!,
          filename:           'recording.webm',
          sourceLanguage:     _selectedLang,
          translateToEnglish: _translateToEng,
        );
      } else {
        if (_recordedPath == null || _recordedPath!.isEmpty) {
          throw Exception('No recording found. Please record audio first.');
        }
        res = await TranscriptionApi.transcribe(
          file:               File(_recordedPath!),
          sourceLanguage:     _selectedLang,
          translateToEnglish: _translateToEng,
        );
      }

      setState(() { _result = res; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _reRecord() {
    setState(() {
      _hasRecording  = false;
      _recordedBytes = null;
      _recordedPath  = null;
      _seconds       = 0;
      _result        = null;
      _error         = null;
      _webChunks     = [];
    });
  }

  String get _timerLabel {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SectionCard(
          emoji: '🎤',
          title: 'Record from Microphone',
          subtitle: 'Record live audio, then tap Transcribe',
          iconBg: AppColors.pink.withOpacity(0.15),
          children: [

            // Language
            Text('SOURCE LANGUAGE', style: AppText.caption()),
            const SizedBox(height: 6),
            LanguageDropdown(
              value: _selectedLang,
              languages: AppLanguages.all,
              onChanged: (v) => setState(() => _selectedLang = v ?? 'auto'),
            ),
            const SizedBox(height: 12),
            TranslateToggle(
              value: _translateToEng,
              onChanged: (v) => setState(() => _translateToEng = v),
            ),
            const SizedBox(height: 24),

            // Waveform while recording
            if (_isRecording) ...[
              _buildWaveform(),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _timerLabel,
                  style: AppText.heading(size: 40, color: AppColors.pink),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Mic button
            Center(
              child: MicButton(isRecording: _isRecording, onTap: _toggleRecording),
            ),
            const SizedBox(height: 12),

            // Status
            Center(
              child: Text(
                _isRecording
                    ? 'Recording…  tap ⏹ to stop'
                    : _hasRecording
                        ? '✅  Recording ready!'
                        : 'Tap 🎤 to start recording',
                style: AppText.label(
                  size: 13,
                  color: _isRecording
                      ? AppColors.pink
                      : _hasRecording ? AppColors.success : AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Recording info card
            if (_hasRecording && !_isRecording)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Text('🎵', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Audio captured  •  $_timerLabel',
                            style: AppText.label(size: 13, color: AppColors.success)),
                        const SizedBox(height: 2),
                        Text('Tap "Transcribe" button below to process',
                            style: AppText.caption(size: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _reRecord,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text('Re-record', style: AppText.caption(size: 11)),
                    ),
                  ),
                ]),
              ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 8),
              ErrorBanner(message: _error!),
            ],

            const SizedBox(height: 16),

            // Submit
            SubmitButton(
              label: '✨  Transcribe Recording',
              loading: _loading,
              enabled: _hasRecording && !_isRecording,
              onPressed: _submit,
            ),
          ],
        ),

        if (_result != null) ResultCard(result: _result!),
      ],
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_bars.length, (i) => Container(
          width: 4,
          height: 4 + _bars[i] * 40,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: AppColors.pink.withOpacity(0.5 + _bars[i] * 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        )),
      ),
    );
  }
}
