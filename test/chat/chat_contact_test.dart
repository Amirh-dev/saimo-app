import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/chat/chat_models.dart';

void main() {
  test('uses username instead of a phone-number fallback', () {
    const contact = ChatContact(
      friendshipID: 'friendship-1',
      targetUserID: 'user-1',
      status: 'ACCEPTED',
      isPending: false,
      targetUsername: 'ali_rezaei',
    );

    expect(contact.displayName, '@ali_rezaei');
    expect(contact.usernameLabel, '@ali_rezaei');
  });

  test('keeps the full name primary and exposes the username label', () {
    const contact = ChatContact(
      friendshipID: 'friendship-1',
      targetUserID: 'user-1',
      status: 'ACCEPTED',
      isPending: false,
      targetFullName: 'علی رضایی',
      targetUsername: 'ali_rezaei',
    );

    expect(contact.displayName, 'علی رضایی');
    expect(contact.hasFullName, isTrue);
    expect(contact.usernameLabel, '@ali_rezaei');
  });
}
