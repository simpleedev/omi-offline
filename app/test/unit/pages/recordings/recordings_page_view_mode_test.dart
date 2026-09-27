import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omi/backend/preferences.dart';
import 'package:omi/models/recordings/recordings_models.dart';
import 'package:omi/pages/recordings/recordings_controller.dart';
import 'package:omi/pages/recordings/recordings_page.dart';
import 'package:omi/providers/device_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PageController extends RecordingsController {
  _PageController([List<MarkerConversation> initialMarkers = const []]) : markers = [...initialMarkers];

  final List<MarkerConversation> markers;

  @override
  void init() {}

  @override
  bool get isLoading => false;

  @override
  bool get syncServiceBusy => false;

  @override
  List<MarkerConversation> get markerConversations => markers;

  @override
  Future<void> deleteMarkerConversation(MarkerConversation marker) async {
    markers.remove(marker);
    notifyListeners();
  }
}

class _PageDevice extends ChangeNotifier implements DeviceProvider {
  @override
  bool isConnected = false;

  @override
  bool isConnecting = false;

  @override
  bool isBluetoothEnabled = true;

  @override
  bool isMuted = false;

  @override
  DateTime? muteSince;

  @override
  bool get isPriorityRecording => false;

  @override
  DateTime? recordingSince;

  @override
  int storageFullPercentage = -1;

  @override
  bool recordingModeMismatch = false;

  @override
  void dismissRecordingModeMismatch() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (_) async => null,
    );
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesUtil.init();
  });

  Widget page(_PageController controller, _PageDevice device) => ChangeNotifierProvider<DeviceProvider>.value(
        value: device,
        child: MaterialApp(home: RecordingsPage(controller: controller)),
      );

  testWidgets('empty Markers view can be selected and restored after reopening', (tester) async {
    final prefs = SharedPreferencesUtil();
    final device = _PageDevice();
    await tester.pumpWidget(page(_PageController(), device));

    expect(find.byTooltip('Toggle markers only'), findsOneWidget);
    expect(find.byTooltip('Hide ghosts'), findsOneWidget);
    expect(find.textContaining('No conversations found.'), findsOneWidget);

    await tester.tap(find.byTooltip('Toggle markers only'));
    await tester.pump();
    expect(find.textContaining('No marked recordings yet.'), findsOneWidget);
    expect(prefs.showMarkersOnly, isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(page(_PageController(), device));
    expect(find.textContaining('No marked recordings yet.'), findsOneWidget);
    expect(find.byTooltip('Toggle markers only'), findsOneWidget);
  });

  testWidgets('deleting the last marker keeps both saved view settings', (tester) async {
    final prefs = SharedPreferencesUtil()..showMarkersOnly = true;
    final marker = MarkerConversation(
      markerTime: DateTime(2026, 9, 26, 12),
      edlFile: File('unused-marker.edl'),
    );
    final controller = _PageController([marker]);
    final device = _PageDevice();
    await tester.pumpWidget(page(controller, device));

    await tester.tap(find.byTooltip('Hide ghosts'));
    await tester.pump();
    expect(find.byTooltip('Show ghosts'), findsOneWidget);
    expect(prefs.hideGhosts, isTrue);

    await tester.longPress(find.text('No audio attached'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(controller.markers, isEmpty);
    expect(find.textContaining('No marked recordings yet.'), findsOneWidget);
    expect(prefs.showMarkersOnly, isTrue);
    expect(prefs.hideGhosts, isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(page(_PageController(), device));
    expect(find.textContaining('No marked recordings yet.'), findsOneWidget);
    expect(find.byTooltip('Show ghosts'), findsOneWidget);
  });
}
