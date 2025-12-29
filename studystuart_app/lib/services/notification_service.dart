import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_character.dart';
import 'emotional_feedback_service.dart';
import 'dart:math';

/// 🔔 Notification Service - Smart Learning Notifications
/// 
/// This service manages all types of notifications that StudyStewart sends
/// to keep users engaged, motivated, and informed about their learning progress.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  final List<Function(AppNotification)> _listeners = [];

  /// Add a listener for new notifications
  void addListener(Function(AppNotification) listener) {
    _listeners.add(listener);
  }

  /// Remove a notification listener
  void removeListener(Function(AppNotification) listener) {
    _listeners.remove(listener);
  }

  /// Send a notification
  void sendNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    
    // Notify all listeners
    for (final listener in _listeners) {
      listener(notification);
    }
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }
  }

  /// Get all notifications
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Get unread notifications count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
  }

  /// Generate sample notifications for demonstration
  void generateSampleNotifications() {
    final samples = _getSampleNotifications();
    for (final notification in samples) {
      sendNotification(notification);
    }
  }

  List<AppNotification> _getSampleNotifications() {
    return [
      // Achievement notifications
      AppNotification(
        id: 'achievement_1',
        type: NotificationType.achievement,
        title: 'New Achievement Unlocked! 🏆',
        message: 'You\'ve completed 10 math challenges in a row! You\'re becoming a math master!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        actionData: {'achievement': 'math_master', 'reward': '50_xp'},
      ),
      
      // Streak notifications
      AppNotification(
        id: 'streak_1',
        type: NotificationType.streak,
        title: 'Amazing 7-Day Streak! 🔥',
        message: 'You\'ve been learning consistently for a whole week! Keep up the fantastic work!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actionData: {'streak_days': 7, 'bonus_xp': 100},
      ),
      
      // Level up notifications
      AppNotification(
        id: 'level_1',
        type: NotificationType.levelUp,
        title: 'Level Up! Welcome to Level 5! ⭐',
        message: 'Your dedication has paid off! You\'ve reached Level 5 and unlocked new challenges!',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        actionData: {'new_level': 5, 'unlocked_games': ['advanced_math', 'science_quiz']},
      ),
      
      // Daily reminder notifications
      AppNotification(
        id: 'reminder_1',
        type: NotificationType.dailyReminder,
        title: 'Time for Your Daily Learning! 📚',
        message: 'Your brain is ready for today\'s challenge! Complete just one game to maintain your streak.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        actionData: {'suggested_game': 'math_challenge'},
      ),
      
      // Challenge notifications
      AppNotification(
        id: 'challenge_1',
        type: NotificationType.challenge,
        title: 'Weekly Challenge: Math Marathon! 🏃‍♂️',
        message: 'Complete 25 math problems this week to earn the Math Marathon badge and 200 XP!',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        actionData: {'challenge_id': 'math_marathon', 'progress': 12, 'target': 25},
      ),
      
      // Social notifications
      AppNotification(
        id: 'social_1',
        type: NotificationType.social,
        title: 'You\'re in 3rd Place! 🥉',
        message: 'Pemba Sherpa just passed you on the leaderboard! Time to reclaim your position!',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        actionData: {'leaderboard_position': 3, 'points_behind': 89},
      ),
      
      // Learning tip notifications
      AppNotification(
        id: 'tip_1',
        type: NotificationType.learningTip,
        title: 'Learning Tip: Spaced Repetition 🧠',
        message: 'Did you know? Reviewing material after 1 day, 3 days, and 1 week helps you remember it better!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        actionData: {'tip_category': 'memory_techniques'},
      ),
      
      // Cultural celebration notifications
      AppNotification(
        id: 'cultural_1',
        type: NotificationType.cultural,
        title: 'Happy Dashain! 🎉',
        message: 'Wishing all our Nepali learners a joyful Dashain festival! May this season bring you knowledge and happiness!',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        actionData: {'festival': 'dashain', 'cultural_content': 'available'},
      ),
      
      // System notifications
      AppNotification(
        id: 'system_1',
        type: NotificationType.system,
        title: 'New Features Available! ✨',
        message: 'We\'ve added new diagram games and improved the voice assistant. Check them out!',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        actionData: {'version': '2.1.0', 'new_features': ['diagram_games', 'voice_improvements']},
      ),
    ];
  }
}

/// 📱 App Notification Model
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? actionData;
  final String? imageUrl;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.actionData,
    this.imageUrl,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? actionData,
    String? imageUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionData: actionData ?? this.actionData,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Get the appropriate icon for this notification type
  IconData get icon {
    switch (type) {
      case NotificationType.achievement:
        return Icons.emoji_events_rounded;
      case NotificationType.streak:
        return Icons.local_fire_department_rounded;
      case NotificationType.levelUp:
        return Icons.star_rounded;
      case NotificationType.dailyReminder:
        return Icons.schedule_rounded;
      case NotificationType.challenge:
        return Icons.flag_rounded;
      case NotificationType.social:
        return Icons.people_rounded;
      case NotificationType.learningTip:
        return Icons.lightbulb_rounded;
      case NotificationType.cultural:
        return Icons.celebration_rounded;
      case NotificationType.system:
        return Icons.system_update_rounded;
    }
  }

  /// Get the appropriate color for this notification type
  Color get color {
    switch (type) {
      case NotificationType.achievement:
        return Colors.amber;
      case NotificationType.streak:
        return Colors.orange;
      case NotificationType.levelUp:
        return Colors.purple;
      case NotificationType.dailyReminder:
        return Colors.blue;
      case NotificationType.challenge:
        return Colors.green;
      case NotificationType.social:
        return Colors.pink;
      case NotificationType.learningTip:
        return Colors.teal;
      case NotificationType.cultural:
        return Colors.red;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  /// Get formatted time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

/// 🏷️ Notification Types
enum NotificationType {
  achievement,     // Badges, milestones, accomplishments
  streak,          // Daily streak maintenance and celebrations
  levelUp,         // Level progression and unlocks
  dailyReminder,   // Daily learning reminders
  challenge,       // Weekly/monthly challenges
  social,          // Leaderboard, friend activities
  learningTip,     // Educational tips and study advice
  cultural,        // Cultural celebrations and events
  system,          // App updates, new features
}

/// 🔔 Notification Icon Widget
class NotificationIcon extends StatefulWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final double size;

  const NotificationIcon({
    super.key,
    this.onTap,
    this.iconColor,
    this.size = 24,
  });

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _notificationService.addListener(_onNewNotification);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  void _onNewNotification(AppNotification notification) {
    // Animate when new notification arrives
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNewNotification);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notificationService.unreadCount;
    
    return GestureDetector(
      onTap: () {
        EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_rounded,
                  color: widget.iconColor ?? Colors.white,
                  size: widget.size,
                ),
                
                // Unread count badge
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 📋 Notification List Widget
class NotificationsList extends StatefulWidget {
  const NotificationsList({super.key});

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Generate sample notifications if empty
    if (_notificationService.notifications.isEmpty) {
      _notificationService.generateSampleNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;
    
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We\'ll notify you about achievements,\nstreaks, and learning tips!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationCard(
          notification: notification,
          onTap: () {
            _notificationService.markAsRead(notification.id);
            setState(() {});
          },
        );
      },
    );
  }
}

/// 🎴 Notification Card Widget
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead ? Colors.white : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: notification.isRead ? Colors.grey.shade200 : Colors.blue.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        notification.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Unread indicator
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: notification.color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}