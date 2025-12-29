import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/emotional_feedback_service.dart';
import '../widgets/tts_button.dart';

/// 🔔 Notifications Screen - View All Learning Notifications
/// 
/// This screen displays all notifications including achievements, streaks,
/// reminders, and learning tips in an organized, engaging interface.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() {
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
    setState(() {});
    
    EmotionalFeedbackService.celebrateSuccess(
      context,
      type: 'correct',
      intensity: 1,
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _notificationService.clearAll();
              setState(() {});
              Navigator.pop(context);
              
              EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;
    final unreadCount = _notificationService.unreadCount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Gradient background
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade400,
                  Colors.purple.shade400,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () {
                          EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (unreadCount > 0)
                              Text(
                                '$unreadCount new notifications',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Action buttons
                      if (notifications.isNotEmpty) ...[
                        if (unreadCount > 0)
                          GestureDetector(
                            onTap: _markAllAsRead,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Mark all read',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        
                        const SizedBox(width: 8),
                        
                        GestureDetector(
                          onTap: _clearAllNotifications,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Notifications content
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: notifications.isEmpty
                          ? _buildEmptyState()
                          : _buildNotificationsList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Positioned TTS Button
          const PositionedTTSButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: Colors.blue.shade300,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'We\'ll notify you about:\n• Learning achievements and streaks\n• Daily reminders and challenges\n• Cultural celebrations and tips\n• New features and updates',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () {
                _notificationService.generateSampleNotifications();
                setState(() {});
                EmotionalFeedbackService.celebrateSuccess(
                  context,
                  type: 'correct',
                  intensity: 2,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Generate Sample Notifications'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final notifications = _notificationService.notifications;
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: notifications.length + 1, // +1 for summary card
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSummaryCard();
        }
        
        final notification = notifications[index - 1];
        return NotificationCard(
          notification: notification,
          onTap: () {
            _notificationService.markAsRead(notification.id);
            setState(() {});
            EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
          },
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    final notifications = _notificationService.notifications;
    final unreadCount = _notificationService.unreadCount;
    
    // Count notifications by type
    final typeCounts = <NotificationType, int>{};
    for (final notification in notifications) {
      typeCounts[notification.type] = (typeCounts[notification.type] ?? 0) + 1;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Notification Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total',
                  notifications.length.toString(),
                  Icons.notifications_rounded,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Unread',
                  unreadCount.toString(),
                  Icons.mark_email_unread_rounded,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Achievements',
                  (typeCounts[NotificationType.achievement] ?? 0).toString(),
                  Icons.emoji_events_rounded,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}