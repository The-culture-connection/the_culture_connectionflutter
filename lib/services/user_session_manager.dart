import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UserSessionManager - Equivalent to iOS UserSessionManager
class UserSessionManager extends StateNotifier<UserSessionState> {
  UserSessionManager() : super(const UserSessionState());

  /// Start registration flow
  void startRegistrationFlow() {
    state = state.copyWith(isInRegistrationFlow: true);
  }

  /// End registration flow
  void endRegistrationFlow() {
    state = state.copyWith(isInRegistrationFlow: false);
  }

  /// Refresh authentication state
  void refreshAuthState() {
    // This would typically check Firebase Auth state
    // For now, we'll just maintain the current state
  }
}

/// User session state
class UserSessionState {
  final bool isInRegistrationFlow;

  const UserSessionState({
    this.isInRegistrationFlow = false,
  });

  UserSessionState copyWith({
    bool? isInRegistrationFlow,
  }) {
    return UserSessionState(
      isInRegistrationFlow: isInRegistrationFlow ?? this.isInRegistrationFlow,
    );
  }
}

/// Provider for UserSessionManager
final userSessionManagerProvider = StateNotifierProvider<UserSessionManager, UserSessionState>(
  (ref) => UserSessionManager(),
);