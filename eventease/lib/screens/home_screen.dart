import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/widgets/animated_fab.dart';
import 'package:eventease/widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showFab = _scrollController.position.userScrollDirection == ScrollDirection.forward;
    if (showFab != _showFab) {
      setState(() {
        _showFab = showFab;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'EventEase',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black87),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Events',
                    style: AppTheme.headlineMedium,
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 8),
                  const Text(
                    'Your upcoming events and activities',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn().slideX(delay: 200.ms),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return EventCard(
                    title: 'Team Meeting ${index + 1}',
                    date: DateTime.now().add(Duration(days: index)),
                    imageUrl: 'https://picsum.photos/500/300?random=$index',
                    progress: (index % 100) / 100,
                    onTap: () {
                      // TODO: Navigate to event details
                    },
                  ).animate(delay: (100 * index).ms).fadeIn().slideY(
                    begin: 0.2,
                    curve: Curves.easeOutQuad,
                  );
                },
                childCount: 10,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
      floatingActionButton: AnimatedFab(
        visible: _showFab,
        onPressed: () {
          // TODO: Navigate to create event screen
        },
      ),
    );
  }
}
