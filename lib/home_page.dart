import 'package:flutter/material.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
  ];

  final List<int> _cards = List.generate(20, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Display the cards
            ..._buildCardStack(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCardStack() {
    final List<Widget> cardWidgets = [];

    // Show only the top 3 cards for performance
    final int startIndex = math.max(0, _cards.length - 3);
    final int endIndex = _cards.length;

    for (int i = startIndex; i < endIndex; i++) {
      final int cardIndex = _cards[i];
      final int displayIndex = i - startIndex;
      final double topPosition = 100.0 + (displayIndex * 20);
      final double scale = 1.0 - (displayIndex * 0.05);

      cardWidgets.add(
        Positioned(
          top: topPosition,
          child: Transform.scale(
            scale: scale,
            child: AppCard(
              key: ValueKey(cardIndex),
              color: _colors[cardIndex % _colors.length],
              onDismiss: () => _dismissCard(i),
            ),
          ),
        ),
      );
    }

    return cardWidgets.reversed.toList(); // Reverse to get correct z-order
  }

  void _dismissCard(int index) {
    setState(() {
      _cards.removeAt(index);
      // Add a new card at the end (bottom of the stack)
      final newCardIndex = _cards.isEmpty ? 0 : _cards.reduce(math.max) + 1;
      _cards.add(newCardIndex);
    });
  }
}

class AppCard extends StatefulWidget {
  final Color color;
  final VoidCallback onDismiss;

  const AppCard({super.key, required this.color, required this.onDismiss});

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dismissible(
      key: ValueKey(widget.color.value),
      direction: DismissDirection.up,
      onDismissed: (_) => widget.onDismiss(),
      child: Container(
        width: size.width * 0.85,
        height: size.height * 0.65,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.apps_rounded,
            size: 50,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
