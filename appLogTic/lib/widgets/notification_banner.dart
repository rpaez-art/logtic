import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A polished in-app notification banner that slides in from the top.
/// Designed to be shown via ScaffoldMessenger.showSnackBar().
class NotificationBanner extends StatelessWidget {
  final String title;
  final String body;
  final String? route;
  final VoidCallback? onTap;

  const NotificationBanner({
    super.key,
    required this.title,
    this.body = '',
    this.route,
    this.onTap,
  });

  /// Show this banner in the app using ScaffoldMessenger.
  /// Returns the SnackBar so it can be dismissed programmatically if needed.
  static SnackBar show(
    BuildContext context, {
    required String title,
    String body = '',
    String? route,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 5),
  }) {
    final snackBar = SnackBar(
      content: NotificationBanner(
        title: title,
        body: body,
        onTap: onTap,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: EdgeInsets.zero,
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      dismissDirection: DismissDirection.up,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
    return snackBar;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          // Dismiss the snackbar first, then execute callback
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          onTap?.call();
        },
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.corpDarkGray,
                AppColors.corpGreen,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated bell icon ring
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.corpGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.corpGold,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Close button
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.white.withValues(alpha: 0.6),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  splashRadius: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
