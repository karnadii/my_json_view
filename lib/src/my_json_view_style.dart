import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Determines how the object count (number of properties in an object or
/// number of items in an array) is displayed within the JSON tree.
enum ObjectInfoStyle {
  /// Shows three dots within braces `{...}`, `[...]`.  Indicates that the
  /// object or array has content, but doesn't show the exact count.  Useful
  /// for very large objects/arrays where displaying the count might be
  /// computationally expensive or visually overwhelming.
  truncated,

  /// Shows the count within braces `{12}`, `[22]`.  Provides a concise
  /// representation of the object/array size.
  consice,

  /// Shows annotation with the count and a descriptive
  /// label: `{ 12 props }` or `[ 22 items ]`.  The labels used
  /// ("props" and "items") can be customized via [MyJsonViewStyle.propsInfoLabel]
  /// and [MyJsonViewStyle.itemsInfoLabel].
  annotated,
}

/// Defines the visual style for the [MyJsonView] widget.
///
/// This class allows customization of various aspects of the JSON display,
/// including colors, fonts, and the visibility of elements like object counts
/// and indent guides. It provides a default style and factory methods
/// to create styles from a highlight theme (e.g., from a code editor) or
/// to copy and modify existing styles.
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
/// {@macro MyJsonViewStyle.example}
class MyJsonViewStyle {
  /// The font size for all text elements in the JSON view.
  final double fontSize;

  /// The font weight for all text elements.
  final FontWeight fontWeight;

  /// The font style for all text elements.
  final FontStyle fontStyle;

  /// The color for metadata (e.g., comments indicating the number of
  /// properties or items).
  final Color? metaColor;

  /// The color for keys in JSON objects.
  final Color? keyColor;

  /// The color for string values.
  final Color? stringColor;

  /// The color for number values.
  final Color? numberColor;

  /// The color for boolean values (`true` and `false`).
  final Color? booleanColor;

  /// The color for `null` values.
  final Color? nullColor;

  /// The color for brackets (e.g., `{}`, `[]`).
  final Color? bracketColor;

  /// The font family for all text elements.  Defaults to a monospace font
  /// suitable for the current platform.
  final String fontFamily;

  /// The label used for object properties when [objectInfoStyle] is set to
  /// [ObjectInfoStyle.annotated].  Defaults to 'props'.
  final String propsInfoLabel;

  /// The label used for array items when [objectInfoStyle] is set to
  /// [ObjectInfoStyle.annotated].  Defaults to 'items'.
  final String itemsInfoLabel;

  /// Whether to always show the object count, even when a node is collapsed.
  /// Defaults to `true`.  If `false`, the object count is only shown when
  /// the node is expanded.
  final bool alwaysShowObjectCount;

  /// Whether to show the start and end brackets for objects and arrays.
  /// Defaults to `true`.
  final bool showStartAndEndBrackets;

  /// Whether to show vertical lines indicating indentation levels.
  /// Defaults to `true`.
  final bool showIndentGuide;

  /// The style used to display the object count.  See [ObjectInfoStyle]
  /// for the available options.  Defaults to [ObjectInfoStyle.annotated].
  final ObjectInfoStyle objectInfoStyle;

  /// Creates a [MyJsonViewStyle] with the specified properties.
  ///
  /// All color and font properties are required. The boolean flags
  /// `alwaysShowObjectCount`, `showEndBrackets`, and `showIndentGuide`
  /// default to `true`. `propsLabel` defaults to 'props', `itemsLabel`
  /// defaults to 'items', and `objectCountStyle` defaults to
  /// `ObjectCountStyle.annotated`.
  MyJsonViewStyle({
    required this.fontSize,
    required this.fontWeight,
    required this.fontStyle,
    required this.metaColor,
    required this.keyColor,
    required this.stringColor,
    required this.numberColor,
    required this.booleanColor,
    required this.nullColor,
    required this.bracketColor,
    required this.fontFamily,
    this.alwaysShowObjectCount = true,
    this.showStartAndEndBrackets = true,
    this.showIndentGuide = true,
    this.propsInfoLabel = 'props',
    this.itemsInfoLabel = 'items',
    this.objectInfoStyle = ObjectInfoStyle.annotated,
  });

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

  /// Default font size.
  static const double _defaultFontSize = 14.0;

  /// Default font weight.
  static const FontWeight _defaultFontWeight = FontWeight.normal;

  /// Default font style.
  static const FontStyle _defaultFontStyle = FontStyle.normal;

  /// Default meta color.
  static const Color _defaultMetaColor = Colors.grey;

  /// Default key color.
  static const Color _defaultKeyColor = Colors.purple;

  /// Default string color.
  static const Color _defaultStringColor = Colors.green;

  /// Default number color.
  static const Color _defaultNumberColor = Colors.blue;

  /// Default boolean color.
  static const Color _defaultBooleanColor = Colors.orange;

  /// Default null color.
  static const Color _defaultNullColor = Colors.red;

  ///Default bracket color
  static const Color _defaultBracketColor = Colors.grey;

  /// Default font family for Android.
  static const String _defaultAndroidFontFamily = 'Roboto Mono';

  /// Default font family for iOS and  macOS.
  static const String _defaultIosFontFamily = 'Menlo';

  /// Default font family for Windows.
  static const String _defaultWindowsFontFamily = 'Consolas';

  /// Default font family for Linux.
  static const String _defaultLinuxFontFamily = 'Dejavu  Sans Mono';

  /// Default font fallback if the default font family is not available.
  static const List<String> _defaultFallBackFonts = [
    'Courier New',
    'monospace',
    'DejaVu Sans Mono',
    'Liberation Mono',
    'Ubuntu Mono',
    'Noto Sans Mono',
  ];

  ///Default props label
  static const String _defaultPropsInfoLabel = 'props';

  ///Default items label
  static const String _defaultItemsInfoLabel = 'items';

  ///Default always show object count
  static const bool _defaultAlwaysShowObjectCount = true;

  ///Default show end brackets
  static const bool _defaultShowEndBrackets = true;

  ///Default show indent guide
  static const bool _defaultShowIndentGuide = true;

  ///Default object info style
  static const ObjectInfoStyle _defaultObjectInfoStyle = ObjectInfoStyle.annotated;

  /// Creates a [MyJsonViewStyle] with default values.
  ///
  /// This provides a reasonable default style for the JSON view, with
  /// commonly used colors and font settings.  It's a good starting point
  /// for customization.
  factory MyJsonViewStyle.defaultStyle() {
    return MyJsonViewStyle(
      fontSize: _defaultFontSize,
      fontWeight: _defaultFontWeight,
      fontStyle: _defaultFontStyle,
      metaColor: _defaultMetaColor,
      keyColor: _defaultKeyColor,
      stringColor: _defaultStringColor,
      numberColor: _defaultNumberColor,
      booleanColor: _defaultBooleanColor,
      nullColor: _defaultNullColor,
      bracketColor: _defaultBracketColor,
      fontFamily: _defaultFontFamily,
      alwaysShowObjectCount: _defaultAlwaysShowObjectCount,
      showStartAndEndBrackets: _defaultShowEndBrackets,
      showIndentGuide: _defaultShowIndentGuide,
      propsInfoLabel: _defaultPropsInfoLabel,
      itemsInfoLabel: _defaultItemsInfoLabel,
      objectInfoStyle: _defaultObjectInfoStyle,
    );
  }

  /// Creates a [MyJsonViewStyle] from a highlight (re_highlight) theme.
  ///
  /// This factory method attempts to map colors from a given
  /// `theme` (typically a `Map<String, TextStyle>`) to the
  /// corresponding properties of the [MyJsonViewStyle]. It provides
  /// fallback colors if certain theme entries are not found. This is
  /// useful for integrating with existing code highlighting themes,
  /// allowing you to use a familiar color scheme for your JSON view.
  factory MyJsonViewStyle.fromHighlightTheme(Map<String, TextStyle> theme) {
    return MyJsonViewStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      metaColor: theme['comment']?.color ?? theme['quote']?.color,
      keyColor: theme['attr']?.color ??
          theme['variable']?.color ??
          theme['template-variable']?.color ??
          theme['type']?.color ??
          theme['selector-class']?.color ??
          theme['selector-attr']?.color ??
          theme['selector-pseudo']?.color ??
          theme['doctag']?.color ??
          Colors.purple,
      stringColor: theme['string']?.color ??
          theme['regexp']?.color ??
          theme['addition']?.color ??
          theme['attribute']?.color ??
          theme['meta-string']?.color ??
          Colors.green,
      numberColor: theme['number']?.color,
      booleanColor: theme['variable']?.color ??
          theme['template-variable']?.color ??
          theme['type']?.color ??
          theme['selector-class']?.color ??
          theme['selector-attr']?.color ??
          theme['selector-pseudo']?.color ??
          theme['attr']?.color ??
          Colors.orange,
      nullColor: theme['symbol']?.color ??
          theme['bullet']?.color ??
          theme['link']?.color ??
          theme['meta']?.color ??
          theme['selector-id']?.color ??
          theme['title']?.color,
      bracketColor: theme['root']?.color,
      fontFamily: _defaultFontFamily,
    );
  }

  /// Creates a new [MyJsonViewStyle] that is a copy of this style,
  /// with the specified properties replaced.
  ///
  /// This method is useful for creating modified styles based on an
  /// existing style. Any properties that are not explicitly provided
  /// will retain their original values.  This is a concise way to make
  /// small adjustments to a style without having to redefine all properties.
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

  /// Returns a [TextStyle] for metadata elements.
  TextStyle get metaTextStyle => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: FontStyle.italic,
        fontFamily: fontFamily,
        color: metaColor,
      );

  /// Returns a [TextStyle] for key elements.
  TextStyle get keyTextStyle => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        fontFamily: fontFamily,
        color: keyColor,
      );

  /// Returns a [TextStyle] for string elements.
  TextStyle get stringTextStyle => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        fontFamily: fontFamily,
        color: stringColor,
      );

  /// Returns a [TextStyle] for number elements.
  TextStyle get numberTextStyle => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        fontFamily: fontFamily,
        color: numberColor,
      );

  /// Returns a [TextStyle] for boolean elements.
  TextStyle get booleanTextStyle => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        fontFamily: fontFamily,
        color: booleanColor,
      );

  /// Returns a [TextStyle] for null elements.
  TextStyle get nullTextStyle => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        fontFamily: fontFamily,
        color: nullColor,
      );

  /// Returns a [TextStyle] for bracket elements.
  TextStyle get bracketTextStyle => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        fontFamily: fontFamily,
        color: bracketColor,
      );
}
