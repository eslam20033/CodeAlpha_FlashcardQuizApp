import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardWidget extends StatelessWidget {
  final Flashcard card;
  final bool showAnswer;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.showAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotate = AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (context, child) {
              final angle = animation.value * pi;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: angle > pi / 2
                    ? Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: child,
                      )
                    : child,
              );
            },
          );
          return rotate;
        },

        child: showAnswer
            ? _buildCardSide(
                card.answer,
                Colors.blue.shade50,
                Colors.blue.shade700,
                "ANSWER",
                key: const ValueKey(true),
              )
            : _buildCardSide(
                card.question,
                Colors.white,
                Colors.orange.shade800,
                "QUESTION",
                key: const ValueKey(false),
              ),
      ),
    );
  }

  Widget _buildCardSide(
    String text,
    Color bgColor,
    Color textColor,
    String label, {
    required Key key,
  }) {
    return Container(
      key: key,
      height: 350,
      width: 280,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: textColor.withOpacity(0.2), width: 2),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              label,
              style: TextStyle(
                color: textColor.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
