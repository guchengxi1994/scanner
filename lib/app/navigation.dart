import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNavigation extends Notifier<int> {
  @override
  int build() => 0;

  void goTo(int index) => state = index;
}

final appNavigationProvider =
    NotifierProvider<AppNavigation, int>(AppNavigation.new);
