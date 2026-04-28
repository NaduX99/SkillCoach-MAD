import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionState {
  final Duration elapsed;
  final bool shouldShowRestAlert;
  final DateTime startTime;

  SessionState({
    required this.elapsed,
    required this.shouldShowRestAlert,
    required this.startTime,
  });

  SessionState copyWith({
    Duration? elapsed,
    bool? shouldShowRestAlert,
    DateTime? startTime,
  }) {
    return SessionState(
      elapsed: elapsed ?? this.elapsed,
      shouldShowRestAlert: shouldShowRestAlert ?? this.shouldShowRestAlert,
      startTime: startTime ?? this.startTime,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  Timer? _timer;
  static const int restIntervalMinutes = 30;

  SessionNotifier()
      : super(SessionState(
          elapsed: Duration.zero,
          shouldShowRestAlert: false,
          startTime: DateTime.now(),
        )) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    // Reverted to 1 second for "live" feel as per user request.
    // Optimization: Listeners should use selectors to avoid unnecessary rebuilds.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newElapsed = DateTime.now().difference(state.startTime);
      
      bool notify = false;
      final prevMinutes = state.elapsed.inMinutes;
      final currentMinutes = newElapsed.inMinutes;

      // Check for rest alert every 30 minutes
      if (currentMinutes > 0 && 
          currentMinutes % restIntervalMinutes == 0 && 
          currentMinutes != prevMinutes) {
        notify = true;
      }

      state = state.copyWith(
        elapsed: newElapsed,
        shouldShowRestAlert: notify,
      );
    });
  }

  void dismissAlert() {
    state = state.copyWith(shouldShowRestAlert: false);
  }

  void resetSession() {
    state = SessionState(
      elapsed: Duration.zero,
      shouldShowRestAlert: false,
      startTime: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});
