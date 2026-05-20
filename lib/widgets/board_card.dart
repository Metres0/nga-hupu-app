import 'package:flutter/material.dart';
import '../models/models.dart';

class BoardCard extends StatelessWidget {
  final BoardNode board;
  final bool isSubscribed;
  final VoidCallback onToggle;

  const BoardCard({
    super.key,
    required this.board,
    required this.isSubscribed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/forum', arguments: board),
              child: Text(
                board.name,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isSubscribed ? Icons.remove_circle_outline : Icons.add_circle_outline,
              color: isSubscribed
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.7),
              size: 22,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
