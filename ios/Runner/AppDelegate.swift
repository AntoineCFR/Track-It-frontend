import UIKit
import Flutter
import Firebase
import GoogleSignIn

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase configuration
    FirebaseApp.configure()
    
    // Google Sign In configuration
    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
      if error != nil || user == nil {
        // No previous sign in
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle deep links for Spotify OAuth callback
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Handle Google Sign In
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    
    // Handle Spotify OAuth callback - Official schemes
    let spotifySchemes = ["spotify-ios-quick-start", "com.spotify.sdk", "com.AntoineCFR.trackit"]
    if spotifySchemes.contains(url.scheme) {
      // The AppAuth plugin will handle this
      return super.application(app, open: url, options: options)
    }
    
    return super.application(app, open: url, options: options)
  }

  // For iOS 9+ 
  override func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
  ) -> Bool {
    // Handle Google Sign In
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    
    // Handle Spotify OAuth callback - Official schemes
    let spotifySchemes = ["spotify-ios-quick-start", "com.spotify.sdk", "com.AntoineCFR.trackit"]
    if spotifySchemes.contains(url.scheme) {
      return super.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    return super.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
