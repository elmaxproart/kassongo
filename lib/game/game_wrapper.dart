import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'kassongo_game.dart';

class GameWrapper extends StatefulWidget {
  final String character;
  final Function(String winner) onVictory;

  const GameWrapper({
    super.key,
    required this.character,
    required this.onVictory,
  });

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  late KassongoGame _game;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _game = KassongoGame(
      selectedCharacter: widget.character,
      onGameEnd: (message) {
        if (message == "Game exited") {
          Navigator.of(context).pop();
        } else if (message == "Game Over") {
          _game.overlays.add('GameOver');
        } else {
          widget.onVictory(message);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget(game: _game));
  }
}

class GameOverMenu extends StatelessWidget {
  final FlameGame game;

  const GameOverMenu({required this.game, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.redAccent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  game.overlays.remove('GameOver');
                  game.resumeEngine();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
