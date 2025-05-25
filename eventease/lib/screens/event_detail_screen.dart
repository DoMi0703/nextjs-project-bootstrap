import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eventease/widgets/task_item.dart';

class EventDetailScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final DateTime date;
  final String location;

  const EventDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.location,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Animated App Bar with Image
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Event Image
                  CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Event Details
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.date.day}/${widget.date.month}/${widget.date.year}',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideX(),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.location,
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideX(delay: 100.ms),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: AppTheme.primaryColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: 'Tasks'),
                      Tab(text: 'Comments'),
                    ],
                  ).animate().fadeIn().slideY(),

                  const SizedBox(height: 16),

                  // Tab Content
                  SizedBox(
                    height: 400, // Adjust based on content
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tasks Tab
                        _buildTasksTab(),

                        // Comments Tab
                        _buildCommentsTab(),
                      ],
                    ),
                  ).animate().fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
      // Add Task/Comment Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add task/comment dialog based on current tab
          _showAddDialog(_tabController.index == 0);
        },
        backgroundColor: AppTheme.primaryColor,
        child: Icon(
          _tabController.index == 0 ? Icons.add_task : Icons.comment,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTasksTab() {
    return ListView.builder(
      itemCount: 5, // Replace with actual tasks
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return TaskItem(
          title: 'Task ${index + 1}',
          assignee: 'John Doe',
          status: TaskStatus.values[index % 3],
          onStatusChanged: (newStatus) {
            // Update task status
          },
        ).animate().fadeIn().slideX(delay: (index * 100).ms);
      },
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: 10, // Replace with actual comments
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return _CommentItem(
                author: 'User ${index + 1}',
                comment: 'This is a sample comment $index',
                timestamp: DateTime.now().subtract(Duration(minutes: index * 10)),
              ).animate().fadeIn().slideX(delay: (index * 100).ms);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  onChanged: (value) {
                    setState(() {
                      _isTyping = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                transform: Matrix4.translationValues(
                  _isTyping ? 0 : 50,
                  0,
                  0,
                ),
                child: IconButton(
                  onPressed: _isTyping
                      ? () {
                          // Send comment
                          _commentController.clear();
                          setState(() {
                            _isTyping = false;
                          });
                        }
                      : null,
                  icon: Icon(
                    Icons.send_rounded,
                    color: _isTyping ? AppTheme.primaryColor : Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddDialog(bool isTask) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isTask ? 'Add New Task' : 'Add Comment',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: isTask ? 'Task title' : 'Write your comment',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (isTask) ...[
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Assign to',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(isTask ? 'Add Task' : 'Post Comment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final String author;
  final String comment;
  final DateTime timestamp;

  const _CommentItem({
    required this.author,
    required this.comment,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              author[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
