import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_constants.dart';
import '../services/transcription_service.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // Logo icon
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: kAccentGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(child: Text('🎙️', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.accent, AppColors.teal],
                  ).createShader(bounds),
                  child: Text(
                    'VaniScript',
                    style: AppText.heading(size: 22),
                  ),
                ),
                Text(
                  'SPEECH · TRANSCRIPTION · TRANSLATION',
                  style: AppText.caption(size: 9),
                ),
              ],
            ),
          ),

          // API status badge
          const _ApiStatusBadge(),
        ],
      ),
    );
  }
}

class _ApiStatusBadge extends StatelessWidget {
  const _ApiStatusBadge();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<TranscriptionProvider>().apiStatus;

    final (color, label) = switch (status) {
      ApiStatus.online     => (AppColors.success, 'Model Ready'),
      ApiStatus.loading    => (AppColors.accent,  'Loading Model…'),
      ApiStatus.offline    => (AppColors.error,   'API Offline'),
      ApiStatus.connecting => (AppColors.textMuted,'Connecting…'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(color: color, pulse: status == ApiStatus.online),
          const SizedBox(width: 6),
          Text(label, style: AppText.caption(size: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  final bool pulse;
  const _PulseDot({required this.color, required this.pulse});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 0.4).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) {
      return Container(width: 8, height: 8,
          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle));
    }
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: widget.color.withOpacity(0.6), blurRadius: 8)],
        ),
      ),
    );
  }
}
