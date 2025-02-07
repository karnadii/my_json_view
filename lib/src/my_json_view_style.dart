import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Determines how the object count (number of properties in an object or
/// number of items in an array) is displayed within the JSON tree.
enum ObjectInfoStyle {
  /// Shows three dots within braces `{...}`, `[...]`.
  ///
  /// Indicates that the object or array has content, but doesn't show the
  /// exact count.  Useful for very large objects/arrays where displaying
  /// the count might be computationally expensive or visually overwhelming.
  truncated,

  /// Shows the count within braces `{12}`, `[22]`.
  ///
  /// Provides a concise representation of the object/array size.
  consice,

  /// Shows annotation with the count and a descriptive label: `{ 12 props }`
  /// or `[ 22 items ]`.
  ///
  /// The labels used ("props" and "items") can be customized via
  /// [MyJsonViewStyle.propsInfoLabel] and [MyJsonViewStyle.itemsInfoLabel].
  annotated,
}

/// Defines the visual style for the [MyJsonView] widget.
///
/// This class allows customization of various aspects of the JSON display,
/// including colors, fonts, and the visibility of elements like object
/// counts and indent guides. It provides a default style and factory
/// methods to create styles from a highlight theme (e.g., from a code
/// editor) or to copy and modify existing styles.
///
/// {@template MyJsonViewStyle.example}
/// **Example:**
///
/// ```dart
/// // Use the default style:
/// final defaultStyle = MyJsonViewStyle.defaultStyle();
///
/// // Create a custom style:
/// final customStyle = MyJsonViewStyle(
///   fontSize: 16.0,
///   fontWeight: FontWeight.bold,
///   fontStyle: FontStyle.italic,
///   metaColor: Colors.grey,
///   keyColor: Colors.blue,
///   stringColor: Colors.green,
///   numberColor: Colors.orange,
///   booleanColor: Colors.purple,
///   nullColor: Colors.red,
///   bracketColor: Colors.black,
///   fontFamily: 'Roboto Mono',
///   alwaysShowObjectCount: true,
///   showStartAndEndBrackets: true,
///   showIndentGuide: true,
///   propsInfoLabel: 'properties',
///   itemsInfoLabel: 'elements',
///   objectInfoStyle: ObjectInfoStyle.consice,
/// );
///
/// // Create a style from a highlight theme (e.g., from a code editor):
/// final theme = {
///   'comment': TextStyle(color: Colors.grey),
///   'string': TextStyle(color: Colors.green),
///   // ... other theme entries ...
/// };
/// final themedStyle = MyJsonViewStyle.fromHighlightTheme(theme);
///
/// // Copy and modify an existing style:
/// final modifiedStyle = customStyle.copyWith(
///   keyColor: Colors.red,
///   showIndentGuide: false,
/// );
///
/// // You can also make style from re_highlight theme
/// import 'package:re_highlight/styles/atom-one-dark-reasonable.dart';
/// final themeFromReHighlightTheme = MyJsonViewStyle.fromHighlightTheme(atomOneDarkReasonableTheme);
///
/// ```
/// {@endtemplate}
class MyJsonViewStyle {
  /// Creates a [MyJsonViewStyle] with the specified properties.
  ///
  /// All color and font properties are required. The boolean flags
  /// `alwaysShowObjectCount`, `showEndBrackets`, and `showIndentGuide`
  /// default to `true`. `propsLabel` defaults to 'props', `itemsLabel`
  /// defaults to 'items', and `objectCountStyle` defaults to
  /// `ObjectCountStyle.annotated`.
  MyJsonViewStyle({
    this.fontSize = _defaultFontSize,
    this.fontWeight = _defaultFontWeight,
    this.fontStyle = _defaultFontStyle,
    this.metaColor = _defaultMetaColor,
    this.keyColor = _defaultKeyColor,
    this.stringColor = _defaultStringColor,
    this.numberColor = _defaultNumberColor,
    this.booleanColor = _defaultBooleanColor,
    this.nullColor = _defaultNullColor,
    this.bracketColor = _defaultBracketColor,
    String? fontFamily,
    this.alwaysShowObjectCount = _defaultAlwaysShowObjectCount,
    this.showStartAndEndBrackets = _defaultShowEndBrackets,
    this.showIndentGuide = _defaultShowIndentGuide,
    this.propsInfoLabel = _defaultPropsInfoLabel,
    this.itemsInfoLabel = _defaultItemsInfoLabel,
    this.objectInfoStyle = _defaultObjectInfoStyle,
  }) : fontFamily = fontFamily ?? _defaultFontFamily;

  /// The font size for all text elements in the JSON view.
  ///
  /// Defaults to 14.0.
  final double fontSize;

  /// The font weight for all text elements.
  ///
  /// Defaults to [FontWeight.normal].
  final FontWeight fontWeight;

  /// The font style for all text elements.
  ///
  /// Defaults to [FontStyle.normal].
  final FontStyle fontStyle;

  /// The color for metadata (e.g., comments indicating the number of
  /// properties or items).
  ///
  /// Defaults to [Colors.grey].
  final Color? metaColor;

  /// The color for keys in JSON objects.
  ///
  /// Defaults to [Colors.purple].
  final Color? keyColor;

  /// The color for string values.
  ///
  /// Defaults to [Colors.green].
  final Color? stringColor;

  /// The color for number values.
  ///
  /// Defaults to [Colors.blue].
  final Color? numberColor;

  /// The color for boolean values (`true` and `false`).
  ///
  /// Defaults to [Colors.orange].
  final Color? booleanColor;

  /// The color for `null` values.
  ///
  /// Defaults to [Colors.red].
  final Color? nullColor;

  /// The color for brackets (e.g., `{}`, `[]`).
  ///
  /// Defaults to [Colors.grey].
  final Color? bracketColor;

  /// The font family for all text elements.
  ///
  /// Defaults to a monospace font suitable for the current platform.
  final String fontFamily;

  /// The label used for object properties when [objectInfoStyle] is set to
  /// [ObjectInfoStyle.annotated].
  ///
  /// Defaults to 'props'.
  final String propsInfoLabel;

  /// The label used for array items when [objectInfoStyle] is set to
  /// [ObjectInfoStyle.annotated].
  ///
  /// Defaults to 'items'.
  final String itemsInfoLabel;

  /// Whether to always show the object count, even when a node is collapsed.
  ///
  /// Defaults to `true`.  If `false`, the object count is only shown when
  /// the node is expanded.
  final bool alwaysShowObjectCount;

  /// Whether to show the start and end brackets for objects and arrays.
  ///
  /// Defaults to `true`.
  final bool showStartAndEndBrackets;

  /// Whether to show vertical lines indicating indentation levels.
  ///
  /// Defaults to `true`.
  final bool showIndentGuide;

  /// The style used to display the object count.
  ///
  /// See [ObjectInfoStyle] for the available options.  Defaults to
  /// [ObjectInfoStyle.annotated].
  final ObjectInfoStyle objectInfoStyle;

  /// Get default font family based on the platform
  static String get _defaultFontFamily {
    if (kIsWeb || kIsWasm) {
      return _defaultFallBackFonts.first;
    }
    if (Platform.isAndroid) {
      return _defaultAndroidFontFamily;
    } else if (Platform.isIOS || Platform.isMacOS) {
      return _defaultIosFontFamily;
    } else if (Platform.isWindows) {
      return _defaultWindowsFontFamily;
    } else if (Platform.isLinux) {
      return _defaultLinuxFontFamily;
    } else {
      return _defaultFallBackFonts.first;
    }
  }

  /// Default values for the style.
  static const double _defaultFontSize = 14.0;
  static const FontWeight _defaultFontWeight = FontWeight.normal;
  static const FontStyle _defaultFontStyle = FontStyle.normal;
  static const Color _defaultMetaColor = Colors.grey;
  static const Color _defaultKeyColor = Colors.purple;
  static const Color _defaultStringColor = Colors.green;
  static const Color _defaultNumberColor = Colors.blue;
  static const Color _defaultBooleanColor = Colors.orange;
  static const Color _defaultNullColor = Colors.red;
  static const Color _defaultBracketColor = Colors.grey;
  static const String _defaultAndroidFontFamily = 'Roboto Mono';
  static const String _defaultIosFontFamily = 'Menlo';
  static const String _defaultWindowsFontFamily = 'Consolas';
  static const String _defaultLinuxFontFamily = 'Dejavu  Sans Mono';
  static const List<String> _defaultFallBackFonts = [
    'Courier New',
    'monospace',
    'DejaVu Sans Mono',
    'Liberation Mono',
    'Ubuntu Mono',
    'Noto Sans Mono',
  ];
  static const String _defaultPropsInfoLabel = 'props';
  static const String _defaultItemsInfoLabel = 'items';
  static const bool _defaultAlwaysShowObjectCount = true;
  static const bool _defaultShowEndBrackets = true;
  static const bool _defaultShowIndentGuide = true;
  static const ObjectInfoStyle _defaultObjectInfoStyle = ObjectInfoStyle.annotated;

  /// Creates a [MyJsonViewStyle] with default values.
  factory MyJsonViewStyle.defaultStyle() => MyJsonViewStyle();

  /// Creates a [MyJsonViewStyle] from a highlight (re_highlight) theme.
  ///
  /// This factory method attempts to map theme entries from a
  /// `re_highlight` theme (or a similar theme map) to the corresponding
  /// properties of [MyJsonViewStyle].  It provides a convenient way to
  /// style the JSON view based on existing code highlighting themes.
  ///
  /// [theme] A map where keys are theme entry names (e.g., 'comment',
  /// 'string') and values are [TextStyle] objects.
  factory MyJsonViewStyle.fromHighlightTheme(Map<String, TextStyle> theme) {
    Color? getColor(List<String> keys) {
      for (final key in keys) {
        if (theme[key]?.color != null) {
          return theme[key]!.color;
        }
      }
      return null;
    }

    return MyJsonViewStyle(
      metaColor: getColor(['comment', 'quote']),
      keyColor: getColor([
            'attr',
            'variable',
            'template-variable',
            'type',
            'selector-class',
            'selector-attr',
            'selector-pseudo',
            'doctag',
          ]) ??
          _defaultKeyColor,
      stringColor: getColor([
            'string',
            'regexp',
            'addition',
            'attribute',
            'meta-string',
          ]) ??
          _defaultStringColor,
      numberColor: getColor(['number']) ?? _defaultNumberColor,
      booleanColor: getColor([
            'doctag',
            'keyword',
            'formula',
          ]) ??
          _defaultBooleanColor,
      nullColor: getColor([
            'doctag',
            'keyword',
            'formula',
          ]) ??
          _defaultNullColor,
      bracketColor: theme['root']?.color ?? _defaultBracketColor,
    );
  }

  /// Creates a new [MyJsonViewStyle] that is a copy of this style,
  /// with the specified properties replaced.
  ///
  /// This method provides a convenient way to create a modified style
  /// based on an existing style.  Any properties that are not explicitly
  /// specified will retain their original values.
  MyJsonViewStyle copyWith({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? metaColor,
    Color? keyColor,
    Color? stringColor,
    Color? numberColor,
    Color? booleanColor,
    Color? nullColor,
    Color? bracketColor,
    String? fontFamily,
    bool? alwaysShowObjectCount,
    bool? showStartAndEndBrackets,
    bool? showIndentGuide,
    String? propsInfoLabel,
    String? itemsInfoLabel,
    ObjectInfoStyle? objectInfoStyle,
  }) {
    return MyJsonViewStyle(
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      metaColor: metaColor ?? this.metaColor,
      keyColor: keyColor ?? this.keyColor,
      stringColor: stringColor ?? this.stringColor,
      numberColor: numberColor ?? this.numberColor,
      booleanColor: booleanColor ?? this.booleanColor,
      nullColor: nullColor ?? this.nullColor,
      bracketColor: bracketColor ?? this.bracketColor,
      fontFamily: fontFamily ?? this.fontFamily,
      propsInfoLabel: propsInfoLabel ?? this.propsInfoLabel,
      itemsInfoLabel: itemsInfoLabel ?? this.itemsInfoLabel,
      alwaysShowObjectCount: alwaysShowObjectCount ?? this.alwaysShowObjectCount,
      showStartAndEndBrackets: showStartAndEndBrackets ?? this.showStartAndEndBrackets,
      showIndentGuide: showIndentGuide ?? this.showIndentGuide,
      objectInfoStyle: objectInfoStyle ?? this.objectInfoStyle,
    );
  }

  /// Returns a [TextStyle] with the given [color].
  TextStyle _getTextStyle(Color? color) => TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: fontFamily,
      color: color,
      fontFamilyFallback: _defaultFallBackFonts);

  /// Returns a [TextStyle] for metadata elements.
  TextStyle get metaTextStyle => _getTextStyle(metaColor).copyWith(fontStyle: FontStyle.italic);

  /// Returns a [TextStyle] for key elements.
  TextStyle get keyTextStyle => _getTextStyle(keyColor);

  /// Returns a [TextStyle] for string elements.
  TextStyle get stringTextStyle => _getTextStyle(stringColor);

  /// Returns a [TextStyle] for number elements.
  TextStyle get numberTextStyle => _getTextStyle(numberColor);

  /// Returns a [TextStyle] for boolean elements.
  TextStyle get booleanTextStyle => _getTextStyle(booleanColor);

  /// Returns a [TextStyle] for null elements.
  TextStyle get nullTextStyle => _getTextStyle(nullColor);

  /// Returns a [TextStyle] for bracket elements.
  TextStyle get bracketTextStyle => _getTextStyle(bracketColor);
}
