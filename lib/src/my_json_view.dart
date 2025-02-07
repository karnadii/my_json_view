import 'package:flutter/material.dart';

import 'const.dart';
import 'my_json_view_style.dart';
import 'my_json_expandable_tile.dart';
import 'my_json_view_controller.dart';

/// A Flutter widget for displaying JSON data in a user-friendly, expandable,
/// and searchable tree view.
///
/// `MyJsonView` takes JSON data (either as a `String`, `Map`, or `List`) and
/// renders it as an interactive tree. Users can expand and collapse nodes,
/// search for specific keys or values, and customize the appearance using
/// [MyJsonViewStyle].
///
/// The widget uses a [MyJsonViewController] to manage the expansion state and
/// search query. You may provide your own controller (e.g., via Provider) or
/// allow the widget to create a default instance internally.
///
/// The search functionality highlights matches within the JSON tree. Both keys
/// and values are highlighted when appropriate.
///
/// {@template MyJsonView.example}
/// **Example Usage:**
///
/// ```dart
/// // Basic usage with a JSON string:
/// MyJsonView(
///   json: '{ "name": "John Doe", "age": 30 }',
///   controller: MyJsonViewController(), // Or any instance
/// );
///
/// // Using a controller for more control:
/// final controller = MyJsonViewController();
///
/// MyJsonView(
///   json: myJsonObject,  // Could be Map, List, or String
///   controller: controller,
/// );
///
/// // Later, you can use the controller:
/// controller.expandAll();
/// controller.filter('John');
///
/// // Customizing the style:
/// MyJsonView(
///  json: myJsonData,
///  style: MyJsonViewStyle(
///    keyColor: Colors.blue,
///    stringColor: Colors.green,
///  ),
///  controller: MyJsonViewController(),
/// );
/// ```
/// {@endtemplate}
class MyJsonView extends StatefulWidget {
  /// Creates a [MyJsonView] from a JSON object ([Map] or [List]).
  ///
  /// The [json] argument is required. The [style] argument is optional
  /// and defaults to [MyJsonViewStyle.defaultStyle]. The [controller]
  /// argument is required to manage the state.
  const MyJsonView({
    super.key,
    required this.json,
    required this.controller,
    this.style,
  });

  /// The JSON data to display. This can be a `Map`, a `List`, or a JSON-encoded `String`.
  final Object json;

  /// The style to use for rendering the JSON view. Defaults to [MyJsonViewStyle.defaultStyle] if `null`.
  final MyJsonViewStyle? style;

