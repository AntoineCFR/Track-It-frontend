import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_it/services/auth_service.dart';
import 'package:track_it/services/spotify_service.dart';
import 'package:track_it/widgets/feature_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCheckingSpotify = true;

  @override
  void initState() {
    super.initState();
    _checkSpotifyLink();
  }

  Future<void> _checkSpotifyLink() async {
    final spotifyService = Provider.of<SpotifyService>(context, listen: false);
    await spotifyService.checkSpotifyLinked();
    if (mounted) {
      setState(() {
        _isCheckingSpotify = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final spotifyService = Provider.of<SpotifyService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track It'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: _isCheckingSpotify
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Info
                  if (user != null) ...[
                    Card(
                      color: Colors.grey[900],
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (user.photoURL != null)
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(user.photoURL!),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              user.displayName ?? user.email ?? 'User',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? '',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Spotify Status
                  const Text(
                    'Spotify Connection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (spotifyService.isLinked)
                    FeatureCard(
                      icon: Icons.check_circle,
                      title: 'Spotify Linked',
                      subtitle: 'Your Spotify account is connected',
                      color: Colors.green,
                      onTap: () async {
                        // Option to unlink
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Unlink Spotify?'),
                            content: const Text(
                              'Are you sure you want to unlink your Spotify account?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await spotifyService.unlinkSpotify();
                                  if (mounted) Navigator.pop(context);
                                },
                                child: const Text(
                                  'Unlink',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    FeatureCard(
                      icon: Icons.link,
                      title: 'Link Spotify',
                      subtitle: 'Connect your Spotify account to track your music',
                      color: const Color(0xFF1DB954),
                      onTap: () {
                        context.push('/link-spotify');
                      },
                    ),
                  const SizedBox(height: 24),

                  // Features (placeholders for future)
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  FeatureCard(
                    icon: Icons.music_note,
                    title: 'Top Tracks',
                    subtitle: 'View your most played tracks',
                    color: Colors.purple,
                    onTap: () {
                      // TODO: Navigate to top tracks
                    },
                  ),
                  const SizedBox(height: 12),

                  FeatureCard(
                    icon: Icons.album,
                    title: 'Top Artists',
                    subtitle: 'View your most listened artists',
                    color: Colors.orange,
                    onTap: () {
                      // TODO: Navigate to top artists
                    },
                  ),
                  const SizedBox(height: 12),

                  FeatureCard(
                    icon: Icons.graphic_eq,
                    title: 'Statistics',
                    subtitle: 'Detailed listening statistics',
                    color: Colors.blue,
                    onTap: () {
                      // TODO: Navigate to statistics
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
