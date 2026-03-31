import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_constants.dart';
import '../services/transcription_service.dart';

class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppColors.textPrimary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppText.heading(size: 14)),
                Text(subtitle, style: AppText.caption(size: 11)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class AudioDropZone extends StatelessWidget {
  final String? fileName;
  final VoidCallback onTap;
  final String hint;

  const AudioDropZone({
    super.key,
    required this.onTap,
    this.fileName,
    this.hint = 'Tap to browse audio file',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: fileName != null ? AppColors.accent.withOpacity(0.04) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: fileName != null ? AppColors.accent.withOpacity(0.4) : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(children: [
          Icon(
            fileName != null ? Icons.audio_file_rounded : Icons.folder_open_rounded,
            size: 48,
            color: fileName != null ? AppColors.accent : AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          if (fileName != null) ...[
            Text(fileName!, style: AppText.label(color: AppColors.accent), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Tap to change', style: AppText.caption()),
          ] else ...[
            Text('Drop or tap to select', style: AppText.label()),
            const SizedBox(height: 4),
            Text(hint, style: AppText.caption()),
          ],
        ]),
      ),
    );
  }
}

class LanguageDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final List<Map<String, String>> languages;

  const LanguageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.languages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.surface2,
          style: AppText.label(size: 13),
          iconEnabledColor: AppColors.textMuted,
          isExpanded: true,
          onChanged: onChanged,
          items: languages.map((lang) => DropdownMenuItem(
            value: lang['code'],
            child: Text(lang['name']!),
          )).toList(),
        ),
      ),
    );
  }
}

class TranslateToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const TranslateToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          Text('Translate to English',
              style: AppText.label(size: 13,
                  color: value ? AppColors.accent : AppColors.textMuted)),
        ]),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  const SubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: (enabled && !loading) ? kAccentGradient : null,
          color: (enabled && !loading) ? null : AppColors.border,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton(
          onPressed: (enabled && !loading) ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                      color: Color(0xFF0A0C10), strokeWidth: 2.5))
              : Text(label,
                  style: AppText.heading(size: 14, color: const Color(0xFF0A0C10))),
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
            style: AppText.label(size: 13, color: AppColors.error))),
      ]),
    );
  }
}

class InfoNote extends StatelessWidget {
  final String message;
  const InfoNote({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.teal.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded, color: AppColors.teal, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
            style: AppText.label(size: 12, color: AppColors.textMuted))),
      ]),
    );
  }
}

class ResultCard extends StatefulWidget {
  final TranscriptionResult result;
  const ResultCard({super.key, required this.result});

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  bool _showSegments = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final isNonLatin = ['te','hi','ta','kn','ml','mr','bn','gu','pa','ur','or','as']
        .contains(r.detectedLanguage);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 8, runSpacing: 6, children: [
            _chip(r.detectedLanguage.toUpperCase(), AppColors.teal),
            _chip('${r.processingTimeS}s', AppColors.accent),
            _chip(r.task == 'translate' ? 'Translated' : 'Transcribed', AppColors.pink),
            if (r.mode != null) _chip(r.mode!, AppColors.success),
          ]),
          const SizedBox(height: 14),

          if (r.originalText != null && r.originalText!.isNotEmpty) ...[
            Text('ORIGINAL (ENGLISH)', style: AppText.caption()),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                r.originalText!,
                style: AppText.label(size: 14, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 14),
            Text('TRANSLATED', style: AppText.caption()),
            const SizedBox(height: 6),
          ] else ...[
            Text('RESULT', style: AppText.caption()),
            const SizedBox(height: 6),
          ],

          SelectableText(
            r.text.isEmpty ? 'No speech detected.' : r.text,
            style: isNonLatin
                ? AppText.telugu()
                : AppText.label(size: 15, color: AppColors.textPrimary),
          ),

          if (r.segments.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _showSegments = !_showSegments),
              child: Row(children: [
                Icon(_showSegments
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_right_rounded,
                    color: AppColors.textMuted, size: 18),
                Text(
                  _showSegments ? 'Hide segments' : 'Show ${r.segments.length} segments',
                  style: AppText.caption(size: 12),
                ),
              ]),
            ),
            if (_showSegments) ...[
              const SizedBox(height: 8),
              ...r.segments.map((s) => _SegmentRow(segment: s)),
            ],
          ],

          const SizedBox(height: 14),
          Row(children: [
            _actionBtn(Icons.copy_rounded, 'Copy', () {
              Clipboard.setData(ClipboardData(text: r.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 2)),
              );
            }),
          ]),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Text(label, style: AppText.caption(size: 11, color: color)),
  );

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(label, style: AppText.caption(size: 12)),
          ]),
        ),
      );
}

class _SegmentRow extends StatelessWidget {
  final TranscriptionSegment segment;
  const _SegmentRow({required this.segment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 90,
          child: Text(segment.timeLabel, style: AppText.caption(size: 10)),
        ),
        Expanded(child: Text(segment.text, style: AppText.label(size: 13))),
      ]),
    );
  }
}

class MicButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;
  const MicButton({super.key, required this.isRecording, required this.onTap});

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.25)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: widget.isRecording
          ? AnimatedBuilder(
              animation: _scale,
              builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
              child: _circle(),
            )
          : _circle(),
    );
  }

  Widget _circle() => Container(
    width: 88, height: 88,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: widget.isRecording
          ? const LinearGradient(colors: [Color(0x40E85D8A), Color(0x26F0A500)])
          : const LinearGradient(colors: [Color(0x33E8C547), Color(0x1A38D9C0)]),
      border: Border.all(
        color: widget.isRecording ? AppColors.pink : AppColors.accent.withOpacity(0.4),
        width: 2,
      ),
      boxShadow: widget.isRecording
          ? [BoxShadow(color: AppColors.pink.withOpacity(0.4), blurRadius: 24)]
          : [],
    ),
    child: Center(
      child: Icon(
        widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
        color: widget.isRecording ? AppColors.pink : AppColors.accent,
        size: 36,
      ),
    ),
  );
}
