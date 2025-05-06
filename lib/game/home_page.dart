import 'package:flutter/material.dart';
import '../utils/trapezoi_dclicp.dart';
import 'game_wrapper.dart';
import 'package:audioplayers/audioplayers.dart';

import 'kassongo_game.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _backgroundPlayer;
  late final AudioPlayer _sfxPlayer;
  bool showOverlay = false;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  int lionWins = 5;
  int phacochereWins = 10;
  String selectedCharacter = 'Phacochere';

  @override
  void initState() {
    super.initState();

    _backgroundPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    _playBackgroundSound();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void toggleOverlay() {
    setState(() {
      showOverlay = !showOverlay;
    });
  }

  void _playBackgroundSound() async {
    await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    await _backgroundPlayer.play(AssetSource('audio/home.mp3'), volume: 0.7);
  }

  void _stopBackgroundSound() {
    _backgroundPlayer.stop();
    _sfxPlayer.stop();
  }

  @override
  void dispose() {
    _stopBackgroundSound();
    _floatController.dispose();
    _backgroundPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  Widget _characterButton(String name, String imagePath) {
    bool isSelected = selectedCharacter == name;

    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedCharacter = name;
        });

        // Joue le cri du personnage sélectionné sans couper la musique de fond
        String audioPath = 'audio/${name.toLowerCase()}.mp3';
        await _sfxPlayer.play(AssetSource(audioPath), volume: 1.0);
        //loop
      },
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset:
                isSelected ? Offset.zero : Offset(0, -_floatAnimation.value),
            child: child,
          );
        },
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.yellowAccent : Colors.transparent,
                  width: 3,
                ),
                shape: BoxShape.circle,
              ),
              child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover)),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Image du personnage sélectionné au centre
          Align(
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Image.asset(
                selectedCharacter == 'Phacochere'
                    ? 'assets/images/img_1.png'
                    : 'assets/images/img_2.png',
                key: ValueKey<String>(selectedCharacter),
                width: 500,
                height: 500,
              ),
            ),
          ),
          // Choix du personnage en bas
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _characterButton("Phacochere", 'assets/images/img_1.png'),
                const SizedBox(width: 20),
                _characterButton("Lion", 'assets/images/img_2.png'),
              ],
            ),
          ),
          // Statistiques en haut à gauche
          Positioned(
            top: 60,
            left: 30,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(163, 63, 0, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'statistiques',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phacochere : $phacochereWins',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    'lion : $lionWins',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // Bloc des classements ou autre contenu sous l'image
          Positioned(
            bottom: 80, // Ajuster selon l'espacement désiré

            left: 30,
            child: Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Color.fromARGB(163, 63, 0, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Classement',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phacochere Wins: $phacochereWins',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    'Lion Wins: $lionWins',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // 🎮 Boutons à droite
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _menuButton(
                    text: "play",
                    icon: Icons.play_arrow,
                    onTap: () {
                      _stopBackgroundSound();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => GameWrapper(
                                character: selectedCharacter,
                                onVictory: (winner) {
                                  setState(() {
                                    if (winner == 'Phacochere')
                                      phacochereWins++;
                                    if (winner == 'Lion') lionWins++;
                                  });
                                },
                              ),
                        ),
                      );
                    },
                    rightPadding: 0,
                  ),
                  const SizedBox(height: 20),
                  _menuButton(
                    text: "with friend",
                    icon: Icons.group,
                    onTap: () {
                      // Inactif pour l'instant
                    },
                    rightPadding: 0,
                  ),
                  const SizedBox(height: 20),
                  _menuButton(
                    text: "Arcade",
                    icon: Icons.videogame_asset,
                    onTap: () {
                      // À implémenter
                    },
                    rightPadding: 0,
                  ),
                ],
              ),
            ),
          ),
          // 🔧 Groupe d'icônes d'options
          Positioned(
            top: 10,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.yellowAccent,
                    size: 40,
                  ),
                  onPressed: () {
                    // Action pour paramètres
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.celebration,
                    color: Colors.yellowAccent,
                  ),
                  onPressed: toggleOverlay,
                ),

                const SizedBox(width: 10),

                IconButton(
                  icon: Icon(
                    Icons.volume_up,
                    color: Colors.yellowAccent,
                    size: 32,
                  ),
                  onPressed: () {
                    // Action pour le son
                  },
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: Colors.yellowAccent,
                    size: 32,
                  ),
                  onPressed: () {
                    // Action pour l'aide
                  },
                ),
              ],
            ),
          ),
          if (showOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Fin de partie',
                        style: TextStyle(color: Colors.white, fontSize: 32),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Phacochère: $phacochereWins\nLion: $lionWins',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: Icon(Icons.refresh),
                        label: const Text("Rejouer"),
                        onPressed: () {
                          toggleOverlay(); // cacher l’overlay
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellowAccent,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    double rightPadding = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: rightPadding),
      child: GestureDetector(
        onTap: onTap,
        child: ClipPath(
          clipper: TrapezoidClipper(),
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            color: Color.fromARGB(163, 63, 0, 1),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
