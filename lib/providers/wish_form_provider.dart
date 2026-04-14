import 'package:flutter/foundation.dart';
import '../models/wish.dart';

class WishFormProvider extends ChangeNotifier {
  WishPriority priority = WishPriority.medium;
  String? categoryId;
  DateTime? deadline;

  void setPriority(WishPriority value) {
    priority = value;
    notifyListeners();
  }

  void setCategoryId(String? value) {
    categoryId = value;
    notifyListeners();
  }

  void setDeadline(DateTime? value) {
    deadline = value;
    notifyListeners();
  }

  void loadFromWish(Wish wish) {
    priority = wish.priority;
    categoryId = wish.categoryId;
    deadline = wish.deadline;
    notifyListeners();
  }

  void reset() {
    priority = WishPriority.medium;
    categoryId = null;
    deadline = null;
    if (hasListeners) notifyListeners();
  }
}
