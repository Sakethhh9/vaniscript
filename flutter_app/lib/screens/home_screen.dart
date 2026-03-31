import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_constants.dart';
import '../services/transcription_service.dart';
import '../widgets/app_header.dart';
import 'upload_screen.dart';
import 'live_screen.dart';
import 'telugu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _healthTimer;

  final _tabs = const [
    Tab(icon: Icon(Icons.upload_file_rounded), text: 'File Upload'),
    Tab(icon: Icon(Icons.bolt_rounded),        text: 'Live Speech'),
    Tab(icon: Icon(Icons.translate_rounded),   text: 'Telugu English'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final provider = context.read<TranscriptionProvider>();
    provider.checkHealth();
    _healthTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => provider.checkHealth(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _healthTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  UploadScreen(),
                  LiveScreen(),
                  TeluguScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0x26E8C547), Color(0x1438D9C0)],
          ),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelStyle: AppText.heading(size: 11),
        unselectedLabelStyle: AppText.caption(size: 11),
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textMuted,
        tabs: _tabs,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
      ),
    );
  }
}
