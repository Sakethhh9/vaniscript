import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../app_constants.dart';
import '../services/transcription_service.dart';
import '../widgets/shared_widgets.dart';

class TeluguScreen extends StatefulWidget {
  const TeluguScreen({super.key});
  @override
  State<TeluguScreen> createState() => _TeluguScreenState();
}

class _TeluguScreenState extends State<TeluguScreen> {
  PlatformFile? _teFile;
  bool _teLoading = false;
  String? _teError;
  TranscriptionResult? _teResult;

  PlatformFile? _enFile;
  bool _enLoading = false;
  String? _enError;
  TranscriptionResult? _enResult;

  Future<void> _pickTe() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['wav','mp3','ogg','m4a','webm','flac'], withData: true,
    );
    if (r != null) setState(() { _teFile = r.files.first; _teResult = null; _teError = null; });
  }

  Future<void> _submitTe() async {
    if (_teFile?.bytes == null) return;
    setState(() { _teLoading = true; _teError = null; _teResult = null; });
    try {
      final res = await TranscriptionApi.teluguToEnglishBytes(_teFile!.bytes!, _teFile!.name);
      setState(() { _teResult = res; });
    } catch (e) {
      setState(() { _teError = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      setState(() { _teLoading = false; });
    }
  }

  Future<void> _pickEn() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['wav','mp3','ogg','m4a','webm','flac'], withData: true,
    );
    if (r != null) setState(() { _enFile = r.files.first; _enResult = null; _enError = null; });
  }

  Future<void> _submitEn() async {
    if (_enFile?.bytes == null) return;
    setState(() { _enLoading = true; _enError = null; _enResult = null; });
    try {
      final res = await TranscriptionApi.englishToTeluguBytes(_enFile!.bytes!, _enFile!.name);
      setState(() { _enResult = res; });
    } catch (e) {
      setState(() { _enError = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      setState(() { _enLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SectionCard(
          icon: Icons.language_rounded,
          title: 'Telugu to English',
          subtitle: 'Upload Telugu speech - receive English transcription',
          iconBg: AppColors.accent.withOpacity(0.15),
          children: [
            AudioDropZone(onTap: _pickTe, fileName: _teFile?.name, hint: 'Telugu speech audio'),
            if (_teError != null) ErrorBanner(message: _teError!),
            const SizedBox(height: 16),
            SubmitButton(label: 'Transcribe Telugu to English', loading: _teLoading, enabled: _teFile != null, onPressed: _submitTe),
          ],
        ),
        if (_teResult != null) ResultCard(result: _teResult!),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('Switch Direction', style: AppText.caption(size: 11)),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ]),
        ),

        SectionCard(
          icon: Icons.translate_rounded,
          title: 'English to Telugu',
          subtitle: 'Upload English speech - receive Telugu transcription',
          iconBg: AppColors.teal.withOpacity(0.12),
          children: [
            AudioDropZone(onTap: _pickEn, fileName: _enFile?.name, hint: 'English speech audio'),
            if (_enError != null) ErrorBanner(message: _enError!),
            const SizedBox(height: 16),
            SubmitButton(label: 'Transcribe English to Telugu', loading: _enLoading, enabled: _enFile != null, onPressed: _submitEn),
          ],
        ),
        if (_enResult != null) ResultCard(result: _enResult!),
      ],
    );
  }
}
