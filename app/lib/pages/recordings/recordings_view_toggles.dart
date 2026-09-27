import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Marker-only and ghost visibility controls for the recordings list.
///
/// These controls reflect user preferences even when the corresponding row
/// type has no entries. In marker-only mode the ghost preference remains
/// interactive, although the marker list itself never includes ghost rows.
class RecordingsViewToggles extends StatelessWidget {
  const RecordingsViewToggles({
    super.key,
    required this.markersOnly,
    required this.hideGhosts,
    required this.onMarkersOnlyChanged,
    required this.onHideGhostsChanged,
    this.showGhostToggle = true,
  });

  final bool markersOnly;
  final bool hideGhosts;
  final bool showGhostToggle;
  final ValueChanged<bool> onMarkersOnlyChanged;
  final ValueChanged<bool> onHideGhostsChanged;

  static const double _iconSize = 18;
  static const EdgeInsets _tapPad = EdgeInsets.symmetric(horizontal: 12, vertical: 10);

  Widget _tapGlyph({required Widget glyph, required VoidCallback onTap, required String tooltip}) => Tooltip(
        message: tooltip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(padding: _tapPad, child: glyph),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tapGlyph(
          tooltip: 'Toggle markers only',
          onTap: () => onMarkersOnlyChanged(!markersOnly),
          glyph: FaIcon(
            markersOnly ? FontAwesomeIcons.solidBookmark : FontAwesomeIcons.bookmark,
            size: _iconSize,
            color: markersOnly ? Colors.amber : Colors.white,
          ),
        ),
        if (showGhostToggle)
          _tapGlyph(
            tooltip: hideGhosts ? 'Show ghosts' : 'Hide ghosts',
            onTap: () => onHideGhostsChanged(!hideGhosts),
            glyph: FaIcon(
              FontAwesomeIcons.ghost,
              size: _iconSize,
              color: hideGhosts ? Colors.grey.shade600 : Colors.orange.shade300,
            ),
          ),
      ],
    );
  }
}
