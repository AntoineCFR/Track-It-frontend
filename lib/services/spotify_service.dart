import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:track_it/services/auth_service.dart';

/// Configuration for Spotify OAuth
class SpotifyConfig {
  static const String clientId = 'YOUR_SPOTIFY_CLIENT_ID';
  
  // Official Spotify redirect URIs for mobile apps
  // These are pre-approved by Spotify for development
  static const String redirectUriAndroid = 'com.spotify.sdk://auth';
  static const String redirectUriIOS = 'spotify-ios-quick-start://spotify-callback';
  
  // Get the appropriate redirect URI based on platform
  static String get redirectUri {
    // Import dart:io for platform detection
    // This will be handled in the service
    return ''; // Will be set dynamically
  }
  
  static const List<String> scopes = [
    'user-read-private',
    'user-read-email',
    'user-top-read',
    'user-library-read',
    'user-read-recently-played',
    'user-read-playback-state',
  ];
  
  static const String authorizationEndpoint = 'https://accounts.spotify.com/authorize';
  static const String tokenEndpoint = 'https://accounts.spotify.com/api/token';
}

class SpotifyService with ChangeNotifier {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  // Get the appropriate redirect URI based on platform
  String get _redirectUri {
    if (Platform.isIOS) {
      return SpotifyConfig.redirectUriIOS;
    } else if (Platform.isAndroid) {
      return SpotifyConfig.redirectUriAndroid;
    }
    // Default for web or other platforms
    return SpotifyConfig.redirectUriAndroid;
  }
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _authCode;
  bool _isLinked = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get authCode => _authCode;
  bool get isLinked => _isLinked;
  String get currentRedirectUri => _redirectUri;

  // Generate a random string for code verifier
  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(64, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  // Generate code challenge from code verifier
  String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Start Spotify OAuth PKCE flow
  Future<bool> linkSpotifyAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Generate PKCE code verifier and challenge
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);
      
      // Use the platform-appropriate redirect URI
      final redirectUri = _redirectUri;
      
      // Build the authorization request
      final request = AuthorizationTokenRequest(
        SpotifyConfig.clientId,
        redirectUri,
        discoveryUrl: null,
        scopes: SpotifyConfig.scopes,
        codeVerifier: codeVerifier,
        // Additional parameters for Spotify PKCE
        additionalParameters: {
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'response_type': 'code',
        },
      );

      // Use authorize instead of authorizeAndExchangeCode to get the auth code
      final result = await _appAuth.authorize(request);

      if (result != null) {
        // Extract the authorization code from the response
        _authCode = result.authorizationCode;
        
        if (_authCode != null) {
          // Save the code to Firestore with user ID
          await _saveCodeToFirestore(_authCode!);
          _isLinked = true;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = 'Authorization was cancelled or failed';
        notifyListeners();
        return false;
      }
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to link Spotify: ${e.toString()}';
      debugPrint('Spotify auth error: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }

  /// Alternative method: Launch Spotify auth in browser and handle callback
  /// This uses the platform-appropriate redirect URI
  Future<void> startSpotifyAuthFlow() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);
      final redirectUri = _redirectUri;
      
      // Build the authorization URL
      final authUrl = Uri(
        scheme: 'https',
        host: 'accounts.spotify.com',
        path: '/authorize',
        queryParameters: {
          'client_id': SpotifyConfig.clientId,
          'response_type': 'code',
          'redirect_uri': redirectUri,
          'code_challenge_method': 'S256',
          'code_challenge': codeChallenge,
          'scope': SpotifyConfig.scopes.join(' '),
          'state': codeVerifier, // Using codeVerifier as state for simplicity
        },
      ).toString();

      debugPrint('Spotify auth URL: $authUrl');
      debugPrint('Using redirect URI: $redirectUri');

      // Use appauth to handle the OAuth flow
      final result = await _appAuth.authorize(
        AuthorizationRequest(
          SpotifyConfig.clientId,
          redirectUri,
          discoveryUrl: null,
          scopes: SpotifyConfig.scopes,
          codeVerifier: codeVerifier,
          additionalParameters: {
            'code_challenge': codeChallenge,
            'code_challenge_method': 'S256',
          },
        ),
      );

      if (result != null) {
        // Extract code from the authorization response
        _authCode = result.authorizationCode;
        
        if (_authCode != null) {
          await _saveCodeToFirestore(_authCode!);
          _isLinked = true;
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to start Spotify auth: ${e.toString()}';
      debugPrint('Spotify auth flow error: ${e.toString()}');
      notifyListeners();
    }
  }

  /// Save the authorization code to Firestore
  Future<bool> _saveCodeToFirestore(String code) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        _errorMessage = 'No user is currently logged in';
        return false;
      }

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'spotifyCode': code,
        'spotifyLinked': true,
        'spotifyCodeUpdatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to save Spotify code: ${e.toString()}';
      return false;
    }
  }

  /// Check if user has already linked Spotify
  Future<bool> checkSpotifyLinked() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _isLinked = doc['spotifyLinked'] ?? false;
        _authCode = doc['spotifyCode'];
        notifyListeners();
        return _isLinked;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get the stored Spotify code for the current user
  Future<String?> getStoredSpotifyCode() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc['spotifyCode'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear the Spotify link
  Future<void> unlinkSpotify() async {
    _isLoading = true;
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'spotifyCode': FieldValue.delete(),
          'spotifyLinked': false,
        });
        _authCode = null;
        _isLinked = false;
      }
    } catch (e) {
      _errorMessage = 'Failed to unlink Spotify: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
  }
}
