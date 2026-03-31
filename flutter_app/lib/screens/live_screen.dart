import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../app_constants.dart';
import '../widgets/shared_widgets.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});
  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final SpeechToText _speech = SpeechToText();

  bool _available   = false;
  bool _isListening = false;
  String _fullText  = '';
  String _interim   = '';
  String _selectedBcp = 'te-IN';
  String? _error;

  final _languages = const [
    {'code': 'te-IN', 'name': 'Telugu'},
    {'code': 'en-US', 'name': 'English US'},
    {'code': 'en-GB', 'name': 'English UK'},
    {'code': 'hi-IN', 'name': 'Hindi'},
    {'code': 'ta-IN', 'name': 'Tamil'},
    {'code': 'kn-IN', 'name': 'Kannada'},
    {'code': 'ml-IN', 'name': 'Malayalam'},
    {'code': 'mr-IN', 'name': 'Marathi'},
    {'code': 'bn-IN', 'name': 'Bengali'},
    {'code': 'gu-IN', 'name': 'Gujarati'},
    {'code': 'pa-IN', 'name': 'Punjabi'},
    {'code': 'or-IN', 'name': 'Odia'},
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _available = await _speech.initialize(
      onError: (e) => setState(() => _error = e.errorMsg),
    );
    setState(() {});
  }

  Future<void> _toggle() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      if (!_available) {
        setState(() => _error = 'Speech recognition not available. Use Chrome browser.');
        return;
      }
      setState(() { _isListening = true; _error = null; });
      await _speech.listen(
        localeId: _selectedBcp,
        onResult: (result) {
          setState(() {
            if (result.finalResult) {
              _fullText += result.recognizedWords + ' ';
              _interim = '';
            } else {
              _interim = result.recognizedWords;
            }
          });
        },
        listenFor: const Duration(minutes: 10),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: false,
      );
    }
  }

  void _clear() => setState(() { _fullText = ''; _interim = ''; });

  @override
  Widget build(BuildContext context) {
    final displayText = _fullText + _interim;
    final isEmpty = displayText.trim().isEmpty;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SectionCard(
          icon: Icons.bolt_rounded,
          title: 'Live Speech Transcription',
          subtitle: 'Real-time on-device recognition - no upload needed',
          iconBg: AppColors.teal.withOpacity(0.12),
          children: [
            const InfoNote(
              message: 'Uses the device built-in speech recognition engine. Works best in Chrome.',
            ),
            Text('SPEAK IN', style: AppText.caption()),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBcp,
                  dropdownColor: AppColors.surface2,
                  style: AppText.label(size: 13),
                  iconEnabledColor: AppColors.textMuted,
                  isExpanded: true,
                  onChanged: (v) => setState(() => _selectedBcp = v ?? 'te-IN'),
                  items: _languages.map((l) => DropdownMenuItem(
                    value: l['code'],
                    child: Text(l['name']!),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(child: MicButton(isRecording: _isListening, onTap: _toggle)),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _isListening ? 'Listening - tap to stop' : 'Tap to start',
                style: AppText.label(size: 13,
                    color: _isListening ? AppColors.pink : AppColors.textMuted),
              ),
            ),
            if (_error != null) ErrorBanner(message: _error!),
            const Divider(color: AppColors.border, height: 32),
            Text('LIVE TRANSCRIPT', style: AppText.caption()),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isListening ? AppColors.teal.withOpacity(0.3) : AppColors.border,
                ),
              ),
              child: SelectableText(
                isEmpty ? 'Start speaking to see text here' : displayText,
                style: isEmpty
                    ? AppText.label(size: 14, color: AppColors.textMuted)
                        .copyWith(fontStyle: FontStyle.italic)
                    : AppText.label(size: 15),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              GestureDetector(
                onTap: () {
                  if (!isEmpty) {
                    Clipboard.setData(ClipboardData(text: displayText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied!'), duration: Duration(seconds: 2)),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.copy_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text('Copy', style: AppText.caption(size: 12)),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _clear,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text('Clear', style: AppText.caption(size: 12)),
                  ]),
                ),
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
