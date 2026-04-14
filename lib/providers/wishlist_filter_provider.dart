import 'package:flutter/foundation.dart';
import '../models/wish.dart';

enum WishSortOrder {
  dateDesc,
  dateAsc,
  priorityHigh,
  priorityLow,
  deadlineAsc,
  titleAz,
}

class WishlistFilterProvider extends ChangeNotifier {
  WishStatus? _statusFilter;
  WishPriority? _priorityFilter;
  WishSortOrder _sortOrder = WishSortOrder.dateDesc;
  String _searchQuery = '';
  bool _sheetOpen = false;

  WishStatus? get statusFilter => _statusFilter;
  WishPriority? get priorityFilter => _priorityFilter;
  WishSortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;
  bool get sheetOpen => _sheetOpen;

  void setStatusFilter(WishStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(WishPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setSortOrder(WishSortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  void setSheetOpen(bool value) {
    if (_sheetOpen == value) return;
    _sheetOpen = value;
    notifyListeners();
  }

  List<Wish> applyAll(List<Wish> wishes) {
    var result = wishes.where((w) {
      if (_statusFilter != null && w.status != _statusFilter) return false;
      if (_priorityFilter != null && w.priority != _priorityFilter)
        return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!w.title.toLowerCase().contains(q) &&
            !(w.description?.toLowerCase().contains(q) ?? false) &&
            !w.tags.any((t) => t.toLowerCase().contains(q))) {
          return false;
        }
      }
      return true;
    }).toList();

    switch (_sortOrder) {
      case WishSortOrder.dateDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case WishSortOrder.dateAsc:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case WishSortOrder.priorityHigh:
        result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      case WishSortOrder.priorityLow:
        result.sort((a, b) => a.priority.index.compareTo(b.priority.index));
      case WishSortOrder.deadlineAsc:
        result.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
      case WishSortOrder.titleAz:
        result.sort((a, b) => a.title.compareTo(b.title));
    }
    return result;
  }
}
