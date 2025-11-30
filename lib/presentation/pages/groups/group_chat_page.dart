import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../../provider/group_provider.dart';
import '../../../provider/auth_provider.dart';

class GroupChatArgs {
  final GroupModel group;

  GroupChatArgs({required this.group});
}

class GroupChatPage extends StatefulWidget {
  final GroupModel group;

  const GroupChatPage({super.key, required this.group});

  static const String routeName = '/group-chat';

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// ✅ Correct membership check
  bool _userIsMember(GroupProvider provider, String userId) {
    final selectedGroup = provider.selectedGroup ?? widget.group;
    return userId.isNotEmpty && selectedGroup.isMember(userId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.loadGroupDetails(widget.group.id);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userModel?.id ?? '';

    if (!_userIsMember(groupProvider, currentUserId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Join the group to send messages.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await groupProvider.sendMessage(widget.group.id, content);

    if (!mounted) return;

    if (success) {
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(groupProvider.error ?? 'Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userModel?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name,
                style: AppTextStyles.heading3.copyWith(fontSize: 18)),
            Text(
              '${widget.group.memberCount} members • ${widget.group.onlineCount} online',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Consumer<GroupProvider>(
              builder: (context, groupProvider, child) {
                final selectedGroup = groupProvider.selectedGroup ?? widget.group;
                final messages = groupProvider.messages;
                final isMember = selectedGroup.isMember(currentUserId);

                if (!isMember) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline,
                              size: 48, color: AppColors.primary),
                          const SizedBox(height: 12),
                          Text(
                            'Join this group to participate in the chat.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (groupProvider.isLoading && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(
                      message: message,
                      isOwn: message.senderId == currentUserId,
                    );
                  },
                );
              },
            ),
          ),

          // Input field
          Consumer<GroupProvider>(
            builder: (context, groupProvider, child) {
              final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
              final currentUserId = authProvider.userModel?.id ?? '';
              final canChat = _userIsMember(groupProvider, currentUserId);

              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 18,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.attach_file_rounded,
                        color: canChat ? AppColors.primary : AppColors.textMuted,
                      ),
                      onPressed: canChat ? () {} : null,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_rounded,
                        color: canChat ? AppColors.primary : AppColors.textMuted,
                      ),
                      onPressed: canChat ? () {} : null,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          enabled: canChat,
                          decoration: InputDecoration(
                            hintText:
                            canChat ? 'Type a message...' : 'Join the group to chat',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: canChat ? AppColors.primary : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: groupProvider.isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Icon(Icons.send_rounded, color: Colors.white),
                        onPressed: (!canChat || groupProvider.isLoading)
                            ? null
                            : _sendMessage,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ----------------------------
// Message Bubble Widget
// ----------------------------
class _MessageBubble extends StatelessWidget {
  final GroupMessage message;
  final bool isOwn;

  const _MessageBubble({
    required this.message,
    required this.isOwn,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isOwn ? AppColors.primary : Colors.white;
    final textColor = isOwn ? Colors.white : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          if (!isOwn)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 16,
                  backgroundImage: message.senderAvatar != null &&
                      message.senderAvatar!.isNotEmpty
                      ? NetworkImage(message.senderAvatar!)
                      : null,
                  child: message.senderAvatar == null ||
                      message.senderAvatar!.isEmpty
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  message.senderName ?? 'User',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (isOwn) const SizedBox(width: 40),
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: Radius.circular(isOwn ? 20 : 4),
                      bottomRight: Radius.circular(isOwn ? 4 : 20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: AppTextStyles.body.copyWith(
                          color: textColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.sentAt),
                        style: AppTextStyles.caption.copyWith(
                          color: textColor.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isOwn) const SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
