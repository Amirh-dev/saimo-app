import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/links/app_links.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app.ravi.saimo/links');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('hands over the launch link, then each link that arrives', () async {
    final pending = <String?>['saimo://payment-result?attemptID=a1'];
    var takes = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'takeLink');
      takes++;
      return pending.isEmpty ? null : pending.removeAt(0);
    });

    final links = <Uri>[];
    AppLinks.instance.listen(links.add);
    await pumpEventQueue();
    expect(links, [Uri.parse('saimo://payment-result?attemptID=a1')]);

    // MainActivity.onNewIntent, with the app already open.
    pending.add('saimo://payment-result?attemptID=a2');
    await messenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(const MethodCall('linkAvailable')),
      (_) {},
    );
    await pumpEventQueue();
    expect(links.last, Uri.parse('saimo://payment-result?attemptID=a2'));
    expect(links, hasLength(2));
    expect(takes, 2);
  });

  test('opening without a link reports nothing', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    final links = <Uri>[];
    AppLinks.instance.listen(links.add);
    await pumpEventQueue();
    expect(links, isEmpty);
  });
}
