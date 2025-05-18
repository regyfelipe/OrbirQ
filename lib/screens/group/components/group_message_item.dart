import 'package:flutter/material.dart';
import '../../../models/group_message.dart';
import '../../../themes/colors.dart';

class GroupMessageItem extends StatelessWidget {
  final GroupMessage message;
  final bool isMe;

  const GroupMessageItem({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Text(
                  message.senderName,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              _buildMessageContent(),
              const SizedBox(height: 4),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe
                      ? Colors.white.withOpacity(0.7)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    // Se tiver uma URL de anexo, é uma imagem ou arquivo
    if (message.attachmentUrl != null) {
      if (message.attachmentUrl!
          .contains(RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false))) {
        // É uma imagem
        return Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.attachmentUrl!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ],
        );
      } else {
        // É um arquivo
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.attach_file),
          title: Text(
            message.content,
            style: TextStyle(
              color: isMe ? Colors.white : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Clique para baixar',
            style: TextStyle(
              color: isMe ? Colors.white70 : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          onTap: () {
   
          },
        );
      }
    }

    return Text(
      message.content,
      style: TextStyle(
        color: isMe ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
