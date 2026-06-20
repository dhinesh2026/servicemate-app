import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  
  User? get user => _user;
  
  // Initialize with default user data (in real app, fetch from API)
  void initializeUser() {
    _user = User(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+1234567890',
      profileImageUrl: 'https://i.pravatar.cc/150?img=3',
      profession: 'Software Developer',
      bio: 'Hello! I am a passionate developer.',
    );
    notifyListeners();
  }
  
  // Update user profile
  void updateProfile(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
    // In a real app, you would also save to backend here
  }
}