import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Battle Challenge!',
        'body': 'Cyber Ninja challenges you to a duel.',
        'time': '2m ago',
        'icon': Icons.bolt,
        'color': AppTheme.accentPurple,
        'isUnread': true,
      },
      {
        'title': 'Level Up!',
        'body': 'You reached Level 5. Keep it up!',
        'time': '2h ago',
        'icon': Icons.arrow_upward,
        'color': AppTheme.primaryCyan,
        'isUnread': true,
      },
      {
        'title': 'New Course Available',
        'body': 'Mastering Flutter Animations is now live.',
        'time': '1d ago',
        'icon': Icons.school,
        'color': Colors.orange,
        'isUnread': false,
      },
      {
        'title': 'Streak Saver Used',
        'body': 'You missed a day, but your streak is safe.',
        'time': '2d ago',
        'icon': Icons.local_fire_department,
        'color': Colors.red,
        'isUnread': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgBlack,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Notifications", style: AppTheme.headlineMedium),
              Text(
                "Mark all read",
                style: TextStyle(color: AppTheme.primaryCyan, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: notifications.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.white.withOpacity(0.05)),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (notif['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          notif['icon'] as IconData,
                          color: notif['color'] as Color,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notif['title'] as String,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: (notif['isUnread'] as bool)
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        notif['body'] as String,
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Text(
                        notif['time'] as String,
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 10,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (index * 50).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}
