import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/group_model.dart';

class GroupChatArgs {
  final GroupModel group;

  GroupChatArgs({required this.group});
}

class GroupChatPage extends StatelessWidget {
  final GroupModel group;

  const GroupChatPage({super.key, required this.group});

  static const String routeName = '/group-chat';

  @override
  Widget build(BuildContext context) {
    final messages = group.messages; // messages list (can be empty)

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
            Text(group.name,
                style: AppTextStyles.heading3.copyWith(fontSize: 18)),
            Text(
              '${group.memberCount} members • ${group.onlineCount} online',
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
            child: ListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _ChatDateLabel(label: 'Today');
                }
                final message = messages[index - 1];
                return _MessageBubble(message: message);
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  icon: const Icon(Icons.attach_file_rounded,
                      color: AppColors.primary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_rounded,
                      color: AppColors.primary),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------
// Date Label Widget
// ----------------------------
class _ChatDateLabel extends StatelessWidget {
  final String label;

  const _ChatDateLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ----------------------------
// Message Bubble Widget
// ----------------------------
class _MessageBubble extends StatelessWidget {
  final GroupMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isOwn = message.isOwn;
    final alignment =
    isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start;
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
              children: const [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 16,
                  child: Icon(Icons.person, size: 16),
                ),
                SizedBox(width: 8),
                Text(
                  'User', // Placeholder sender name
                  style: TextStyle(
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
                  child: Text(
                    message.content,
                    style: AppTextStyles.body.copyWith(
                      color: textColor,
                      height: 1.5,
                    ),
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
}
