import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/messages/model/message_item_model.dart';
import 'package:vidsell/features/messages/model/conversation_model.dart';
import 'package:vidsell/features/messages/pages/chat_detail_page.dart';
import 'package:vidsell/features/messages/pages/notification_page.dart';
import 'package:vidsell/features/messages/repositories/messaging_repository.dart';
import 'package:vidsell/features/messages/widgets/message_tile.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  int _selectedFilterIndex = 0;
  int _selectedSortIndex = 0;

  bool _isSelectionMode = false;
  final Set<String> _selectedItemIds = {};
  bool _isLoading = false;
  Object? _loadError;
  List<ConversationModel> _conversations = [];

  List<String> get _filterOptions => [
    context.l10n.messageFilterAll,
    context.l10n.messageFilterSales,
    context.l10n.messageFilterPurchases,
    context.l10n.messageFilterBlocked,
  ];

  List<String> get _sortOptions => [
    context.l10n.messageSortByDate,
    context.l10n.messageSortUnread,
  ];

  List<MessageItemModel> get _messages => _conversations
      .map((conversation) {
        final date = conversation.updatedAt?.toLocal();
        final formattedDate = date == null
            ? ''
            : '${date.day.toString().padLeft(2, '0')}.'
                  '${date.month.toString().padLeft(2, '0')}.'
                  '${date.year}';
        return MessageItemModel(
          id: conversation.id,
          title: conversation.listingTitle?.isNotEmpty == true
              ? conversation.listingTitle!
              : conversation.participantName,
          sender: conversation.participantName,
          lastMessage: conversation.lastMessage,
          date: formattedDate,
          avatarUrl: conversation.participantAvatar ?? '',
          isOnline: false,
          unreadCount: conversation.unreadCount,
        );
      })
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final conversations = await context
          .read<MessagingRepository>()
          .fetchConversations();
      if (!mounted) return;
      setState(() {
        _conversations = conversations;
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

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
        if (_selectedItemIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItemIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItemIds.clear();
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E2638),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.deleteConversation,
                  style: AppTextStyle.primaryText.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  context.l10n.messagesDeletedPermanently,
                  style: AppTextStyle.primaryText.copyWith(
                    fontSize: 13.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        context.l10n.cancel,
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _performDeleteAction();
                      },
                      child: Text(
                        context.l10n.conversationDeleted,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performDeleteAction() async {
    final repository = context.read<MessagingRepository>();
    final selectedIds = _selectedItemIds.toList();
    setState(() {
      _isLoading = true;
    });

    try {
      await repository.deleteConversations(selectedIds);
      final conversations = await repository.fetchConversations();
      if (!mounted) return;
      setState(() {
        _conversations = conversations;
        _isLoading = false;
        _exitSelectionMode();
      });
    } catch (error) {
      if (!mounted) return;
      var displayedError = error;
      try {
        final conversations = await repository.fetchConversations();
        if (!mounted) return;
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      } catch (refreshError) {
        if (!mounted) return;
        displayedError = StateError(
          '$error. Refreshing conversations also failed: $refreshError',
        );
        setState(() {
          _loadError = refreshError;
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(displayedError.toString())));
    }
  }

  void _showFilterModal() {
    final options = _filterOptions;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFF161E2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.messages,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade400,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...options.asMap().entries.map((entry) {
                    final option = entry.value;
                    final isSelected = _selectedFilterIndex == entry.key;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilterIndex = entry.key);
                        setModalState(() {});
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2838),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColor.activeColor
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              width: 20.r,
                              height: 20.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColor.activeColor
                                      : Colors.grey.shade600,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 8.r,
                                        height: 8.r,
                                        decoration: const BoxDecoration(
                                          color: AppColor.activeColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortModal() {
    final options = _sortOptions;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFF161E2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.messages,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade400,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...options.asMap().entries.map((entry) {
                    final option = entry.value;
                    final isSelected = _selectedSortIndex == entry.key;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedSortIndex = entry.key);
                        setModalState(() {});
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2838),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColor.activeColor
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              width: 20.r,
                              height: 20.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColor.activeColor
                                      : Colors.grey.shade600,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 8.r,
                                        height: 8.r,
                                        decoration: const BoxDecoration(
                                          color: AppColor.activeColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 16.h),

                _isSelectionMode
                    ? _buildSelectionHeader()
                    : _buildNormalHeader(),

                14.height,
                const Divider(color: AppColor.bgSurfaceColor, thickness: 1.0),
                14.height,

                // Filter & Sort Trigger Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      _buildFilterButton(
                        label: _filterOptions[_selectedFilterIndex],
                        onTap: _showFilterModal,
                      ),
                      SizedBox(width: 12.w),
                      _buildFilterButton(
                        label: _sortOptions[_selectedSortIndex],
                        onTap: _showSortModal,
                      ),
                    ],
                  ),
                ),
                24.height,

                // Messages List
                Expanded(
                  child: _loadError != null
                      ? Center(
                          child: TextButton(
                            onPressed: _loadConversations,
                            child: Text(
                              _loadError.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _messages.isEmpty && !_isLoading
                      ? Center(
                          child: Text(
                            context.l10n.noMessages,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13.sp,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _messages.length,
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final item = _messages[index];
                            final isSelected = _selectedItemIds.contains(
                              item.id,
                            );

                            return InkWell(
                              borderRadius: BorderRadius.circular(8.r),
                              onLongPress: () => _toggleSelection(item.id),
                              onTap: () async {
                                if (_isSelectionMode) {
                                  _toggleSelection(item.id);
                                } else {
                                  await context.goTo<void>(
                                    ChatDetailPage(
                                      conversationId: item.id,
                                      userName: item.sender,
                                      userAvatar: item.avatarUrl,
                                      listingId:
                                          _conversations[index].listingId,
                                      listingTitle:
                                          _conversations[index].listingTitle,
                                      listingImage:
                                          _conversations[index].listingImage,
                                      listingPrice:
                                          _conversations[index].listingPrice,
                                    ),
                                  );
                                  if (mounted) _loadConversations();
                                }
                              },
                              child: MessageTile(
                                item: item,
                                isSelected: isSelected,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Loading Overlay matching the screenshot style
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2638),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 26.w,
                        height: 26.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.lightBlueAccent,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        context.l10n.pleaseWait,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 3),
    );
  }

  Widget _buildNormalHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          100.width,
          Text(
            context.l10n.messages,
            style: AppTextStyle.primaryText.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              context.goTo(const NotificationsPage());
            },
            child: Text(
              context.l10n.notifications,
              style: AppTextStyle.primaryText.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.activeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
            onPressed: _exitSelectionMode,
          ),
          Text(
            '${_selectedItemIds.length}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: _selectedItemIds.isNotEmpty
                ? _showDeleteConfirmationDialog
                : null,
            child: Text(
              context.l10n.delete,
              style: TextStyle(
                color: AppColor.activeColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColor.bgInfoColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColor.activeColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColor.activeColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColor.activeColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
