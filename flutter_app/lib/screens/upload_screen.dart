import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../app_constants.dart';
import '../services/transcription_service.dart';
import '../widgets/shared_widgets.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PlatformFile? _file;
  String _selectedLang = 'auto';
  bool   _loading      = false;
  String? _error;
  TranscriptionResult? _result;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav','mp3','ogg','m4a','webm','flac','aac'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() { _file = result.files.first; _result = null; _error = null; });
    }
  }

  Future<void> _submit() async {
    if (_file == null || _file!.bytes == null) return;
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final res = await TranscriptionApi.transcribeBytes(
        bytes: _file!.bytes!, filename: _file!.name, sourceLanguage: _selectedLang,
      );
      setState(() { _result = res; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SectionCard(
          icon: Icons.upload_file_rounded,
          title: 'Upload Audio File',
          subtitle: 'WAV  MP3  OGG  M4A  WEBM up to 100 MB',
          iconBg: AppColors.accent.withOpacity(0.15),
          children: [
            Text('SOURCE LANGUAGE', style: AppText.caption()),
            const SizedBox(height: 6),
            LanguageDropdown(
              value: _selectedLang,
              languages: AppLanguages.all,
              onChanged: (v) => setState(() => _selectedLang = v ?? 'auto'),
            ),
            const SizedBox(height: 16),
            AudioDropZone(onTap: _pickFile, fileName: _file?.name, hint: 'WAV  MP3  OGG  M4A  WEBM'),
            if (_error != null) ErrorBanner(message: _error!),
            const SizedBox(height: 16),
            SubmitButton(label: 'Transcribe', loading: _loading, enabled: _file != null, onPressed: _submit),
          ],
        ),
        if (_result != null) ResultCard(result: _result!),
      ],
    );
  }
}
