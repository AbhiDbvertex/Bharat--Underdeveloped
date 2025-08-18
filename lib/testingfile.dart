import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MusicPlayerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _loaded = false;
  bool _playing = false;
  String _musicUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'; // Sample MP3 for demo
  String _thumbnailUrl = 'https://via.placeholder.com/350x350'; // Placeholder image
  String _songTitle = 'Sample Song';
  String _artistName = 'Sample Artist';

  @override
  void initState() {
    super.initState();
    _loadMusic();
    _fetchMusicFromAPI(); // Fetch music data from API
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // Load music from URL
  Future<void> _loadMusic() async {
    try {
      await _player.setUrl(_musicUrl);
      setState(() {
        _loaded = true;
      });
    } catch (e) {
      print('Error loading music: $e');
    }
  }

  // Play music
  Future<void> _playMusic() async {
    setState(() {
      _playing = true;
    });
    await _player.play();
  }

  // Pause music
  Future<void> _pauseMusic() async {
    setState(() {
      _playing = false;
    });
    await _player.pause();
  }

  // Seek backward or forward
  Future<void> _seekMusic(int seconds) async {
    if (!_loaded) return;
    final newPosition = _player.position.inSeconds + seconds;
    final duration = _player.duration?.inSeconds ?? 0;
    if (newPosition >= 0 && newPosition <= duration) {
      await _player.seek(Duration(seconds: newPosition));
    } else if (newPosition < 0) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seek(Duration(seconds: duration));
    }
  }

  // Fetch music data from Free Music Archive API (placeholder)
  Future<void> _fetchMusicFromAPI() async {
    // Note: Free Music Archive API requires an API key. For demo, we use a sample URL.
    // Replace with actual API call when you have an API key from https://freemusicarchive.org/api
    try {
      final response = await http.get(Uri.parse('https://musicbrainz.org/doc/MusicBrainz_API'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Example: Update _musicUrl, _songTitle, _artistName, _thumbnailUrl based on API response
        setState(() {
          // Placeholder: Update with actual API data parsing
          _songTitle = data['title'] ?? 'Sample Song';
          _artistName = data['artist'] ?? 'Sample Artist';
        });
      } else {
        print('Failed to fetch music data');
      }
    } catch (e) {
      print('Error fetching music: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dost Music Player'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _thumbnailUrl,
                height: 350,
                width: 350,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.music_note, size: 350),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _songTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _artistName,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder(
                stream: _player.positionStream,
                builder: (context, snapshot1) {
                  final Duration position = snapshot1.data as Duration? ?? Duration.zero;
                  return StreamBuilder(
                    stream: _player.bufferedPositionStream,
                    builder: (context, snapshot2) {
                      final Duration buffered = snapshot2.data as Duration? ?? Duration.zero;
                      return SizedBox(
                        height: 30,
                        child: ProgressBar(
                          progress: position,
                          total: _player.duration ?? Duration.zero,
                          buffered: buffered,
                          timeLabelPadding: -1,
                          timeLabelTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
                          progressBarColor: Colors.red,
                          baseBarColor: Colors.grey[200],
                          bufferedBarColor: Colors.grey[350],
                          thumbColor: Colors.red,
                          onSeek: _loaded
                              ? (duration) async {
                            await _player.seek(duration);
                          }
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.fast_rewind_rounded, size: 40),
                  onPressed: _loaded ? () => _seekMusic(-10) : null,
                ),
                Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: _loaded
                        ? () {
                      if (_playing) {
                        _pauseMusic();
                      } else {
                        _playMusic();
                      }
                    }
                        : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fast_forward_rounded, size: 40),
                  onPressed: _loaded ? () => _seekMusic(10) : null,
                ),
              ],
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}