import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../main.dart';
import '../models/song.dart';

// Particle class for the particle system
class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// Custom painter for particle system
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      // Update particle position
      particle.y = (particle.y + particle.speed * 0.01) % 1.0;
      particle.x = (particle.x + math.sin(animationValue * 2 * math.pi + particle.y * 10) * 0.001) % 1.0;

      paint.color = Color(0xFF64FFDA).withOpacity(particle.opacity * 0.6);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late AnimationController _miniPlayerController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _rotateController;
  late AnimationController _breathingController;
  late AnimationController _floatingPlayerController;
  late AnimationController _seekBarController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _miniPlayerAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<Offset> _floatingPlayerSlideAnimation;
  late Animation<double> _seekBarAnimation;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  bool _isDragging = false;
  double _dragPosition = 0.0;
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAnimations();
    _generateParticles();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _miniPlayerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingPlayerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _seekBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _miniPlayerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _miniPlayerController,
      curve: Curves.elasticOut,
    ));

    _floatingPlayerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _floatingPlayerController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotateController);

    _breathingAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _seekBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _seekBarController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _generateParticles() {
    particles = List.generate(30, (index) {
      return Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 3 + 1,
        speed: math.Random().nextDouble() * 0.5 + 0.1,
        opacity: math.Random().nextDouble() * 0.5 + 0.1,
      );
    });
  }

  void _handleSeekStart(double value) {
    setState(() {
      _isDragging = true;
      _dragPosition = value.clamp(0.0, 1.0);
    });
    _seekBarController.forward();
  }

  void _handleSeekUpdate(double value, MusicPlayerState playerState) {
    setState(() {
      _dragPosition = value.clamp(0.0, 1.0);
    });
  }

  void _handleSeekEnd(double value, MusicPlayerState playerState) {
    setState(() {
      _isDragging = false;
    });
    _seekBarController.reverse();

    // Seek to the new position using just_audio
    final duration = playerState.audioPlayer.duration;
    if (duration != null) {
      final newPosition = Duration(seconds: (value * duration.inSeconds).round());
      playerState.audioPlayer.seek(newPosition);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _miniPlayerController.dispose();
    _floatingPlayerController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _rotateController.dispose();
    _breathingController.dispose();
    _seekBarController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayerState>(
      builder: (context, playerState, child) {
        // Handle floating player animation
        if (playerState.currentSong != null && !_floatingPlayerController.isCompleted) {
          _floatingPlayerController.forward();
        } else if (playerState.currentSong == null) {
          _floatingPlayerController.reverse();
        }

        return Scaffold(
          body: Stack(
            children: [
              _buildAnimatedBackground(),
              _buildParticleSystem(),
              SafeArea(
                child: Column(
                  children: [
                    _buildSpectacularAppBar(),
                    _buildEnhancedSearchBar(),
                    _buildGlassmorphicTabBar(),
                    Expanded(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Stack(
                              children: [
                                TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildSpectacularSongsList(playerState, false),
                                    _buildSpectacularSongsList(playerState, true),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Add bottom padding when floating player is visible
                    if (playerState.currentSong != null)
                      const SizedBox(height: 120), // Increased height for seek bar
                  ],
                ),
              ),
              // Floating Mini Player - positioned absolutely
              if (playerState.currentSong != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SlideTransition(
                    position: _floatingPlayerSlideAnimation,
                    child: _buildFloatingMiniPlayer(playerState),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + math.sin(_waveAnimation.value) * 0.1,
                0.7 + math.cos(_waveAnimation.value) * 0.1,
                1.0,
              ],
              colors: [
                const Color(0xFF0A0A0A),
                const Color(0xFF1A1A2E).withOpacity(0.9),
                const Color(0xFF16213E).withOpacity(0.8),
                const Color(0xFF0F3460),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleSystem() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(particles, _particleController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildSpectacularAppBar() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DB954).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFF1DB954),
                              Color(0xFF1ED760),
                              Color(0xFF00D4AA),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1DB954).withOpacity(0.6),
                              blurRadius: 15,
                              spreadRadius: 3,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SoundWave',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Experience Music Like Never Before',
                        style: TextStyle(
                          color: Color(0xFF64FFDA),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearchVisible = !_isSearchVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isSearchVisible ? Icons.close : Icons.search,
                            color: const Color(0xFF64FFDA),
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      height: _isSearchVisible ? 100 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: _isSearchVisible ? 1.0 : 0.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF64FFDA).withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64FFDA).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search for your favorite tracks...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF64FFDA),
                size: 24,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {});
                },
                child: const Icon(
                  Icons.clear,
                  color: Color(0xFF64FFDA),
                ),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1DB954),
                Color(0xFF64FFDA),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1DB954).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          tabs: const [
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('All Tracks'),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Favorites'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpectacularSongsList(MusicPlayerState playerState, bool favoritesOnly) {
    var songs = favoritesOnly ? playerState.favorites : playerState.songs;
    if (_searchController.text.isNotEmpty) {
      songs = playerState.searchSongs(_searchController.text);
    }

    if (songs.isEmpty) {
      return _buildEmptyState(favoritesOnly);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            // Clamp the value to ensure it stays within valid opacity range
            final clampedOpacity = value.clamp(0.0, 1.0);

            return Transform.translate(
              offset: Offset(100 * (1 - value), 0),
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: clampedOpacity,
                  child: _buildSpectacularSongTile(song, playerState),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool favoritesOnly) {
    return Center(
      child: AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF64FFDA).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF64FFDA).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    favoritesOnly ? Icons.favorite_border : Icons.music_off,
                    size: 80,
                    color: const Color(0xFF64FFDA),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  favoritesOnly ? 'No favorite songs yet' : 'No songs found',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  favoritesOnly
                      ? 'Start adding songs to your favorites!'
                      : 'Try adjusting your search terms',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpectacularSongTile(Song song, MusicPlayerState playerState) {
    final isCurrentSong = playerState.currentSong?.id == song.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrentSong
              ? [
            const Color(0xFF1DB954).withOpacity(0.3),
            const Color(0xFF64FFDA).withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ]
              : [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentSong
              ? const Color(0xFF1DB954).withOpacity(0.6)
              : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentSong
                ? const Color(0xFF1DB954).withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: isCurrentSong ? 20 : 10,
            spreadRadius: isCurrentSong ? 2 : 0,
            offset: Offset(0, isCurrentSong ? 8 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Hero(
            tag: song.id,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  if (isCurrentSong)
                    BoxShadow(
                      color: const Color(0xFF1DB954).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Image.asset(
                      song.coverPath,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1DB954), Color(0xFF64FFDA)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 32,
                          ),
                        );
                      },
                    ),
                    if (isCurrentSong && playerState.isPlaying)
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.graphic_eq,
                          color: Color(0xFF64FFDA),
                          size: 28,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          title: Text(
            song.title,
            style: TextStyle(
              color: isCurrentSong ? const Color(0xFF64FFDA) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentSong)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1DB954), Color(0xFF64FFDA)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'PLAYING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => playerState.toggleFavorite(song),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: song.isFavorite
                        ? const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    )
                        : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: song.isFavorite
                          ? const Color(0xFFFF6B6B).withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                    ),
                    boxShadow: song.isFavorite
                        ? [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    song.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: song.isFavorite ? Colors.white : const Color(0xFF64FFDA),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          onTap: () => playerState.playSong(song),
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildFloatingMiniPlayer(MusicPlayerState playerState) {
    if (playerState.currentSong == null) {
      return const SizedBox.shrink();
    }

    // Get actual duration and position from the audio player
    return StreamBuilder<Duration?>(
      stream: playerState.audioPlayer.durationStream,
      builder: (context, durationSnapshot) {
        return StreamBuilder<Duration>(
          stream: playerState.audioPlayer.positionStream,
          builder: (context, positionSnapshot) {
            final duration = durationSnapshot.data?.inSeconds.toDouble() ?? 180.0;
            final currentPosition = _isDragging
                ? _dragPosition * duration
                : (positionSnapshot.data?.inSeconds.toDouble() ?? 0.0);
            final progress = _isDragging
                ? _dragPosition
                : (duration > 0 ? currentPosition / duration : 0.0);

            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1DB954),
                    Color(0xFF64FFDA),
                    Color(0xFF00D4AA),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1DB954).withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 3,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: const Color(0xFF64FFDA).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main player content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          // Album Art
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                playerState.currentSong!.coverPath,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF1DB954), Color(0xFF64FFDA)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Song Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  playerState.currentSong!.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  playerState.currentSong!.artist,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Control Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Play/Pause Button
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: playerState.isPlaying ? _pulseAnimation.value : 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.9),
                                            Colors.white.withOpacity(0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: playerState.togglePlay,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                                              color: const Color(0xFF1DB954),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),

                              // Close/Stop Button
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.red.withOpacity(0.8),
                                      Colors.redAccent.withOpacity(0.9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      playerState.stopSong();
                                      _floatingPlayerController.reverse();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Seek Bar Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          // Progress Bar with Slider
                          Container(
                            height: 40, // Increased height for better touch area
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.white.withOpacity(0.9),
                                inactiveTrackColor: Colors.white.withOpacity(0.3),
                                thumbColor: const Color(0xFF64FFDA),
                                overlayColor: const Color(0xFF64FFDA).withOpacity(0.3),
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: _isDragging ? 10 : 8,
                                ),
                                overlayShape: RoundSliderOverlayShape(
                                  overlayRadius: _isDragging ? 20 : 15,
                                ),
                                trackHeight: 6,
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChangeStart: (value) {
                                  _handleSeekStart(value);
                                },
                                onChanged: (value) {
                                  _handleSeekUpdate(value, playerState);
                                },
                                onChangeEnd: (value) {
                                  _handleSeekEnd(value, playerState);
                                },
                              ),
                            ),
                          ),

                          // Time labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(currentPosition),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _formatDuration(duration),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}