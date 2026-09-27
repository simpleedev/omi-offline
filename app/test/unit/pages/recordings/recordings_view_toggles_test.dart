import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omi/pages/recordings/recordings_view_toggles.dart';

void main() {
  testWidgets('both controls remain available with no corresponding rows', (tester) async {
    var markersOnly = false;
    var hideGhosts = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => RecordingsViewToggles(
            markersOnly: markersOnly,
            hideGhosts: hideGhosts,
            onMarkersOnlyChanged: (value) => setState(() => markersOnly = value),
            onHideGhostsChanged: (value) => setState(() => hideGhosts = value),
          ),
        ),
      ),
    ));

    expect(find.byTooltip('Toggle markers only'), findsOneWidget);
    expect(find.byTooltip('Hide ghosts'), findsOneWidget);

    await tester.tap(find.byTooltip('Toggle markers only'));
    await tester.pump();
    expect(markersOnly, isTrue);

    // Marker mode does not disable the ghost preference. With no ghost rows,
    // toggling it changes the saved/displayed setting but has no rows to affect.
    await tester.tap(find.byTooltip('Hide ghosts'));
    await tester.pump();
    expect(markersOnly, isTrue);
    expect(hideGhosts, isTrue);
    expect(find.byTooltip('Show ghosts'), findsOneWidget);
  });

  testWidgets('ghost control can be omitted during ghost multi-select', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RecordingsViewToggles(
          markersOnly: false,
          hideGhosts: false,
          showGhostToggle: false,
          onMarkersOnlyChanged: (_) {},
          onHideGhostsChanged: (_) {},
        ),
      ),
    ));

    expect(find.byTooltip('Toggle markers only'), findsOneWidget);
    expect(find.byTooltip('Hide ghosts'), findsNothing);
  });
}
