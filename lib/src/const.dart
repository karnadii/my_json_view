/// Constants used in the MyJsonView library.
///
/// These constants define default values for visual aspects of the JSON view,
/// such as indentation and icon sizes. They are used internally by the
/// widgets to maintain a consistent appearance.
library;

/// The size of the expand/collapse icon.
const double kExpandIconSize = 16;

/// The extra indentation added for each level of nesting in the JSON tree,
/// in addition to the space taken up by the indent guide.
const double kExtraIndent = 20;

/// The base indentation for each level of nesting. This is also used as
/// the vertical offset for the top stroke of the indent guide.
const double kIndent = 16;
