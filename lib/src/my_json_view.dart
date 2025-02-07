import 'package:flutter/material.dart';

import 'const.dart';
import 'my_json_view_style.dart';
import 'my_json_expandable_tile.dart';
import 'my_json_view_controller.dart';

/// A Flutter widget for displaying JSON data in a user-friendly, expandable,
/// and searchable tree view.
///
/// `MyJsonView` takes JSON data (either as a `String`, `Map`, or `List`) and
/// renders it as an interactive tree.  Users can expand and collapse nodes,
/// search for specific keys or values, and customize the appearance using
/// [MyJsonViewStyle].
///
/// The widget uses a [MyJsonViewController] to manage the expansion state and
/// search query.  You can either provide your own controller (e.g., using
/// `Provider`) or let the widget create a default one internally.
///
/// The search functionality highlights matches within the JSON tree. The
/// highlighting is applied to both keys and values.
///
/// **Example:**
///
/// ```dart
/// // Simple usage with a JSON string:
/// MyJsonView.string(
///   jsonString: '{ "name": "John Doe", "age": 30 }',
/// )
///
/// // Usage with a Map and a custom controller:
/// final controller = MyJsonViewController();
/// MyJsonView(
///   json: {'name': 'Jane Doe', 'age': 25},
///   controller: controller,
///   style: MyJsonViewStyle(keyColor: Colors.red),
/// )
///
/// // Usage with a List, custom style, and search:
/// final controller = MyJsonViewController();
/// MyJsonView(
///    json: [1, 2, {'a': 3}],
///    controller: controller,
///    style: MyJsonViewStyle.defaultStyle(),
///  );
///  controller.filter('3'); // Highlights the '3' in the nested object
///
/// ```
///
class MyJsonView extends StatefulWidget {
  /// The JSON data to display.  This can be a `Map`, a `List`, or a
  /// JSON-encoded `String`.
  final Object json;

  /// The style to use for rendering the JSON view.  If `null`, a default
  /// style is used ([MyJsonViewStyle.defaultStyle]).
  final MyJsonViewStyle? style;

  /// The controller for managing the expansion state and search query.
  /// If not provided a new controller instance get created.
  final MyJsonViewController controller;

  /// Creates a [MyJsonView] from a JSON object ([Map] or [List]).
  const MyJsonView({
    super.key,
    required this.json,
    required this.controller,
    this.style,
  });

  /// Creates a [MyJsonView] from a JSON string.
  ///
  /// This is a convenience constructor that parses the [jsonString] using
  /// [MyJsonViewController]'s internal parsing logic.
  factory MyJsonView.string({
    Key? key,
    required String jsonString,
    MyJsonViewStyle? style,
    required MyJsonViewController controller,
  }) =>
      MyJsonView(
        key: key,
        json: jsonString,
        style: style,
        controller: controller,
      );

  @override
  State<MyJsonView> createState() => _MyJsonViewState();
}

class _MyJsonViewState extends State<MyJsonView> {
  late MyJsonViewStyle _style;

  @override
  void initState() {
    super.initState();
    _style = widget.style ?? MyJsonViewStyle.defaultStyle();
    widget.controller.json = widget.json;
  }

