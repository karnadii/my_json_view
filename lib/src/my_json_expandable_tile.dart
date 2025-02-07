import 'package:flutter/material.dart';

import 'const.dart';
import 'my_expand_icon.dart';
import 'my_json_view_controller.dart';

/// A widget that displays a single expandable node in the JSON tree.
///
/// This widget is used internally by [MyJsonView] to build the hierarchical
/// tree structure.  It handles the expand/collapse logic, displays the
/// expand/collapse icon, and renders the header and children of a JSON node.
/// The appearance of the tile (including the indent guide) is controlled by
/// the [MyJsonViewStyle] passed to the [MyJsonView].
///
/// The tile listens to changes in a [MyJsonViewController] (if provided) to
/// automatically update its expanded/collapsed state.  The root tile does
/// *not* listen to the controller; its expansion state is controlled
/// directly by the user.
///
/// {@template JsonExpandableTile.example}
/// **Example:**
///
/// ```dart
/// // Typically, you wouldn't use JsonExpandableTile directly, but rather
/// // through MyJsonView.  This example shows how it's used internally:
///
/// final controller = MyJsonViewController();
///
/// JsonExpandableTile(
///   headerExpanded: Text('Expanded Header'),
///   headerCollapsed: Text('Collapsed Header'),
///   controller: controller,
///   children: [
///     Text('Child 1'),
///     Text('Child 2'),
///   ],
///   isRoot: false, // Set to true for the root node
///   showIndentGuide: true,
///   childrenLength: 2,
/// )
/// ```
/// {@endtemplate}
class JsonExpandableTile extends StatefulWidget {
  /// Creates a [JsonExpandableTile].
  ///
  /// The [headerExpanded], [headerCollapsed], [children], [isRoot], and
  /// [childrenLength] arguments are required. The [controller] is optional
  /// and should only be provided for non-root tiles.  The [showIndentGuide]
  /// flag controls the visibility of the indent guide.
  const JsonExpandableTile({
    super.key,
    required this.headerExpanded,
    required this.headerCollapsed,
    this.indent,
    this.footer,
    this.controller,
    required this.children,
    required this.isRoot,
    this.showIndentGuide = true,
    required this.childrenLength,
  });

  /// The widget to display as the header when the tile is expanded.
  final Widget headerExpanded;

  /// The widget to display as the header when the tile is collapsed.
  final Widget headerCollapsed;

  /// The indentation level of this tile.
  ///
  /// Used to calculate the position of the indent guide.
  final double? indent;

  /// An optional widget to display at the bottom of the tile's children.
  ///
  /// This is typically used to show the closing bracket of an object or array.
  final Widget? footer;

  /// The controller that manages the expansion state of the JSON view.
  ///
  /// If provided, the tile will listen to changes in the controller and
  /// automatically update its expanded/collapsed state.  The root tile
  /// should *not* have a controller.
  final MyJsonViewController? controller;

  /// The child widgets to display when the tile is expanded.
  final List<Widget> children;

  /// Whether this tile represents the root node of the JSON tree.
  ///
  /// The root tile does not listen to the controller for expansion state
  /// changes.
  final bool isRoot;

  /// The number of children.
  final int childrenLength;

  /// Whether to show the vertical indent guide line.
  ///
  /// This is usually controlled by the [MyJsonViewStyle.showIndentGuide]
  /// property.
  final bool showIndentGuide;

  @override
  State<JsonExpandableTile> createState() => _JsonExpandableTileState();
}

