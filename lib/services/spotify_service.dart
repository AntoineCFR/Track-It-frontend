import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:track_it/services/auth_service.dart';

/// Configuration for Spotify OAuth
class SpotifyConfig {
  static const String clientId = 'YOUR_SPOTIFY_CLIENT_ID';
  static const String redirectUri = 'com.AntoineCFR.trackit:/callback';
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
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _authCode;
  bool _isLinked = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get authCode => _authCode;
  bool get isLinked => _isLinked;

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
      
      // Store code verifier temporarily (in a real app, use secure storage)
      // For this demo, we'll pass it through the auth request
      
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          SpotifyConfig.clientId,
          SpotifyConfig.redirectUri,
          discoveryUrl: null,
          scopes: SpotifyConfig.scopes,
          codeVerifier: codeVerifier,
          // Additional parameters for Spotify
          additionalParameters: {
            'code_challenge': codeChallenge,
            'code_challenge_method': 'S256',
            'response_type': 'code',
          },
        ),
      );

      if (result != null) {
        // Extract the authorization code from the response
        // The code is in the authorization response
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
      notifyListeners();
      return false;
    }
  }

  /// Alternative method: Launch Spotify auth in browser and handle callback
  Future<void> startSpotifyAuthFlow() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);
      
      // Build the authorization URL
      final authUrl = Uri(
        scheme: 'https',
        host: 'accounts.spotify.com',
        path: '/authorize',
        queryParameters: {
          'client_id': SpotifyConfig.clientId,
          'response_type': 'code',
          'redirect_uri': SpotifyConfig.redirectUri,
          'code_challenge_method': 'S256',
          'code_challenge': codeChallenge,
          'scope': SpotifyConfig.scopes.join(' '),
          'state': codeVerifier, // Using codeVerifier as state for simplicity
        },
      ).toString();

      // Use url_launcher to open the URL in browser
      // In a real app, you'd use a WebView or custom tabs
      // For now, we'll use the appauth package which handles this
      
      final result = await _appAuth.authorize(
        AuthorizationRequest(
          SpotifyConfig.clientId,
          SpotifyConfig.redirectUri,
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
        // The code is in the authorizationCode field
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
