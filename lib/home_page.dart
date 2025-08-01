import 'package:flutter/material.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.lime,
  ];

  // Список карточек, который будет пополняться динамически
  final List<int> _cards = List.generate(10, (index) => index);

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

            // Add a hint text at the bottom
            Positioned(
              bottom: 40,
              child: Text(
                'Swipe up to dismiss',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCardStack() {
    final List<Widget> cardWidgets = [];

    // Проверяем, нужно ли добавить новые карточки
    _ensureEnoughCards();

    // Show only the top 3 cards for performance
    final int startIndex = math.max(0, _cards.length - 3);
    final int endIndex = _cards.length;

    for (int i = startIndex; i < endIndex; i++) {
      final int cardIndex = _cards[i];
      final int displayIndex = i - startIndex;
      final double topPosition = 80.0 + (displayIndex * 25);
      final double scale = 1.0 - (displayIndex * 0.05);

      cardWidgets.add(
        Positioned(
          top: topPosition,
          child: Transform.scale(
            scale: scale,
            child: AppCard(
              color: _colors[cardIndex % _colors.length],
              onDismiss: () => _dismissCard(i),
              index: cardIndex,
            ),
          ),
        ),
      );
    }

    return cardWidgets.reversed.toList(); // Reverse to get correct z-order
  }

  // Метод для обеспечения достаточного количества карточек
  void _ensureEnoughCards() {
    // Если осталось менее 5 карточек, добавляем еще 10
    if (_cards.length < 5) {
      final int lastIndex = _cards.isEmpty ? 0 : _cards.reduce(math.max);
      for (int i = 1; i <= 10; i++) {
        _cards.add(lastIndex + i);
      }
    }
  }

  void _dismissCard(int index) {
    setState(() {
      // Удаляем карточку
      _cards.removeAt(index);

      // Всегда добавляем новую карточку в начало списка
      // Используем значение меньше минимального в списке для сохранения порядка
      final newCardIndex = _cards.isEmpty ? 0 : (_cards.reduce(math.min) - 1);
      _cards.insert(0, newCardIndex);
    });
  }
}

class AppCard extends StatefulWidget {
  final Color color;
  final VoidCallback onDismiss;
  final int index;

  const AppCard({
    super.key,
    required this.color,
    required this.onDismiss,
    required this.index,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  double _dragExtent = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragExtent += details.delta.dy;
      // Limit drag to only upward direction
      _dragExtent = math.min(0, _dragExtent);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;

    // Dismiss if dragged far enough or with enough velocity
    if (_dragExtent < -100 || velocity < -500) {
      _controller.forward();
    } else {
      // Reset position
      setState(() {
        _isDragging = false;
        _dragExtent = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Transform.translate(
            offset: _isDragging ? Offset(0, _dragExtent) : Offset.zero,
            child: GestureDetector(
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
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
                child: Stack(
                  children: [
                    // App content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apps_rounded,
                            size: 50,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'App ${widget.index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Handle indicator at the top
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
