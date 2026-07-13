import 'package:flutter/widgets.dart';

/// Global, app-wide record of what the user is currently looking at in chat.
///
/// The notification layer uses this to decide whether an incoming message
/// should surface a notification. A message is suppressed only when the user is
/// actively viewing that exact conversation in the foreground; in every other
/// situation (app backgrounded, on another screen, or on the contact list) a
/// notification is shown.
///
/// It also caches a small `userID -> display name` map so notifications can
/// show the sender's name, and the current user's id so we never notify the
/// user about their own messages.
class ActiveChatTracker {
  ActiveChatTracker._();

  static final ActiveChatTracker instance = ActiveChatTracker._();

  /// The other participant's user id for the conversation currently open on
  /// screen, or `null` when no conversation is open.
  String? _openConversationUserID;

  /// Whether the app is currently in the foreground.
  bool _appInForeground = true;

  /// The signed-in user's id, used to ignore self-sent messages.
  String? _currentUserID;

  final Map<String, String> _displayNames = <String, String>{};

  String? get currentUserID => _currentUserID;
  set currentUserID(String? value) {
    if (value == null || value.isEmpty) return;
    _currentUserID = value;
  }

  set appInForeground(bool value) => _appInForeground = value;

  /// Marks a conversation (identified by the other user's id) as open.
  void openConversation(String? otherUserID) {
    _openConversationUserID = otherUserID;
  }

  /// Clears the currently open conversation.
  void closeConversation() {
    _openConversationUserID = null;
  }

  /// Merges known contact display names so notifications can name the sender.
  void cacheDisplayNames(Map<String, String> namesByUserID) {
    namesByUserID.forEach((id, name) {
      if (id.isEmpty || name.trim().isEmpty) return;
      _displayNames[id] = name;
    });
  }

  String? displayNameFor(String userID) => _displayNames[userID];

  /// Whether an incoming message from [senderID] should be shown as a
  /// notification given the current app/chat state.
  bool shouldNotifyForMessageFrom(String senderID) {
    // Never notify about our own messages echoed back over the socket.
    if (_currentUserID != null && senderID == _currentUserID) return false;

    // Suppress only when the user is actively reading that exact conversation.
    final isViewingSender = _appInForeground &&
        _openConversationUserID != null &&
        _openConversationUserID == senderID;
    return !isViewingSender;
  }
}

/// Convenience mixin for a screen that represents an open conversation.
///
/// Not required, but documents intent where used.
mixin TracksOpenConversation<T extends StatefulWidget> on State<T> {
  void markConversationOpen(String? otherUserID) =>
      ActiveChatTracker.instance.openConversation(otherUserID);

  void markConversationClosed() =>
      ActiveChatTracker.instance.closeConversation();
}
