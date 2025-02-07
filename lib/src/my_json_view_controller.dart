import 'dart:convert' hide json;
import 'package:flutter/material.dart';

/// A controller for managing the state of a [MyJsonView] widget.
///
/// This class uses `ChangeNotifier` to notify listeners (primarily the
/// [MyJsonView] widget) of changes to the JSON data, search query, and
/// expansion state. It provides methods for setting JSON data,
/// expanding/collapsing all nodes, and setting/clearing a search filter.
///
/// The controller handles the logic for expanding and collapsing all nodes
/// at once.  It also maintains the current search query and notifies the
/// view when the query changes, triggering a visual update to highlight
/// matching text. The actual filtering is now visual, using
/// `_highlightText` method on `MyJsonView`.
///
/// {@template MyJsonViewController.example}
/// **Example Usage:**
///
/// ```dart
/// // 1. Create a controller instance (usually with Provider).
/// final myJsonViewController = MyJsonViewController();
///
/// // 2. Provide the controller to your widgets (e.g., using Provider).
/// //    Wrap your top-level widget with ChangeNotifierProvider:
/// //    ChangeNotifierProvider(
/// //      create: (context) => myJsonViewController,
/// //      child: MyApp(),
/// //    );
///
/// // 3. Access the controller in your widgets:
/// final controller = Provider.of<MyJsonViewController>(context);
///
/// // 4. Use the controller's methods and properties:
/// controller.setJson(yourJsonData); // Load JSON data
/// controller.expandAll();          // Expand all nodes
/// controller.filter('keyword');     // Search for a keyword
/// controller.clearFilter();        // Clear the search filter
///
/// // 5. Access the state:
/// print('Search Query: ${controller.filterQuery}');
/// print('Is Expanded: ${controller.isExpanded}');
///
/// // 6. Use with JsonExpandableTile:
/// JsonExpandableTile(
///    ...
///    controller: controller, // Pass the controller to the tile
///    ...
///  )
///
/// ```
/// {@endtemplate}
class MyJsonViewController extends ChangeNotifier {
  /// Creates a [MyJsonViewController].
  MyJsonViewController();

  String _filterQuery = "";
  bool _isExpanded = true;
  dynamic _json = {};
  // dynamic _filteredJson; // Cache the filtered JSON

  /// Whether all nodes are currently expanded.
  ///
  /// This affects all [JsonExpandableTile] widgets that are using this
  /// controller (except for the root tile).
  bool get isExpanded => _isExpanded;

  /// Whether all nodes are currently collapsed.
  ///
  /// This is simply the inverse of [isExpanded].
  bool get isCollapsed => !_isExpanded;

  /// The current search query.
  ///
  /// Setting this to a non-empty string will trigger a visual update to
  /// highlight matching text in the JSON view.
  String get filterQuery => _filterQuery;

  /// Indicates whether a filter is currently active.
  ///
  /// Returns `true` if [filterQuery] is not empty, `false` otherwise.
  bool get isFiltered => _filterQuery.isNotEmpty;

  /// The currently loaded JSON data.
  dynamic get json => _json;

  /// The currently loaded JSON data.
  // @Deprecated('This getter is no longer used for filtering. Use json instead.')
  // dynamic get filteredJson => _filteredJson;

  /// Sets the JSON data to be displayed.
  ///
  /// [input] can be a `Map<String, dynamic>`, a `List<dynamic>`, or a
  /// JSON-encoded `String`.  If a string is provided, it will be parsed
  /// using `jsonDecode`. If parsing fails, an error object will be set
  /// as the JSON data, which will be displayed by [MyJsonView].
  set json(dynamic input) {
    _json = _parseJson(input);
    notifyListeners();
  }

  /// Expands all JSON nodes.
  ///
  /// This will affect all [JsonExpandableTile] widgets that are using this
  /// controller (except for the root tile).
  void expandAll() {
    _isExpanded = true;
    notifyListeners();
  }

  /// Collapses all JSON nodes.
  ///
  /// This will affect all [JsonExpandableTile] widgets that are using this
  /// controller (except for the root tile).
  void collapseAll() {
    _isExpanded = false;
    notifyListeners();
  }

  /// Sets the search query for filtering and highlighting.
  ///
  /// The search is case-insensitive. This method triggers a visual update
  /// in [MyJsonView] to highlight the matching text.
  ///
  /// If the [query] is the same as the current [_filterQuery], this method
  /// does nothing to avoid unnecessary updates.
  void filter(String query) {
    if (query == _filterQuery) {
      return; // Avoid unnecessary filtering if the query hasn't changed.
    }
    _filterQuery = query;
    notifyListeners();
  }

  /// Clears the current search query.
  ///
  /// Resets the view to the original JSON data.  If the current
  /// [_filterQuery] is already empty, this method does nothing to avoid
  /// unnecessary updates.
  void clearFilter() {
    if (_filterQuery.isEmpty) {
      return; // Avoid unnecessary updates.
    }
    _filterQuery = "";
    notifyListeners();
  }

  /// Attempts to parse JSON input.
  ///
  /// [jsonInput] can be a JSON-encoded String, a Map, or a List.
  ///
  /// Returns the parsed JSON if successful, or an error object if parsing fails.
  dynamic _parseJson(Object jsonInput) {
    if (jsonInput is String) {
      try {
        return jsonDecode(jsonInput);
      } catch (_) {
        return {
          "success": false,
          "error": "Invalid JSON format, please fix your JSON string",
        };
      }
    }
    if (jsonInput is Map || jsonInput is List) {
      return jsonInput;
    }
    return {
      "success": false,
      "error":
          "Unsupported JSON format, please provide a Map<String, dynamic>, List<dynamic> or a JSON String",
    };
  }
}
