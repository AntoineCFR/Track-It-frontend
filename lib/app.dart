import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_it/screens/login_screen.dart';
import 'package:track_it/screens/home_screen.dart';
import 'package:track_it/screens/spotify_link_screen.dart';
import 'package:track_it/services/auth_service.dart';

class TrackItApp extends StatelessWidget {
  const TrackItApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final isLoggedIn = authService.currentUser != null;
        final location = state.uri.path;
        
        if (!isLoggedIn && location != '/login') {
          return '/login';
        }
        
        if (isLoggedIn && location == '/login') {
          return '/home';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/link-spotify',
          builder: (context, state) => const SpotifyLinkScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Track It',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DB954), // Spotify Green
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DB954),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
      routerConfig: router,
    );
  }
}