  /// The controller to manage expansion state and search query.
  /// If not provided a new controller instance gets created.
  final MyJsonViewController controller;

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
    // Update JSON only if the controller or the JSON itself changes.
    if (widget.controller != oldWidget.controller || widget.json != oldWidget.json) {
      widget.controller.json = widget.json;
    }
  }

  /// Highlights search query matches within [text] using [style].
  List<InlineSpan> _highlightText(String text, TextStyle style) {
    final query = widget.controller.filterQuery;
    if (query.isEmpty) return [TextSpan(text: text, style: style)];

    // Case-insensitive matching.
    final escapedQuery = RegExp.escape(query);
    final lowerText = text.toLowerCase();
    final matches = RegExp(escapedQuery).allMatches(lowerText);
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

  /// Wraps a list of [InlineSpan]s in a [SelectableText.rich] widget.
  Widget _selectableText(List<InlineSpan> spans) {
    return SelectableText.rich(
      TextSpan(children: spans),
      showCursor: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveJson = widget.controller.json;
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildJsonTree(context, effectiveJson, isRoot: true, keyName: 'root'),
        );
      },
    );
  }

  /// Recursively builds the JSON tree according to the data type.
  Widget _buildJsonTree(
    BuildContext context,
    dynamic data, {
    String? keyName,
    bool isRoot = false,
  }) {
    if (data is Map) {
      return _buildMapNode(context, data, keyName: keyName, isRoot: isRoot);
    } else if (data is List) {
      return _buildListNode(context, data, keyName: keyName, isRoot: isRoot);
    } else {
      return _buildPrimitiveNode(context, data, keyName: keyName);
    }
  }

  /// Returns a widget for brackets if enabled.
  Widget _buildBracketWidget(BuildContext context, String symbol) {
    if (!_style.showStartAndEndBrackets) return const SizedBox.shrink();
    return Text(symbol, style: _style.bracketTextStyle);
  }

  /// Returns a string representation of object/array count based on the style.
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

  /// Constructs a title widget including the key (if provided), brackets and comment.
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
      style: italic ? _style.metaTextStyle : _style.metaTextStyle.copyWith(fontStyle: FontStyle.normal),
    ));
    spans.add(TextSpan(text: bracketEnd, style: _style.bracketTextStyle));

    return Align(alignment: Alignment.topLeft, child: _selectableText(spans));
  }

  /// Constructs a text span for a key including highlighting and colon separation.
  TextSpan _buildKeySpan(BuildContext context, String key) {
    final listIndexPattern = RegExp(r'^\[(\d+)\]');
    if (listIndexPattern.hasMatch(key)) {
      final match = listIndexPattern.firstMatch(key)!;
      final index = match.group(1)!;
      return TextSpan(
        children: [
          TextSpan(text: '[', style: _style.bracketTextStyle),
          TextSpan(text: index, style: _style.bracketTextStyle),
          TextSpan(text: ']', style: _style.bracketTextStyle),
          TextSpan(text: ' : ', style: _style.bracketTextStyle),
        ],
      );
    }
    return TextSpan(
      children: [
        ..._highlightText(key, _style.keyTextStyle),
        TextSpan(text: ' : ', style: _style.bracketTextStyle),
      ],
    );
  }

  /// Constructs a text span for a value with highlighting.
  TextSpan _buildValueSpan(BuildContext context, String value, TextStyle style) {
    return TextSpan(children: _highlightText(value, style));
  }

  /// Returns a [TextSpan] for a primitive type (String, number, bool, or null).
  TextSpan _buildValueTextSpan(BuildContext context, dynamic data) {
    if (data is String) {
      return _buildValueSpan(context, '"$data"', _style.stringTextStyle);
    } else if (data is num) {
      return _buildValueSpan(context, data.toString(), _style.numberTextStyle);
    } else if (data is bool) {
      return _buildValueSpan(context, data.toString(), _style.booleanTextStyle);
    } else {
      return _buildValueSpan(context, data.toString(), _style.nullTextStyle);
    }
  }

  /// Helper to extract common expandable header construction logic.
  Map<String, Widget> _buildHeaders({
    String? keyName,
    required int count,
    required String openBracket,
    required String closeBracket,
    required String infoLabel,
  }) {
    final comment = _buildCountString(count, infoLabel, _style.objectInfoStyle);
    // Expanded header adapts based on style flags.
    final headerExpanded = _buildKeyValueTitleWithInfo(
      context,
      keyName,
      _style.alwaysShowObjectCount || _style.showStartAndEndBrackets || count == 0 ? openBracket : '',
      _style.alwaysShowObjectCount && !_style.showStartAndEndBrackets
          ? comment
          : _style.alwaysShowObjectCount &&
                  _style.showStartAndEndBrackets &&
                  _style.objectInfoStyle != ObjectInfoStyle.truncated &&
                  count > 1
              ? ' // $comment '
              : '',
      _style.alwaysShowObjectCount && !_style.showStartAndEndBrackets
          ? closeBracket
          : count == 0
              ? '0$closeBracket'
              : '',
      _style.showStartAndEndBrackets,
    );
    // Collapsed header always uses the basic bracket notation.
    final headerCollapsed = _buildKeyValueTitleWithInfo(
      context,
      keyName,
      openBracket,
      comment,
      closeBracket,
      false,
    );
    return {
      'expanded': headerExpanded,
      'collapsed': headerCollapsed,
    };
  }

  /// Builds a widget for a Map node.
  Widget _buildMapNode(
    BuildContext context,
    Map map, {
    String? keyName,
    bool isRoot = false,
  }) {
    final count = map.length;
    final headers = _buildHeaders(
      keyName: keyName,
      count: count,
      openBracket: '{',
      closeBracket: '}',
      infoLabel: _style.propsInfoLabel,
    );
    return JsonExpandableTile(
      childrenLength: count,
      headerExpanded: headers['expanded']!,
      headerCollapsed: headers['collapsed']!,
      indent: kIndent,
      controller: widget.controller,
      isRoot: isRoot,
      footer: _style.showStartAndEndBrackets ? _buildBracketWidget(context, '}') : const SizedBox.shrink(),
      showIndentGuide: _style.showIndentGuide,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          itemBuilder: (context, index) {
            final entry = map.entries.toList()[index];
            return _buildJsonTree(context, entry.value, keyName: entry.key.toString(), isRoot: false);
          },
        )
      ],
    );
  }

  /// Builds a widget for a List node.
  Widget _buildListNode(
    BuildContext context,
    List list, {
    String? keyName,
    bool isRoot = false,
  }) {
    final count = list.length;
    final headers = _buildHeaders(
      keyName: keyName,
      count: count,
      openBracket: '[',
      closeBracket: ']',
      infoLabel: _style.itemsInfoLabel,
    );
    return JsonExpandableTile(
      childrenLength: count,
      headerExpanded: headers['expanded']!,
      headerCollapsed: headers['collapsed']!,
      indent: kIndent,
      controller: widget.controller,
      isRoot: isRoot,
      footer: _style.showStartAndEndBrackets ? _buildBracketWidget(context, ']') : const SizedBox.shrink(),
      showIndentGuide: _style.showIndentGuide,
      children: [
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

  /// Builds a widget for a primitive value (String, number, bool, or null).
  Widget _buildPrimitiveNode(BuildContext context, dynamic data, {String? keyName}) {
    // Build the value spans using the helper method.
    final List<InlineSpan> valueSpans = [_buildValueTextSpan(context, data)];
    if (keyName != null) {
      // Use _buildKeySpan to handle array style keys like [0].
      final TextSpan keySpan = _buildKeySpan(context, keyName);
      return Padding(
        padding: const EdgeInsets.only(left: kExtraIndent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectableText(keySpan.children ?? [keySpan]),
            Expanded(child: _selectableText(valueSpans)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: kExtraIndent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _selectableText(valueSpans)),
        ],
      ),
    );
  }
}
