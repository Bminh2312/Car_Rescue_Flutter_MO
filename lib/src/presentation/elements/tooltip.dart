import 'package:flutter/material.dart';

class TapTooltip extends StatefulWidget {
  final Widget child;
  final String message;

  const TapTooltip({Key? key, required this.child, required this.message})
      : super(key: key);

  @override
  _TapTooltipState createState() => _TapTooltipState();
}

class _TapTooltipState extends State<TapTooltip> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 20), // Offset can be adjusted
          child: Material(
            elevation: 4.0,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(widget.message),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () => _showOverlay(context),
        child: widget.child,
      ),
    );
  }
}
