import 'package:flutter/foundation.dart';

class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;

  int get currentPage => _currentPage;

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }
}
