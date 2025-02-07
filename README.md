
[![pub package](https://img.shields.io/pub/v/my_json_view.svg)](https://pub.dev/packages/my_json_view)
# MyJsonView

A customizable Flutter widget for displaying JSON data in a user-friendly, expandable, and searchable tree view.

# Demo
Check the demo at [https://karnadii.github.io/my_json_view/](https://karnadii.github.io/my_json_view/)

## Screenshots
| Screenshot 1 | Screenshot 2 | Screenshot 3 |
|------------|------------|------------|
| ![Screenshot 1](https://raw.githubusercontent.com/karnadii/my_json_view/main/img/ss1.png) | ![Screenshot 2](https://raw.githubusercontent.com/karnadii/my_json_view/main/img/ss2.png) | ![Screenshot 3](https://raw.githubusercontent.com/karnadii/my_json_view/main/img/ss3.png) |

## Features

- 🌳 Interactive tree view with expand/collapse functionality
- 🔍 Search and highlight functionality for both keys and values
- 🎨 Customizable appearance with `MyJsonViewStyle`
- 📋 Selectable text for easy copying



## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  my_json_view: ^1.0.0
```

## Usage

### Basic Usage

```dart
import 'package:my_json_view/my_json_view.dart';

final controller = MyJsonViewController();
MyJsonView(
  json: {'name': 'John Doe', 'age': 30},
  controller: controller,
);

```

### With Custom Style

```dart
final style = MyJsonViewStyle(
  fontSize: 16.0,
  keyColor: Colors.blue,
  stringColor: Colors.green,
  numberColor: Colors.orange,
  booleanColor: Colors.purple,
  nullColor: Colors.red,
  fontFamily: 'Roboto Mono',
  showIndentGuide: true,
  objectInfoStyle: ObjectInfoStyle.annotated,
);

MyJsonView(
  json: yourJsonData,
  style: style,
  controller: MyJsonViewController(),
);
```

### With Search Functionality

```dart
final controller = MyJsonViewController();

Column(
  children: [
    TextField(
      onChanged: (value) {
        setState(() {
            controller.filter(value);
        });
      },
    ),
    Expanded(
      child: MyJsonView(
        json: yourJsonData,
        controller: controller,
      ),
    ),
  ],
);

```
### With Expand/Collapse Controls

```dart
final controller = MyJsonViewController();

Row(
  children: [
    IconButton(
      onPressed: () => controller.expandAll(),
      icon: Icon(Icons.expand),
    ),
    IconButton(
      onPressed: () => controller.collapseAll(),
      icon: Icon(Icons.compress),
    ),
    Expanded(
      child: MyJsonView(
        json: yourJsonData,
        controller: controller,
      ),
    ),
  ],
);
```

## Customization

### Style Properties

- `fontSize`: Font size for all text elements
- `fontWeight`: Font weight for all text elements
- `fontStyle`: Font style for all text elements
- `fontFamily`: Font family for all text elements
- `keyColor`: Color for object keys
- `stringColor`: Color for string values
- `numberColor`: Color for number values
- `booleanColor`: Color for boolean values
- `nullColor`: Color for null values
- `bracketColor`: Color for brackets and colons
- `metaColor`: Color for metadata (e.g., object/array counts)
- `showIndentGuide`: Whether to show vertical indent guides
- `showStartAndEndBrackets`: Whether to show opening/closing brackets
- `objectInfoStyle`: How to display object/array information (truncated/concise/annotated)

### Controller Features

- `expandAll()`: Expands all nodes
- `collapseAll()`: Collapses all nodes
- `filter(String query)`: Highlights text matching the query
- `clearFilter()`: Clears the current search filter

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.


