import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/flashcard_provider.dart';
import '../widgets/flashcard_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();
    final bool hasCards = provider.cards.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: _buildAppBar(context, provider),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.withOpacity(0.1), const Color(0xFFF8F9FD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (hasCards) _buildProgressHeader(provider),
              Expanded(
                child: hasCards
                    ? _buildCardsView(provider)
                    : _buildEmptyState(),
              ),
              if (hasCards) _buildActionButtons(context, provider),
              _buildBottomNavBar(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    FlashcardProvider provider,
  ) {
    return AppBar(
      title: const Text(
        "Flashcard Master",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildProgressHeader(FlashcardProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Card ${provider.currentIndex + 1} of ${provider.cards.length}",
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: 100,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: provider.cards.isEmpty
                  ? 0
                  : (provider.currentIndex + 1) / provider.cards.length,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsView(FlashcardProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: PageView.builder(
        itemCount: provider.cards.length,
        controller: PageController(initialPage: provider.currentIndex),
        onPageChanged: (index) => provider.setIndex(index),
        itemBuilder: (context, index) {
          return AnimatedScale(
            scale: provider.currentIndex == index ? 1.0 : 0.9,
            duration: const Duration(milliseconds: 300),
            child: FlashcardWidget(
              card: provider.cards[index],
              showAnswer: provider.showAnswer,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 100,
            color: Colors.blue.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          const Text(
            "Your deck is empty",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text("Add some cards to start learning!"),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, FlashcardProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: provider.toggleAnswer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
          ),
          child: Text(
            provider.showAnswer ? "HIDE ANSWER" : "REVEAL ANSWER",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, FlashcardProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomIcon(
            Icons.edit_note_rounded,
            Colors.blue,
            provider.cards.isNotEmpty
                ? () => _showEditDialog(context, provider)
                : null,
          ),
          GestureDetector(
            onTap: () => _showAddDialog(context, provider),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
          _buildBottomIcon(
            Icons.delete_sweep_outlined,
            Colors.redAccent,
            provider.cards.isNotEmpty ? () => provider.deleteCard() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, Color color, VoidCallback? onTap) {
    return IconButton(
      icon: Icon(icon, color: onTap == null ? Colors.grey : color, size: 28),
      onPressed: onTap,
    );
  }

  void _showAddDialog(BuildContext context, FlashcardProvider provider) {
    final qController = TextEditingController();
    final aController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Flashcard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              decoration: const InputDecoration(labelText: "Question"),
            ),
            TextField(
              controller: aController,
              decoration: const InputDecoration(labelText: "Answer"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (qController.text.isNotEmpty && aController.text.isNotEmpty) {
                provider.addCard(qController.text, aController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, FlashcardProvider provider) {
    if (provider.currentCard == null) return;
    final qController = TextEditingController(
      text: provider.currentCard!.question,
    );
    final aController = TextEditingController(
      text: provider.currentCard!.answer,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Flashcard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              decoration: const InputDecoration(labelText: "Question"),
            ),
            TextField(
              controller: aController,
              decoration: const InputDecoration(labelText: "Answer"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.editCard(qController.text, aController.text);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
