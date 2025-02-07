/*
  My JSON View Demo
  ------------------

  This example demonstrates the usage of MyJsonView along with a JSON code editor
  to display and interact with JSON data. The app supports both a tree view and a raw
  JSON view, and includes a search functionality. The style of MyJsonView is updated dynamically
  based on the system brightness.
  
  Improvements made:
  - Removed redundant post-frame callback in initState as didChangeDependencies handles initial style update.
  - Updated _style declaration from late final to late to allow updates.
  - Added inline comments to clarify widget logic and code sections.
*/

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_json_view/my_json_view.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My JSON View Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber, brightness: Brightness.dark),
      ),
      home: const MyHomePage(title: 'My JSON View'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _jsonViewController = MyJsonViewController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late final CodeLineEditingController _codeEditorController;
  // Remove final keyword from _style to allow updates via setState
  late MyJsonViewStyle _style;
  Timer? _debounce; // Debounce timer for search filtering
  int _selectedIndex = 0;
  bool _isSearching = false;

  // JSON data to display. Declared as static const to avoid re-allocation.
  static const dynamic _jsonData = {
    "applicationName": "JSON Viewer Tester",
    "version": 1.2,
    "releaseDate": "2024-10-27",
    "isValid": true,
    "author": {
      "name": "Alex Doe",
      "email": "alex.doe@example.com",
      "organization": "Acme Software",
      "address": {
        "street": "42 Galaxy Way",
        "city": "Metropolis",
        "state": "Stateville",
        "zip": "12345",
        "country": "United Fictional Republic",
        "coordinates": {"latitude": 48.8566, "longitude": 2.3522, "altitude": null}
      },
      "contactNumbers": ["+15551112222", "+15553334444"],
      "isActive": true
    },
    "features": [
      "Syntax Highlighting",
      "Collapsible Nodes",
      "Search Functionality",
      "JSON Validation",
      "Data Type Display"
    ],
    "configuration": {
      "theme": "dark",
      "fontSize": 14,
      "indentSize": 2,
      "showLineNumbers": true,
      "maxDepth": 10,
      "customColors": {
        "string": "#f1fa8c",
        "number": "#bd93f9",
        "boolean": "#ff79c6",
        "null": "#8be9fd",
        "key": "#50fa7b"
      },
      "allowedOperations": ["read", "parse", "validate"]
    },
    "data": [
      {
        "id": 1,
        "name": "Item 1",
        "description": "This is the first item.",
        "price": 19.99,
        "inStock": true,
        "tags": ["tag1", "tag2", "tag3"],
        "relatedItems": [2, 3]
      },
      {
        "id": 2,
        "name": "Item 2",
        "description": null,
        "price": 29.99,
        "inStock": false,
        "tags": ["tag2", "tag4"],
        "relatedItems": [1]
      },
      {
        "id": 3,
        "name": "Item 3",
        "description": "Another item.",
        "price": 9.99,
        "inStock": true,
        "tags": [],
        "relatedItems": [1, 2],
        "details": {
          "weight": 0.5,
          "dimensions": {"width": 10, "height": 5, "depth": 2}
        }
      }
    ],
    "logs": [
      {"timestamp": "2024-10-26T10:00:00Z", "level": "info", "message": "Application started"},
      {
        "timestamp": "2024-10-26T10:01:00Z",
        "level": "warn",
        "message": "Configuration file not found, using defaults",
        "details": {"file_path": "/path/to/config.json", "error_code": 404}
      },
      {"timestamp": "2024-10-26T10:05:00Z", "level": "error", "message": "Failed to load data", "details": null}
    ],
    "statusCodes": [200, 201, 400, 401, 403, 404, 500],
    "emptyArray": [],
    "emptyObject": {},
    "nullValue": null,
    "booleanTrue": true,
    "booleanFalse": false,
    "largeNumber": 1234567890,
    "smallNumber": 0.000000123,
    "negativeNumber": -42,
    "longString":
        "This is a very long string to test the wrapping capabilities of the JSON viewer.  It should handle long strings gracefully without breaking the layout.",
    "specialCharacters": "!@#\$%^&*()_+=-`~[]{}|;':\",./<>?",
    "unicodeCharacters": "你好世界",
    "escapedCharacters": "This string contains \"quotes\" and \\backslashes\\.",
    "mixedArray": [
      1,
      "two",
      true,
      null,
      {"key": "value"}
    ],
    "deeplyNested": {
      "level1": {
        "level2": {
          "level3": {
            "level4": {"level5": "Finally, some data!"}
          }
        }
      }
    },
    "anotherArray": [
      {"name": "John", "age": 30, "city": "New York"},
      {"name": "Jane", "age": 25, "city": "Los Angeles"},
      {"name": "Peter", "age": 40, "city": "Chicago"}
    ],
    "lastItem": "The end"
  };

  @override
  void initState() {
    super.initState();
    // Initialize the CodeLineEditingController with pretty printed JSON.
    _codeEditorController = CodeLineEditingController.fromText(
      const JsonEncoder.withIndent('  ').convert(_jsonData),
    );
  }

  // Update the style based on the current system brightness.
  // This method is called whenever dependencies change.
  void _updateStyle() {
    setState(() {
      _style = MyJsonViewStyle.fromHighlightTheme(
        MediaQuery.of(context).platformBrightness == Brightness.dark ? atomOneDarkTheme : atomOneLightTheme,
      ).copyWith(
        showStartAndEndBrackets: true,
        fontSize: 14,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update the style when widget dependencies change (e.g., theme change).
    _updateStyle();
  }

  @override
  void dispose() {
    _codeEditorController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Handle search input changes with debounce to reduce filter operations.
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      setState(() {
        _jsonViewController.filter(value); // Filter the JSON tree view
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    setState(() {
                      _jsonViewController.clearFilter();
                    });
                  });
                },
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('JSON Tree'),
                    icon: Icon(Icons.data_object),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Raw JSON'),
                    icon: Icon(Icons.code),
                  ),
                ],
                selected: {_selectedIndex},
                onSelectionChanged: (value) {
                  setState(() {
                    _selectedIndex = value.first;
                  });
                },
              ),
        centerTitle: true,
        actions: [
          // Only show JSON view controls when in JSON tree mode and not searching.
          if (_selectedIndex == 0 && !_isSearching) ...[
            IconButton(
              onPressed: () => _jsonViewController.expandAll(),
              tooltip: 'Expand All',
              icon: const Icon(Icons.expand_rounded),
            ),
            IconButton(
              onPressed: () => _jsonViewController.collapseAll(),
              tooltip: 'Collapse All',
              icon: const Icon(Icons.compress),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  // Automatically request focus for the search field.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _searchFocusNode.requestFocus();
                  });
                });
              },
              tooltip: 'Search JSON',
              icon: const Icon(Icons.search),
            ),
          ]
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    // JSON Tree view using MyJsonView
                    MyJsonView(
                      style: _style,
                      controller: _jsonViewController,
                      json: _jsonData,
                    ),
                    // Raw JSON view using CodeEditor
                    CodeEditor(
                      controller: _codeEditorController,
                      readOnly: true,
                      indicatorBuilder: (context, editingController, chunkController, notifier) {
                        return Row(
                          children: [
                            DefaultCodeLineNumber(
                              controller: editingController,
                              notifier: notifier,
                            ),
                            DefaultCodeChunkIndicator(
                              width: 20,
                              controller: chunkController,
                              notifier: notifier,
                            )
                          ],
                        );
                      },
                      style: CodeEditorStyle(
                        fontFamily: _style.fontFamily,
                        fontSize: _style.fontSize,
                        codeTheme: CodeHighlightTheme(
                          languages: {
                            'json': CodeHighlightThemeMode(mode: langJson),
                          },
                          theme: MediaQuery.of(context).platformBrightness == Brightness.dark
                              ? atomOneDarkTheme
                              : atomOneLightTheme,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
