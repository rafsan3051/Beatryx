import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
    
    // Safety check: if local file is missing, reset it to prevent crashes
    if (_photoUrl != null && !_photoUrl!.startsWith('http')) {
      if (!File(_photoUrl!).existsSync()) {
        _photoUrl = null;
        _isLocalPhoto = false;
      }
    }
    
    notifyListeners();
  }

  Future<void> setLocalProfile(String name, String? photoPath) async {
    _displayName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('display_name', name);

    if (photoPath != null && !photoPath.startsWith('http')) {
      // Copy image to permanent app directory to prevent it from disappearing
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(photoPath);
        final permanentPath = path.join(appDir.path, 'profile_$fileName');
        
        final File tempFile = File(photoPath);
        if (tempFile.existsSync()) {
          await tempFile.copy(permanentPath);
          _photoUrl = permanentPath;
          _isLocalPhoto = true;
          await prefs.setString('photo_url', permanentPath);
          await prefs.setBool('is_local_photo', true);
        }
      } catch (e) {
        debugPrint('Error saving permanent profile pic: $e');
      }
    }
    
    _isSignedIn = false;
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
    // Don't use clear() as it wipes app settings, just remove user specific keys
    await prefs.remove('display_name');
    await prefs.remove('photo_url');
    await prefs.remove('is_local_photo');
    
    notifyListeners();
  }
}
