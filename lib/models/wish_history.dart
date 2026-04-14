class WishHistory {
  final String id;
  final String wishId;
  final String changeDescription;
  final DateTime changedAt;

  WishHistory({
    required this.id,
    required this.wishId,
    required this.changeDescription,
    required this.changedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'wish_id': wishId,
    'change_description': changeDescription,
    'changed_at': changedAt.toIso8601String(),
  };

  factory WishHistory.fromMap(Map<String, dynamic> map) => WishHistory(
    id: map['id'],
    wishId: map['wish_id'],
    changeDescription: map['change_description'],
    changedAt: DateTime.parse(map['changed_at']),
  );
}
