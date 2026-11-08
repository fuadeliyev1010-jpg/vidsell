import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/messages/model/notification_item_model.dart';
import 'package:vidsell/features/messages/repositories/messaging_repository.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItemModel> _notifications = [];
  bool _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final notifications = await context
          .read<MessagingRepository>()
          .fetchNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await context.read<MessagingRepository>().markAllNotificationsRead();
      if (!mounted) return;
      setState(() {
        _notifications = _notifications
            .map((item) => item.copyWith(isRead: true))
            .toList();
      });
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _markAsRead(NotificationItemModel item) async {
    if (item.isRead) return;
    try {
      await context.read<MessagingRepository>().markNotificationRead(item.id);
      if (!mounted) return;
      setState(() {
        _notifications = _notifications
            .map(
              (notification) => notification.id == item.id
                  ? notification.copyWith(isRead: true)
                  : notification,
            )
            .toList();
      });
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _removeNotification(String id) async {
    try {
      await context.read<MessagingRepository>().deleteNotification(id);
      if (!mounted) return;
      setState(() {
        _notifications.removeWhere((item) => item.id == id);
      });
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildAppBar(context),
            SizedBox(height: 12.h),
            _buildMarkAllAsReadButton(),
            SizedBox(height: 16.h),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.activeColor,
                      ),
                    )
                  : _loadError != null
                  ? Center(
                      child: TextButton(
                        onPressed: _loadNotifications,
                        child: Text(
                          _loadError.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _notifications.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.noNotifications,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _notifications.length,
                      separatorBuilder: (_, _) => Divider(
                        color: Colors.white.withValues(alpha: 0.05),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return GestureDetector(
                          onTap: () => _markAsRead(item),
                          child: _buildNotificationTile(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 3),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          IconButton(
            onPressed: context.goBack,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          Expanded(
            child: Text(
              context.l10n.notifications,
              textAlign: TextAlign.center,
              style: AppTextStyle.primaryText.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 40.w), // Balance back button spacing
        ],
      ),
    );
  }

  Widget _buildMarkAllAsReadButton() {
    return GestureDetector(
      onTap: _markAllAsRead,
      child: Text(
        context.l10n.markAllRead,
        style: TextStyle(
          color: AppColor.activeColor,
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItemModel item) {
    // Unread background vs read background styling
    final tileColor = item.isRead
        ? Colors.transparent
        : const Color(0xFF131D2A);

    return Container(
      color: tileColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bell Icon Container
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: AppColor.activeColor, width: 1.5),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColor.activeColor,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // Title & Description & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  item.date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),

          // Close / Dismiss Button
          GestureDetector(
            onTap: () => _removeNotification(item.id),
            child: Padding(
              padding: EdgeInsets.only(left: 8.w, top: 2.h),
              child: Icon(
                Icons.close,
                color: Colors.grey.shade500,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
