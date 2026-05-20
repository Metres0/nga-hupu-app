import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionProvider extends ChangeNotifier {
  Set<int> _subscribed = {};
  static const _key = 'nga_subscribed_fids';

  Set<int> get subscribed => _subscribed;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _subscribed = raw.map((s) => int.parse(s)).toSet();
    notifyListeners();
  }

  bool isSubscribed(int fid) => _subscribed.contains(fid);

  Future<void> toggle(int fid) async {
    if (_subscribed.contains(fid)) {
      _subscribed.remove(fid);
    } else {
      _subscribed.add(fid);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _subscribed.map((e) => e.toString()).toList());
    notifyListeners();
  }
}
