import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const CardMatchingGame());
}

class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<CardModel> cards = [];
  List<CardModel> selectedCards = [];
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    initializeCards();
  }

  // Initialize card data and shuffle the list
  void initializeCards() {
    List<String> cardImages = [
      '🐶', '😈', '🧠', '💅🏼', '❤️', '👀', '🤪', '🤟🏼', 
    ];

    cards = List.generate(cardImages.length * 2, (index) {
      return CardModel(
        frontDesign: cardImages[index % cardImages.length],
        isFaceUp: false,
      );
    });

    cards.shuffle(); // Shuffle the cards for randomness
  }

  // Handle card tap logic
  void onCardTapped(CardModel card) async {
    if (isBusy || card.isFaceUp || selectedCards.length == 2) return;

    setState(() {
      card.isFaceUp = true;
      selectedCards.add(card);
    });

    if (selectedCards.length == 2) {
      isBusy = true;
      await Future.delayed(const Duration(seconds: 1));

      if (selectedCards[0].frontDesign != selectedCards[1].frontDesign) {
        setState(() {
          selectedCards[0].isFaceUp = false;
          selectedCards[1].isFaceUp = false;
        });
      }

      selectedCards.clear();
      isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4x4 grid
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onCardTapped(cards[index]),
              child: CardWidget(card: cards[index]),
            );
          },
        ),
      ),
    );
  }
}

class CardModel {
  final String frontDesign;
  bool isFaceUp;

  CardModel({
    required this.frontDesign,
    this.isFaceUp = false,
  });
}

class CardWidget extends StatelessWidget {
  final CardModel card;

  const CardWidget({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final rotate = Tween(begin: pi, end: 0.0).animate(animation);

        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final isFront = card.isFaceUp;
            return Transform(
              transform: Matrix4.rotationY(isFront ? 0 : pi),
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      child: card.isFaceUp ? _buildFront() : _buildBack(),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
    );
  }

  Widget _buildFront() {
    return Container(
      key: const ValueKey(true),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          card.frontDesign,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      key: const ValueKey(false),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '🐕‍🦺', // Placeholder for back of the card
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}
