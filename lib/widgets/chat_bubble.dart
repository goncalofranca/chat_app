import 'package:flutter/material.dart';

// A ChatBubble for showing a single chat message on the ChatScreen.
class ChatBubble extends StatelessWidget {
  // A bubble that starts a sequence of messages from the same user. Shows the
  // avatar and username.
  const ChatBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
    this.createdAt,
  }) : isFirstInSequence = true;

  // A bubble that continues a sequence of messages from the same user.
  const ChatBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    this.createdAt,
  }) : isFirstInSequence = false,
       userImage = null,
       username = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String? username;
  final String message;
  final bool isMe;
  final DateTime? createdAt;

  static const _avatarRadius = 18.0;

  String? get _time {
    final date = createdAt;
    if (date == null) return null;
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildAvatar(ColorScheme scheme) {
    // Reserves the avatar's space so consecutive bubbles stay aligned.
    if (!isFirstInSequence) return const SizedBox(width: _avatarRadius * 2);

    final image = userImage;
    final initial = (username?.trim().isNotEmpty ?? false)
        ? username!.trim()[0].toUpperCase()
        : '?';
    return CircleAvatar(
      radius: _avatarRadius,
      backgroundColor: scheme.primaryContainer,
      foregroundImage: (image != null && image.isNotEmpty)
          ? NetworkImage(image)
          : null,
      child: Text(
        initial,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bubbleColor = isMe ? scheme.primary : scheme.surfaceContainerHighest;
    final textColor = isMe ? scheme.onPrimary : scheme.onSurface;
    const big = Radius.circular(20);
    const small = Radius.circular(6);

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: big,
          topRight: big,
          bottomLeft: isMe ? big : (isFirstInSequence ? small : big),
          bottomRight: isMe ? (isFirstInSequence ? small : big) : big,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.35,
                color: textColor,
              ),
            ),
          ),
          if (_time != null) ...[
            const SizedBox(height: 2),
            Text(
              _time!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor.withAlpha(170),
              ),
            ),
          ],
        ],
      ),
    );

    final content = Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!isMe && username != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              username!,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
        bubble,
      ],
    );

    return Padding(
      padding: EdgeInsets.only(top: isFirstInSequence ? 14 : 3),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[_buildAvatar(scheme), const SizedBox(width: 8)],
          Flexible(child: content),
          if (isMe) ...[const SizedBox(width: 8), _buildAvatar(scheme)],
        ],
      ),
    );
  }
}
