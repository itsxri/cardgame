import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; //for delay

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => GameState(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CardMatchingGame(),
    );
  }
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bikini Bottom Matching'),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns per row
                  ),
                  itemCount: gameState.cards.length,
                  itemBuilder: (context, index) {
                    final card = gameState.cards[index];
                    return GestureDetector(
                      onTap: () {
                        gameState.flipCard(index);

                        // Show correct/incorrect message 
                        if (gameState.showCorrectMessage) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('You found a pair!')),
                          );
                        } else if (gameState.showIncorrectMessage) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sorry, try again.')),
                          );
                        }

                        
                        if (gameState.allPairsFound()) {
                          Future.delayed(Duration(milliseconds: 500), () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Congratulations!'),
                                  content: Text('You found all pairs!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        gameState.resetGame(); // Reset game
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Play Again'),
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        child: card.isFaceUp
                            ? Image.asset(card.frontImage) // card front
                            : Image.asset('assets/card_back.png'), // card back
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CardModel {
  String frontImage;
  bool isFaceUp;

  CardModel({required this.frontImage, this.isFaceUp = false});
}

class GameState with ChangeNotifier {
  List<CardModel> cards = []; 
  List<int> flippedIndices = []; 
  bool showCorrectMessage = false;
  bool showIncorrectMessage = false;

  GameState() {
    _initializeCards(); 
  }

  void _initializeCards() {
    // front cards
    List<String> images = [
      'assets/Mr._Krabs.png',
      'assets/Plankton_stock_art.webp',
      'assets/Patrick_Star.svg.png',
    ];

    cards = images.map((image) => CardModel(frontImage: image)).toList();
    cards.addAll(cards.map((card) => CardModel(frontImage: card.frontImage)).toList());

    // Shuffle 
    cards.shuffle();
  }

  void flipCard(int index) {
    if (cards[index].isFaceUp) return;

    cards[index].isFaceUp = !cards[index].isFaceUp; // Flip the card
    flippedIndices.add(index);

    if (flippedIndices.length == 2) {
      _checkMatch();
    }

    notifyListeners(); 
  }

  void _checkMatch() {
    if (cards[flippedIndices[0]].frontImage == cards[flippedIndices[1]].frontImage) {
      // It's a match
      showCorrectMessage = true;
      showIncorrectMessage = false;
      flippedIndices.clear();
    } else {
      // Not a match
      showCorrectMessage = false;
      showIncorrectMessage = true;

      Future.delayed(Duration(seconds: 1), () {
        cards[flippedIndices[0]].isFaceUp = false;
        cards[flippedIndices[1]].isFaceUp = false;
        flippedIndices.clear();
        notifyListeners(); 
      });
    }

    // Reset the messages 
    Future.delayed(Duration(milliseconds: 1500), () {
      showCorrectMessage = false;
      showIncorrectMessage = false;
      notifyListeners();
    });
  }

  void resetGame() {
    // Reset game and shuffle cards
    flippedIndices.clear();
    _initializeCards(); 
    notifyListeners();
  }

  bool allPairsFound() {
    // are the cards faceup?
    return cards.every((card) => card.isFaceUp);
  }
}
