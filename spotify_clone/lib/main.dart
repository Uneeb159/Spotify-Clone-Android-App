import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'models/song.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MusicPlayerState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.purple,
          secondary: Colors.purpleAccent,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MusicPlayerState extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final NotificationService _notificationService = NotificationService();
  List<Song> _songs = Song.songs;
  List<Song> _favorites = [];
  Song? _currentSong;
  bool _isPlaying = false;
  bool _notificationsInitialized = false;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get songs => _songs;
  List<Song> get favorites => _favorites;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;

  MusicPlayerState() {
    _initializeNotifications();
    _setupAudioPlayerListeners();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
      _notificationsInitialized = true;
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      
      if (processingState == ProcessingState.completed) {
        _isPlaying = false;
        notifyListeners();
      } else if (_isPlaying != isPlaying) {
        _isPlaying = isPlaying;
        notifyListeners();
        
        // Update notification when play state changes
        if (_currentSong != null && _notificationsInitialized) {
          _notificationService.showMusicNotification(_currentSong!, _isPlaying);
        }
      }
    });
  }

  Future<void> playSong(Song song) async {
    try {
      _currentSong = song;
      await _audioPlayer.setAsset(song.songPath);
      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();

      // Show notification
      if (_notificationsInitialized) {
        await _notificationService.showMusicNotification(song, true);
      }
    } catch (e) {
      print('Error playing song: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      _isPlaying = !_isPlaying;
      notifyListeners();

      // Update notification
      if (_currentSong != null && _notificationsInitialized) {
        await _notificationService.showMusicNotification(_currentSong!, _isPlaying);
      }
    } catch (e) {
      print('Error toggling play: $e');
    }
  }

  Future<void> stopSong() async {
    try {
      await _audioPlayer.stop();
      _currentSong = null;
      _isPlaying = false;
      notifyListeners();

      // Cancel notification
      if (_notificationsInitialized) {
        await _notificationService.cancelNotification();
      }
    } catch (e) {
      print('Error stopping song: $e');
    }
  }

  void toggleFavorite(Song song) {
    song.isFavorite = !song.isFavorite;
    if (song.isFavorite) {
      if (!_favorites.contains(song)) {
        _favorites.add(song);
      }
    } else {
      _favorites.remove(song);
    }
    notifyListeners();
  }

  List<Song> searchSongs(String query) {
    return _songs.where((song) =>
      song.title.toLowerCase().contains(query.toLowerCase()) ||
      song.artist.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}