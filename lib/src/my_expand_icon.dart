import 'package:flutter/material.dart';

/// A customizable expand/collapse icon widget that animates between expanded
/// and collapsed states.
///
/// This widget displays an icon that rotates smoothly when pressed, providing
/// visual feedback to the user.  It uses a [Material] widget with an
/// [InkWell] to handle tap events and provide a splash effect.  The appearance
/// and behavior of the icon can be customized through various properties.
///
/// {@template MyExpandIcon.example}
/// **Example:**
///
/// ```dart
/// MyExpandIcon(
///   isExpanded: _isExpanded,
///   onPressed: (isExpanded) {
///     setState(() {
///       _isExpanded = !isExpanded;
///     });
///   },
///   icon: Icons.expand_more,
///   turnsExpanded: 0.5, // Rotate 180 degrees when expanded
///   turnsCollapsed: 0.0, // No rotation when collapsed
///   color: Colors.blue,
///   hoverColor: Colors.lightBlue,
///   splashColor: Colors.blue.withOpacity(0.3),
/// )
/// ```
/// {@endtemplate}
class MyExpandIcon extends StatefulWidget {
  /// Whether the icon is currently in the expanded state.
  final bool isExpanded;

  /// Callback function triggered when the icon is pressed.
  ///
  /// Provides the new expanded state (the opposite of the current state).
  final ValueChanged<bool> onPressed;

  /// The icon to display. Defaults to `Icons.arrow_drop_down`.
  final IconData icon;

  /// The color of the icon. If [hoverColor] is specified, this color
  /// is used when the icon is not hovered. If not specified, defaults to the
  /// theme's `onSurface` color.
  final Color? color;

  /// The color of the icon when hovered. If not specified, defaults to [color].
  final Color? hoverColor;

  /// The splash color of the [InkWell].
  final Color? splashColor;

  /// The duration of the rotation animation. Defaults to 300 milliseconds.
  final Duration duration;

  /// The size of the icon. Defaults to 24.
  final double? size;

  /// The padding around the icon. Defaults to 8 on all sides.
  final EdgeInsetsGeometry? padding;

  /// The number of turns to rotate the icon when expanded. Defaults to 0.0
  /// (no rotation).  A value of 0.5 would rotate the icon 180 degrees.
  final double turnsExpanded;

  /// The number of turns to rotate the icon when collapsed. Defaults to -0.25
  /// (a slight counter-clockwise rotation).
  final double turnsCollapsed;

  /// Creates a [MyExpandIcon].
  const MyExpandIcon({
    super.key,
    this.isExpanded = false,
    required this.onPressed,
    this.icon = Icons.arrow_drop_down,
    this.color,
    this.hoverColor,
    this.splashColor,
    this.duration = const Duration(milliseconds: 300),
    this.size = 24,
    this.padding = const EdgeInsets.all(8),
    this.turnsExpanded = 0.0,
    this.turnsCollapsed = -0.25,
  });

  @override
  State<MyExpandIcon> createState() => _MyExpandIconState();
}

class _MyExpandIconState extends State<MyExpandIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final effectiveColor =
        _isHovered ? widget.hoverColor ?? widget.color ?? onSurfaceColor : widget.color ?? onSurfaceColor;

    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        cursor: SystemMouseCursors.click, // Indicate it's clickable
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          // Keep InkWell for the splash effect
          onTap: () => widget.onPressed(!widget.isExpanded),
          splashColor: widget.splashColor, // Use splashColor if provided
          customBorder: const CircleBorder(),
          child: AnimatedRotation(
            duration: widget.duration,
            curve: Curves.easeInOut,
            turns: widget.isExpanded ? widget.turnsExpanded : widget.turnsCollapsed, // Use the new properties
            child: Icon(
              widget.icon,
              color: effectiveColor,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}
