import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardProvider extends ChangeNotifier {
  final List<Flashcard> _cards = [];

  int _currentIndex = 0;
  bool _showAnswer = false;

  List<Flashcard> get cards => _cards;

  Flashcard? get currentCard =>
      _cards.isNotEmpty ? _cards[_currentIndex] : null;

  bool get showAnswer => _showAnswer;

  int get currentIndex => _currentIndex;

  void toggleAnswer() {
    _showAnswer = !_showAnswer;
    notifyListeners();
  }

  void nextCard() {
    if (_cards.isEmpty) return;

    if (_currentIndex < _cards.length - 1) {
      _currentIndex++;
      _showAnswer = false;
      notifyListeners();
    }
  }

  void prevCard() {
    if (_cards.isEmpty) return;

    if (_currentIndex > 0) {
      _currentIndex--;
      _showAnswer = false;
      notifyListeners();
    }
  }

  void setIndex(int index) {
    if (_cards.isEmpty) return;

    _currentIndex = index;
    _showAnswer = false;
    notifyListeners();
  }

  void addCard(String question, String answer) {
    if (question.trim().isEmpty || answer.trim().isEmpty) return;

    _cards.add(Flashcard(question: question, answer: answer));

    if (_cards.length == 1) {
      _currentIndex = 0;
    }

    notifyListeners();
  }

  void editCard(String question, String answer) {
    if (_cards.isEmpty) return;

    _cards[_currentIndex] = Flashcard(question: question, answer: answer);

    notifyListeners();
  }

  void deleteCard() {
    if (_cards.isEmpty) return;

    _cards.removeAt(_currentIndex);

    if (_currentIndex >= _cards.length && _currentIndex > 0) {
      _currentIndex--;
    }

    notifyListeners();
  }
}
