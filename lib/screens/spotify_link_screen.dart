import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_it/services/spotify_service.dart';

class SpotifyLinkScreen extends StatefulWidget {
  const SpotifyLinkScreen({super.key});

  @override
  State<SpotifyLinkScreen> createState() => _SpotifyLinkScreenState();
}

class _SpotifyLinkScreenState extends State<SpotifyLinkScreen> {
  @override
  void initState() {
    super.initState();
    // Check if already linked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAlreadyLinked();
    });
  }

  Future<void> _checkAlreadyLinked() async {
    final spotifyService = Provider.of<SpotifyService>(context, listen: false);
    final isLinked = await spotifyService.checkSpotifyLinked();
    
    if (isLinked && mounted) {
      // Already linked, go back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spotify is already linked!')),
        );
        context.pop();
      }
    }
  }

  Future<void> _linkSpotify() async {
    final spotifyService = Provider.of<SpotifyService>(context, listen: false);
    
    final success = await spotifyService.linkSpotifyAccount();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Spotify linked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Small delay to show the snackbar before navigating back
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.pop();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(spotifyService.errorMessage ?? 'Failed to link Spotify'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotifyService = Provider.of<SpotifyService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Spotify'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spotify Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.music_note,
                size: 80,
                color: Color(0xFF1DB954),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            const Text(
              'Connect to Spotify',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'To track your music statistics, we need to connect to your Spotify account. '
              'This will allow us to access your listening history and preferences.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Permissions List
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We will access:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ListTile(
                    leading: Icon(Icons.check, color: Colors.green, size: 20),
                    title: Text('Your profile information'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.check, color: Colors.green, size: 20),
                    title: Text('Your email address'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.check, color: Colors.green, size: 20),
                    title: Text('Your top artists and tracks'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.check, color: Colors.green, size: 20),
                    title: Text('Your recently played tracks'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Connect Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: spotifyService.isLoading ? null : _linkSpotify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: spotifyService.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.music_note),
                          SizedBox(width: 8),
                          Text(
                            'Connect to Spotify',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Cancel Button
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            // Error Message
            if (spotifyService.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  spotifyService.errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
