import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/features/messages/model/chat_message_model.dart';
import 'package:vidsell/features/messages/model/conversation_model.dart';
import 'package:vidsell/features/messages/repositories/messaging_repository.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ChatDetailPage extends StatefulWidget {
  final String? conversationId;
  final String userName;
  final String? userAvatar;
  final String? sellerId;
  final String? listingId;
  final String? listingTitle;
  final String? listingImage;
  final String? listingPrice;
  final String? initialMessage;

  const ChatDetailPage({
    super.key,
    this.conversationId,
    this.userName = 'Vidsell',
    this.userAvatar =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200',
    this.sellerId,
    this.listingId,
    this.listingTitle,
    this.listingImage,
    this.listingPrice,
    this.initialMessage,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();

  bool _isSelectionMode = false;
  bool _isMuted = false;
  bool _isBlocked = false;
  bool _isLoading = true;
  bool _isSending = false;
  Object? _loadError;
  String? _conversationId;
  ConversationModel? _conversation;
  final Set<String> _selectedMessageIds = {};
  List<ChatMessageModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    final initialMessage = widget.initialMessage;
    if (initialMessage != null && initialMessage.isNotEmpty) {
      _messageController.text = initialMessage;
    }
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final repository = context.read<MessagingRepository>();
      var conversationId = _conversationId;
      ConversationModel? conversation;
      if (conversationId == null && widget.sellerId?.isNotEmpty == true) {
        conversation = await repository.getOrCreateConversation(
          participantId: widget.sellerId!,
          listingId: widget.listingId,
          participantName: widget.userName,
          participantAvatar: widget.userAvatar,
          listingTitle: widget.listingTitle,
          listingImage: widget.listingImage,
          listingPrice: widget.listingPrice,
        );
        conversationId = conversation.id;
      }
      if (conversationId == null) {
        throw StateError(
          'A conversation ID or seller ID is required to open this chat.',
        );
      }

      final messages = await repository.fetchMessages(conversationId);
      await repository.markConversationRead(conversationId);
      if (!mounted) return;
      setState(() {
        _conversationId = conversationId;
        _conversation = conversation;
        _messages = messages
            .map(
              (message) =>
                  message.isMe ? message : message.copyWith(isRead: true),
            )
            .toList();
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

  void _toggleMessageSelection(String id) {
    setState(() {
      if (_selectedMessageIds.contains(id)) {
        _selectedMessageIds.remove(id);
        if (_selectedMessageIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessageIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedMessageIds.clear();
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final conversationId = _conversationId;
    if (text.isEmpty || conversationId == null || _isSending) return;

    setState(() => _isSending = true);
    try {
      final message = await context.read<MessagingRepository>().sendMessage(
        conversationId,
        text,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(message);
        _messageController.clear();
        _isSending = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _deleteSelectedMessages() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E2638),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.deleteSelectedMessages,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  context.l10n.chatSelectedDeleteCount(
                    _selectedMessageIds.length,
                  ),
                  style: TextStyle(
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
                        _performDeleteMessages();
                      },
                      child: Text(
                        context.l10n.delete,
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

  Future<void> _performDeleteMessages() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    final messageIds = _selectedMessageIds.toList();
    try {
      await context.read<MessagingRepository>().deleteMessages(
        conversationId,
        messageIds,
      );
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((message) => messageIds.contains(message.id));
        _exitSelectionMode();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _copySelectedMessages() {
    final validTexts = _messages
        .where(
          (msg) =>
              _selectedMessageIds.contains(msg.id) &&
              msg.type == MessageType.text &&
              msg.text.trim().isNotEmpty,
        )
        .map((msg) => msg.text)
        .toList();

    if (validTexts.isEmpty) {
      _showCustomSnackBar(context.l10n.chatNoTextToCopy);
      return;
    }

    final copiedText = validTexts.join('\n\n');
    Clipboard.setData(ClipboardData(text: copiedText));

    final count = validTexts.length;
    _showCustomSnackBar(context.l10n.chatCopiedMessageCount(count));
    _exitSelectionMode();
  }

  void _replyToMessage() {
    if (_selectedMessageIds.length != 1) {
      _showCustomSnackBar(context.l10n.chatSelectOneToReply);
      return;
    }

    final selectedId = _selectedMessageIds.first;
    final selectedMessage = _messages.firstWhere((msg) => msg.id == selectedId);

    if (selectedMessage.type == MessageType.deleted) {
      _showCustomSnackBar(context.l10n.chatReplyDeletedMessage);
      return;
    }

    final replyPreviewText = selectedMessage.text.isNotEmpty
        ? selectedMessage.text
        : (selectedMessage.imageUrl != null
              ? context.l10n.chatImagePlaceholder
              : '');

    _messageController.text = '“ $replyPreviewText ”\n';
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );

    _exitSelectionMode();
  }

  void _clearChatHistory() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E2638),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.deleteConversation,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                context.l10n.messagesDeletedPermanently,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
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
                      _clearConversation();
                    },
                    child: Text(
                      context.l10n.delete,
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
      ),
    );
  }

  Future<void> _clearConversation() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    try {
      await context.read<MessagingRepository>().clearMessages(conversationId);
      if (!mounted) return;
      setState(() => _messages.clear());
      _showCustomSnackBar(context.l10n.chatCleared);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(100.w, 80.h, 16.w, 0),
      color: const Color(0xFF1E2838),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      items: [
        PopupMenuItem<String>(
          value: 'block',
          child: Row(
            children: [
              Icon(Icons.person_off_outlined, color: Colors.white, size: 18.sp),
              SizedBox(width: 12.w),
              Text(
                _isBlocked ? context.l10n.unblockUser : context.l10n.blockUser,
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.outlined_flag, color: Colors.white, size: 18.sp),
              SizedBox(width: 12.w),
              Text(
                context.l10n.reportUser,
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'clear',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 18.sp),
              SizedBox(width: 12.w),
              Text(
                context.l10n.conversationDeleted,
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'mute',
          child: Row(
            children: [
              Icon(
                _isMuted
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                color: Colors.white,
                size: 18.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                _isMuted
                    ? context.l10n.enableNotifications
                    : context.l10n.disableNotifications,
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ],
    ).then((selected) {
      if (!context.mounted || selected == null) return;

      switch (selected) {
        case 'block':
          setState(() => _isBlocked = !_isBlocked);
          _showCustomSnackBar(
            _isBlocked ? context.l10n.userBlocked : context.l10n.userUnblocked,
          );
          break;
        case 'report':
          _showCustomSnackBar(context.l10n.userReportSubmitted);
          break;
        case 'clear':
          _clearChatHistory();
          break;
        case 'mute':
          setState(() => _isMuted = !_isMuted);
          _showCustomSnackBar(
            _isMuted
                ? context.l10n.notificationsDisabled
                : context.l10n.notificationsEnabled,
          );
          break;
      }
    });
  }

  void _showCustomSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.only(bottom: 20.h, left: 16.w, right: 16.w),
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2838),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColor.activeColor.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppColor.activeColor,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () {
            if (_isSelectionMode) {
              _exitSelectionMode();
            } else {
              context.goBack();
            }
          },
        ),
        title: _isSelectionMode
            ? Text(
                '${_selectedMessageIds.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: const Color(0xFF263042),
                    backgroundImage: _avatarProvider,
                    child: _avatarProvider == null
                        ? const Icon(Icons.person, color: Colors.white70)
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
        actions: _isSelectionMode
            ? []
            : [
                IconButton(
                  icon: Icon(
                    Icons.phone_outlined,
                    color: Colors.lightBlueAccent,
                    size: 22.sp,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey, size: 22.sp),
                  onPressed: () => _showOptionsMenu(context),
                ),
              ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(color: AppColor.bgElavated, thickness: 1),
            if ((_conversation?.listingId ?? widget.listingId) != null)
              _buildListingContext(),
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
                        onPressed: _loadConversation,
                        child: Text(
                          _loadError.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Text(
                          (_conversation?.listingId ?? widget.listingId) ==
                                      null &&
                                  widget.sellerId == null &&
                                  widget.userName == 'Vidsell'
                              ? context.l10n.noMessages
                              : (_conversation?.listingId ??
                                        widget.listingId) ==
                                    null
                              ? context.l10n.chatMessageSeller
                              : context.l10n.chatMessageSellerAboutListing,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isSelected = _selectedMessageIds.contains(
                          message.id,
                        );

                        return GestureDetector(
                          onLongPress: () {
                            if (message.type != MessageType.deleted) {
                              _toggleMessageSelection(message.id);
                            }
                          },
                          onTap: _isSelectionMode
                              ? () {
                                  if (message.type != MessageType.deleted) {
                                    _toggleMessageSelection(message.id);
                                  }
                                }
                              : null,
                          child: Stack(
                            children: [
                              _buildMessageBubble(message, isSelected),
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  top: 8.h,
                                  child: Container(
                                    width: 24.r,
                                    height: 24.r,
                                    decoration: const BoxDecoration(
                                      color: AppColor.activeColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (_isSelectionMode) _buildSelectionActionBar(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildListingContext() {
    final image = _conversation?.listingImage ?? widget.listingImage;
    final listingTitle =
        _conversation?.listingTitle ?? widget.listingTitle ?? '';
    final listingPrice = _conversation?.listingPrice ?? widget.listingPrice;
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A202A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.bgElavated),
      ),
      child: Row(
        children: [
          if (image != null && image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image(
                image: image.startsWith('http')
                    ? NetworkImage(image)
                    : AssetImage(image) as ImageProvider,
                width: 42.w,
                height: 42.w,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _listingImagePlaceholder(),
              ),
            )
          else
            _listingImagePlaceholder(),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.aboutListing,
                  style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  listingTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          if (listingPrice?.isNotEmpty == true) ...[
            SizedBox(width: 8.w),
            Text(
              listingPrice!,
              style: TextStyle(
                color: AppColor.activeColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  ImageProvider? get _avatarProvider {
    final avatar = widget.userAvatar;
    if (avatar == null || avatar.isEmpty) return null;
    return avatar.startsWith('http')
        ? NetworkImage(avatar)
        : AssetImage(avatar);
  }

  Widget _listingImagePlaceholder() {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: const Color(0xFF263042),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: const Icon(Icons.inventory_2_outlined, color: Colors.white54),
    );
  }

  Widget _buildSelectionActionBar() {
    final bool canReply = _selectedMessageIds.length == 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: const Color(0xFF1E2838),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.content_copy,
            label: context.l10n.copy,
            onTap: _copySelectedMessages,
          ),
          _buildActionButton(
            icon: Icons.reply,
            label: context.l10n.reply,
            onTap: _replyToMessage,
            isDisabled: !canReply,
          ),
          _buildActionButton(
            icon: Icons.delete_outline,
            label: context.l10n.delete,
            onTap: _deleteSelectedMessages,
            isDelete: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDelete = false,
    bool isDisabled = false,
  }) {
    final Color activeThemeColor = isDelete
        ? Colors.redAccent
        : AppColor.activeColor;
    final Color displayColor = isDisabled
        ? Colors.grey.shade600
        : activeThemeColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: displayColor, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: displayColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isSelected) {
    if (message.type == MessageType.deleted) {
      return Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0F587D),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, color: Colors.white70, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                context.l10n.deletedMessage,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                message.time,
                style: TextStyle(color: Colors.white54, fontSize: 10.sp),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.done_all, color: Colors.lightBlueAccent, size: 14.sp),
            ],
          ),
        ),
      );
    }

    if (message.type == MessageType.image) {
      return Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 220.w,
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.activeColor.withValues(alpha: 0.7)
                : (message.isMe
                      ? AppColor.activeColor
                      : const Color(0xFF1E2838)),
            borderRadius: BorderRadius.circular(16.r),
            border: isSelected
                ? Border.all(color: AppColor.activeColor, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Image.network(
                  message.imageUrl!,
                  height: 240.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.time,
                      style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.done_all, color: Colors.white, size: 14.sp),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.activeColor.withValues(alpha: 0.7)
              : (message.isMe ? AppColor.activeColor : const Color(0xFF1E2838)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: message.isMe ? Radius.circular(16.r) : Radius.zero,
            bottomRight: message.isMe ? Radius.zero : Radius.circular(16.r),
          ),
          border: isSelected
              ? Border.all(color: AppColor.activeColor, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                height: 1.3,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                ),
                if (message.isMe) ...[
                  SizedBox(width: 4.w),
                  Icon(Icons.done_all, color: Colors.white, size: 14.sp),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Color(0xFF1E2838),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: 1,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: context.l10n.message,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: const BoxDecoration(
                color: AppColor.activeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
