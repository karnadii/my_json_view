/// Provides constants used throughout the `my_json_view` package.
///
/// These constants define default values for visual aspects of the JSON
/// view, such as indentation and icon sizes. They are used internally by
/// the widgets to maintain a consistent appearance and can be used to
/// customize the look and feel of the JSON view.
library;

/// The size of the expand/collapse icon.
///
/// This constant defines the width and height of the [MyExpandIcon] widget.
///
/// Defaults to 18.
const double kExpandIconSize = 18;

/// The extra indentation added for each level of nesting in the JSON tree.
///
/// This value is added to the base indentation ([kIndent]) to provide
/// additional visual separation between levels.
///
/// Defaults to 20.
const double kExtraIndent = 20;

/// The base indentation for each level of nesting in the JSON tree.
///
/// This value also determines the vertical offset for the top stroke of
/// the indent guide in [JsonExpandableTile].
///
/// Defaults to 16.
const double kIndent = 16;