class _JsonExpandableTileState extends State<JsonExpandableTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.childrenLength > 0 ? true : false;
    if (widget.controller != null && !widget.isRoot) {
      _isExpanded = widget.controller!.isExpanded;
    }
    //Listen to controller changes if it is not root
    if (!widget.isRoot && widget.controller != null) {
      widget.controller!.addListener(_handleControllerChange);
    }
  }

  @override
  void didUpdateWidget(covariant JsonExpandableTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Remove listener from the old controller
    if (oldWidget.controller != null && !oldWidget.isRoot) {
      oldWidget.controller!.removeListener(_handleControllerChange);
    }

    //If the controller changed, update the expanded state.
    if (widget.controller != null && !widget.isRoot) {
      _isExpanded = widget.controller!.isExpanded;
    }

    // Add listener to the new controller
    if (widget.controller != null && !widget.isRoot) {
      widget.controller!.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    //Always remove listener on dispose.
    if (widget.controller != null && !widget.isRoot) {
      widget.controller!.removeListener(_handleControllerChange);
    }
    super.dispose();
  }

  /// Handles changes in the [MyJsonViewController].
  ///
  /// This method is called whenever the controller's state changes.  It
  /// updates the `_isExpanded` state of the tile if the controller's
  /// `isExpanded` property differs from the local state, *and* if this
  /// tile is not the root tile.  This ensures that non-root tiles
  /// automatically expand and collapse in response to controller actions.
  void _handleControllerChange() {
    // Only update if the controller's expanded state differs from the local state.
    // This prevents unnecessary rebuilds.
    if (widget.controller != null &&
        widget.controller!.isExpanded != _isExpanded &&
        !widget.isRoot) {
      setState(() {
        _isExpanded = widget.controller!.isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute an effective painter color: if the tile is expanded
    // and the user wants to show the indent guide, use the theme color;
    // otherwise make it transparent.
    final effectiveColor =
        (_isExpanded && widget.showIndentGuide && widget.childrenLength > 0)
            ? Theme.of(context).colorScheme.outlineVariant
            : Colors.transparent;
    final Widget header =
        _isExpanded ? widget.headerExpanded : widget.headerCollapsed;
    return CustomPaint(
      painter: _MyIndentGuidePainter(
        color: effectiveColor,
        strokeWidth: 1.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Row(
                children: [
                  widget.childrenLength > 0
                      ? MyExpandIcon(
                          onPressed: (_) => _toggleExpanded(),
                          size: kExpandIconSize,
                          isExpanded: _isExpanded,
                          padding: EdgeInsets.zero,
                        )
                      : const SizedBox(
                          width: kExpandIconSize,
                          height: kExpandIconSize,
                        ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: header,
                  ),
                ],
              ),
              // The InkWell overlay is transparent and covers the whole header row.
              // It toggles expansion when tapped.
              Positioned.fill(
                child: InkWell(
                  onTap: _toggleExpanded,
                  // Set splashColor to transparent if you don’t want a visual effect
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ),
            ],
          ),
          if (_isExpanded && widget.childrenLength > 0)
            Padding(
              padding: EdgeInsets.only(left: widget.indent ?? kIndent),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    widget.children.length + (widget.footer != null ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == widget.children.length &&
                      widget.footer != null) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: widget.footer!,
                    );
                  }
                  return widget.children[index];
                },
              ),
            )
        ],
      ),
    );
  }

  /// Toggles the expanded state of the tile.
  ///
  /// This method is called when the user taps the expand/collapse icon or
  /// the header.
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}

/// Custom painter to draw the indent guide (bracket lines).
///
/// The [color] determines whether or not the guide is visible.  If the
/// color is transparent, the painter effectively does nothing.  The
/// [strokeWidth] controls the thickness of the lines.
class _MyIndentGuidePainter extends CustomPainter {
  /// Creates a [_MyIndentGuidePainter].
  ///
  /// The [color] is required and determines the color of the lines.  The
  /// [strokeWidth] defaults to 1.0.
  _MyIndentGuidePainter({
    required this.color,
    this.strokeWidth = 1.0,
  });

  /// The color of the indent guide lines.
  final Color color;

  /// The thickness of the indent guide lines.
  final double strokeWidth;

  /// The length of the top horizontal stroke of the indent guide.
  static const double topStrokeLength = 2;

  /// The vertical offset of the bottom horizontal stroke of the indent guide.
  static const double bottomOffset = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    // Draw top horizontal line
    canvas.drawLine(
      const Offset(0, kIndent),
      const Offset(topStrokeLength, kIndent),
      paint,
    );
    // Draw vertical line
    canvas.drawLine(
      const Offset(0, bottomOffset),
      Offset(0, size.height - bottomOffset),
      paint,
    );
    // Draw bottom horizontal line
    canvas.drawLine(
      Offset(0, size.height - bottomOffset),
      Offset(kIndent, size.height - bottomOffset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
