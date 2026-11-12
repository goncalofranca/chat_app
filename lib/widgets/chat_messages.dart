import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatSnapshot.hasError) {
          debugPrint('[DEBUG] chat stream error: ${chatSnapshot.error}');
          return _EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong',
            subtitle: '${chatSnapshot.error}',
          );
        }

        final chatDocs = chatSnapshot.data?.docs ?? [];
        debugPrint(
          '[DEBUG] currentUid=$currentUid docs=${chatDocs.length} '
          '${chatDocs.map((d) => '(${d.id}: userId=${d.data()['userId']}, username=${d.data()['username']})').join(' ')}',
        );
        if (chatDocs.isEmpty) {
          return const _EmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No messages yet',
            subtitle: 'Be the first to say hello 👋',
          );
        }

        String senderOf(Map<String, dynamic> data) =>
            (data['userId'] ?? data['userUid'] ?? data['username'] ?? '')
                .toString();

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) {
            final data = chatDocs[index].data();
            // The list is reversed, so the next index is the older message.
            final olderData = index + 1 < chatDocs.length
                ? chatDocs[index + 1].data()
                : null;
            final sender = senderOf(data);
            final continuesSequence =
                olderData != null && senderOf(olderData) == sender;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            final isMe = currentUid != null && sender == currentUid;
            final text = (data['text'] ?? '').toString();

            if (continuesSequence) {
              return ChatBubble.next(
                key: ValueKey(chatDocs[index].id),
                message: text,
                isMe: isMe,
                createdAt: createdAt,
              );
            }
            return ChatBubble.first(
              key: ValueKey(chatDocs[index].id),
              userImage: data['userImage'] as String?,
              username: (data['username'] ?? 'Unknown').toString(),
              message: text,
              isMe: isMe,
              createdAt: createdAt,
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
