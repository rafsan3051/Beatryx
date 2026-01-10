import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  String _displayName = 'User';
  String? _photoUrl;
  bool _isSignedIn = false;
  bool _isLocalPhoto = false;

  String get displayName => _displayName;
  String? get photoUrl => _photoUrl;
  bool get isSignedIn => _isSignedIn;
  bool get isLocalPhoto => _isLocalPhoto;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ImagePicker _picker = ImagePicker();

  UserProvider() {
    _loadLocalProfile();
  }

  Future<void> _loadLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _displayName = prefs.getString('display_name') ?? 'User';
    _photoUrl = prefs.getString('photo_url');
    _isLocalPhoto = prefs.getBool('is_local_photo') ?? false;
    notifyListeners();
  }

  Future<void> setLocalProfile(String name, String? photoPath) async {
    _displayName = name;
    if (photoPath != null) {
      _photoUrl = photoPath;
      _isLocalPhoto = true;
    }
    _isSignedIn = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('display_name', name);
    if (photoPath != null) {
      await prefs.setString('photo_url', photoPath);
      await prefs.setBool('is_local_photo', true);
    }
    notifyListeners();
  }

  Future<void> pickLocalAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await setLocalProfile(_displayName, image.path);
      }
    } catch (e) {
      debugPrint('Error picking avatar: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        _displayName = account.displayName ?? 'User';
        _photoUrl = account.photoUrl;
        _isSignedIn = true;
        _isLocalPhoto = false;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('display_name', _displayName);
        if (_photoUrl != null) await prefs.setString('photo_url', _photoUrl!);
        await prefs.setBool('is_local_photo', false);
        
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Google Sign-In error: $error');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _isSignedIn = false;
    _isLocalPhoto = false;
    _photoUrl = null;
    _displayName = 'User';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
}