  @override
  void didUpdateWidget(covariant MyJsonView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.style != oldWidget.style) {
      _style = widget.style ?? MyJsonViewStyle.defaultStyle();
    }
    // Only update the json if the controller or the json itself changes.
    if (widget.controller != oldWidget.controller || widget.json != oldWidget.json) {
      widget.controller.json = widget.json;
    }
  }

  /// Highlights search query matches within the provided text.
  ///
  /// This method searches for the current [widget.controller.filterQuery]
  /// within the given [text] and returns a list of [InlineSpan]s.  Matches
  /// are highlighted with a yellow background.  The search is case-insensitive.
  List<InlineSpan> _highlightText(String text, TextStyle style) {
    final query = widget.controller.filterQuery;
    if (query.isEmpty) return [TextSpan(text: text, style: style)];

    final regex = RegExp.escape(query); // No need to create a new RegExp every time
    final matches = regex.allMatches(text.toLowerCase()); // Use toLowerCase() for case-insensitive search
    if (matches.isEmpty) return [TextSpan(text: text, style: style)];

    final spans = <InlineSpan>[];
    int currentIndex = 0;
    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start), style: style));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: style.copyWith(backgroundColor: Colors.yellow),
      ));
      currentIndex = match.end;
    }
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: style));
    }
    return spans;
  }

  /// Creates a [SelectableText.rich] widget from a list of [InlineSpan]s.
  Widget _selectableText(List<InlineSpan> spans) {
    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final effectiveJson = widget.controller.isFiltered ? widget.controller.filteredJson : widget.controller.json;
    final effectiveJson = widget.controller.json;
    // Use a ListView.builder for the top-level as well, for performance with large JSON objects.
    return ListView.builder(
      itemCount: 1, // Top level is always 1 item (the root)
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildJsonTree(
            context,
            effectiveJson,
            isRoot: true,
            keyName: 'root',
          ),
        );
      },
    );
  }

  /// Recursively builds the JSON tree based on the data type.
  ///
  /// This method handles [Map], [List], and primitive types (String, num,
  /// bool, null).  It calls the appropriate builder method for each type.
  Widget _buildJsonTree(
    BuildContext context,
    dynamic filteredJsonData, {
    String? keyName,
    bool isRoot = false,
  }) {
    if (filteredJsonData is Map) {
      return _buildMapNode(context, filteredJsonData, keyName: keyName, isRoot: isRoot);
    } else if (filteredJsonData is List) {
      return _buildListNode(context, filteredJsonData, keyName: keyName, isRoot: isRoot);
    } else {
      return _buildPrimitiveNode(context, filteredJsonData, keyName: keyName);
    }
  }

  /// Builds a widget for brackets, only when enabled.
  Widget _buildBracketWidget(BuildContext context, String symbol) {
    if (!_style.showStartAndEndBrackets) return const SizedBox.shrink();
    return Text(symbol, style: _style.bracketTextStyle);
  }

  /// Builds a string representation of the object/array count.
  ///
  /// The output depends on the [style] (truncated, concise, or annotated).
  String _buildCountString(int count, String label, ObjectInfoStyle style) {
    switch (style) {
      case ObjectInfoStyle.truncated:
        return '...';
      case ObjectInfoStyle.consice:
        return '$count';
      case ObjectInfoStyle.annotated:
        return "$count $label";
    }
  }

  /// Builds a title with key (if provided), starting bracket and optionally a comment.
  Widget _buildKeyValueTitleWithInfo(
    BuildContext context,
    String? key,
    String bracketStart,
    String comment,
    String bracketEnd, [
    bool italic = true,
  ]) {
    final spans = <InlineSpan>[];
    if (key != null) spans.add(_buildKeySpan(context, key));

    spans.add(TextSpan(text: bracketStart, style: _style.bracketTextStyle));

    spans.add(TextSpan(
        text: comment,
        style: italic ? _style.metaTextStyle : _style.metaTextStyle.copyWith(fontStyle: FontStyle.normal)));

    spans.add(TextSpan(text: bracketEnd, style: _style.bracketTextStyle));

    return Align(alignment: Alignment.topLeft, child: _selectableText(spans));
  }

  /// Builds a [TextSpan] for a key, including the colon and highlighting.
  TextSpan _buildKeySpan(BuildContext context, String key) {
    return TextSpan(
      children: [
        ..._highlightText(key, _style.keyTextStyle),
        // Use a single TextSpan for the colon, it's more efficient.
        TextSpan(text: ' : ', style: _style.bracketTextStyle),
      ],
    );
  }

  /// Builds a [TextSpan] for a value, with highlighting.
  TextSpan _buildValueSpan(BuildContext context, String value, TextStyle style) {
    return TextSpan(children: _highlightText(value, style));
  }

  /// Builds a [TextSpan] for a primitive value (String, number, boolean, or null).
  TextSpan _buildValueTextSpan(BuildContext context, dynamic data) {
    // Use a switch statement for slightly better performance and readability.
    switch (data.runtimeType) {
      case String:
        return _buildValueSpan(context, '"$data"', _style.stringTextStyle);
      case num:
        return _buildValueSpan(context, data.toString(), _style.numberTextStyle);
      case bool:
        return _buildValueSpan(context, data.toString(), _style.booleanTextStyle);
      default: // Handles null and other types
        return _buildValueSpan(context, data.toString(), _style.nullTextStyle);
    }
  }

  /// Builds a [JsonExpandableTile] for a [Map] node.
  Widget _buildMapNode(
    BuildContext context,
    Map map, {
    String? keyName,
    bool isRoot = false,
  }) {
    final int count = map.length;
    final entries = map.entries.toList(); // Convert to list once, reuse
    final String comment = _buildCountString(count, _style.propsInfoLabel, _style.objectInfoStyle);

    // Pre-calculate header widgets
    final headerExpanded = _buildKeyValueTitleWithInfo(
      context,
      keyName,
      _style.alwaysShowObjectCount || _style.showStartAndEndBrackets || count == 0 ? '{' : '',
      _style.alwaysShowObjectCount && !_style.showStartAndEndBrackets
          ? comment
          : _style.alwaysShowObjectCount &&
                  _style.showStartAndEndBrackets &&
                  _style.objectInfoStyle != ObjectInfoStyle.truncated &&
                  count > 1
              ? ' // $comment '
              : '',
      _style.alwaysShowObjectCount && !_style.showStartAndEndBrackets
          ? '}'
          : count == 0
              ? '0}'
              : '',
      _style.showStartAndEndBrackets,
    );
    final headerCollapsed = _buildKeyValueTitleWithInfo(
      context,
      keyName,
      '{',
      comment,
      '}',
      false,
    );

    return JsonExpandableTile(
      childrenLength: count,
      headerExpanded: headerExpanded,
      headerCollapsed: headerCollapsed,
      indent: kIndent,
      controller: widget.controller,
      isRoot: isRoot,
      footer: _style.showStartAndEndBrackets ? _buildBracketWidget(context, '}') : const SizedBox.shrink(),
      showIndentGuide: _style.showIndentGuide,
      children: [
        // Use ListView.builder for better performance with large maps
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          itemBuilder: (context, index) {
            final entry = entries[index]; // Access the pre-calculated entry
            return _buildJsonTree(context, entry.value, keyName: entry.key.toString(), isRoot: false);
          },
        )
      ],
    );
  }

  /// Builds a [JsonExpandableTile] for a [List] node.
  Widget _buildListNode(
    BuildContext context,
    List list, {
    String? keyName,
    bool isRoot = false,
  }) {
    final int count = list.length;
    final String comment = _buildCountString(count, _style.itemsInfoLabel, _style.objectInfoStyle);

    // Pre-calculate header widgets
    final headerExpanded = _buildKeyValueTitleWithInfo(
        context,
        keyName,
        _style.alwaysShowObjectCount || _style.showStartAndEndBrackets || count == 0 ? '[' : '',
        _style.alwaysShowObjectCount && !_style.showStartAndEndBrackets
            ? comment
            : _style.alwaysShowObjectCount &&
                    _style.showStartAndEndBrackets &&
                    _style.objectInfoStyle != ObjectInfoStyle.truncated &&
                    count > 1
                ? ' // $comment '
                : '',
        _style.alwaysShowObjectCount && !_style.showStartAndEndBrackets
            ? ']'
            : count == 0
                ? '0]'
                : '',
        _style.showStartAndEndBrackets);
    final headerCollapsed = _buildKeyValueTitleWithInfo(
      context,
      keyName,
      '[',
      comment,
      ']',
      false,
    );

    return JsonExpandableTile(
      childrenLength: count,
      headerExpanded: headerExpanded,
      headerCollapsed: headerCollapsed,
      indent: kIndent,
      controller: widget.controller,
      isRoot: isRoot,
      footer: _style.showStartAndEndBrackets ? _buildBracketWidget(context, ']') : const SizedBox.shrink(),
      showIndentGuide: _style.showIndentGuide,
      children: [
        // Use ListView.builder for better performance with large lists
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          itemBuilder: (context, index) {
            return _buildJsonTree(context, list[index], keyName: '[$index]', isRoot: false);
          },
        )
      ],
    );
  }

  /// Builds a widget for a primitive value (String, number, boolean, or null).
  Widget _buildPrimitiveNode(BuildContext context, dynamic data, {String? keyName}) {
    // Simplify: No need for a container if there's no keyName
    if (keyName == null) {
      return _selectableText(_buildValueTextSpan(context, data).children!);
    }

    return Container(
      padding: const EdgeInsets.only(left: kExtraIndent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use a single RichText for the key and colon
          IntrinsicWidth(
            child: _selectableText(
              TextSpan(children: [
                ..._highlightText(keyName, _style.keyTextStyle),
                TextSpan(text: ' : ', style: _style.bracketTextStyle)
              ]).children!,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(child: _selectableText(_buildValueTextSpan(context, data).children!)),
        ],
      ),
    );
  }
}
