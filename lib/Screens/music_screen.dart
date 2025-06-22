import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  double _volume = 0.5;

  // Lista de canciones con título y URL
  final List<Map<String, String>> _songs = [
    {
      'title': 'Música para dormir',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
    },
    {
      'title': 'Relajación profunda',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
    },
    {
      'title': 'Música para concentrarse',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
    },
  ];

  int? _currentlyPlayingIndex;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(_volume); // Inicializa el volumen
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Libera recursos
    super.dispose();
  }

  // Función para reproducir o pausar una canción específica
  Future<void> _togglePlay(int index) async {
    if (_currentlyPlayingIndex == index && isPlaying) {
      await _audioPlayer.pause();
      setState(() => isPlaying = false);
    } else {
      await _audioPlayer.setUrl(_songs[index]['url']!);
      await _audioPlayer.play();
      setState(() {
        _currentlyPlayingIndex = index;
        isPlaying = true;
      });
    }
  }

  // Pausar música desde botón global
  Future<void> _pauseMusic() async {
    await _audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  // Controlar el volumen con Slider
  void _changeVolume(double value) {
    _audioPlayer.setVolume(value);
    setState(() => _volume = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Música Relajante')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                final isThisPlaying = isPlaying && _currentlyPlayingIndex == index;

                return ListTile(
                  leading: Icon(
                    isThisPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                  title: Text(song['title']!),
                  onTap: () => _togglePlay(index),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          const Text('Volumen'),
          Slider(
            value: _volume,
            onChanged: _changeVolume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(_volume * 100).round()}%',
          ),
          const SizedBox(height: 10),
        ],
      ),
      floatingActionButton: isPlaying
          ? FloatingActionButton(
              onPressed: _pauseMusic,
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.pause),
              tooltip: 'Pausar música',
            )
          : null,
    );
  }
}
