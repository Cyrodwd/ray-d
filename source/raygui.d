module raygui;

import raylib;
import core.stdc.stdlib;

/*******************************************************************************************
*
*   raygui v4.5-dev - A simple and easy-to-use immediate-mode gui library
*
*   DESCRIPTION:
*       raygui is a tools-dev-focused immediate-mode-gui library based on raylib but also
*       available as a standalone library, as long as input and drawing functions are provided.
*
*   FEATURES:
*       - Immediate-mode gui, minimal retained data
*       - +25 controls provided (basic and advanced)
*       - Styling system for colors, font and metrics
*       - Icons supported, embedded as a 1-bit icons pack
*       - Standalone mode option (custom input/graphics backend)
*       - Multiple support tools provided for raygui development
*
*   POSSIBLE IMPROVEMENTS:
*       - Better standalone mode API for easy plug of custom backends
*       - Externalize required inputs, allow user easier customization
*
*   LIMITATIONS:
*       - No editable multi-line word-wraped text box supported
*       - No auto-layout mechanism, up to the user to define controls position and size
*       - Standalone mode requires library modification and some user work to plug another backend
*
*   NOTES:
*       - WARNING: GuiLoadStyle() and GuiLoadStyle{Custom}() functions, allocate memory for
*         font atlas recs and glyphs, freeing that memory is (usually) up to the user,
*         no unload function is explicitly provided... but note that GuiLoadStyleDefault() unloads
*         by default any previously loaded font (texture, recs, glyphs).
*       - Global UI alpha (guiAlpha) is applied inside GuiDrawRectangle() and GuiDrawText() functions
*
*   CONTROLS PROVIDED:
*     # Container/separators Controls
*       - WindowBox     --> StatusBar, Panel
*       - GroupBox      --> Line
*       - Line
*       - Panel         --> StatusBar
*       - ScrollPanel   --> StatusBar
*       - TabBar        --> Button
*
*     # Basic Controls
*       - Label
*       - LabelButton   --> Label
*       - Button
*       - Toggle
*       - ToggleGroup   --> Toggle
*       - ToggleSlider
*       - CheckBox
*       - ComboBox
*       - DropdownBox
*       - TextBox
*       - ValueBox      --> TextBox
*       - Spinner       --> Button, ValueBox
*       - Slider
*       - SliderBar     --> Slider
*       - ProgressBar
*       - StatusBar
*       - DummyRec
*       - Grid
*
*     # Advance Controls
*       - ListView
*       - ColorPicker   --> ColorPanel, ColorBarHue
*       - MessageBox    --> Window, Label, Button
*       - TextInputBox  --> Window, Label, TextBox, Button
*
*     It also provides a set of functions for styling the controls based on its properties (size, color).
*
*
*   RAYGUI STYLE (guiStyle):
*       raygui uses a global data array for all gui style properties (allocated on data segment by default),
*       when a new style is loaded, it is loaded over the global style... but a default gui style could always be
*       recovered with GuiLoadStyleDefault() function, that overwrites the current style to the default one
*
*       The global style array size is fixed and depends on the number of controls and properties:
*
*           static unsigned int guiStyle[RAYGUI_MAX_CONTROLS*(RAYGUI_MAX_PROPS_BASE + RAYGUI_MAX_PROPS_EXTENDED)];
*
*       guiStyle size is by default: 16*(16 + 8) = 384*4 = 1536 bytes = 1.5 KB
*
*       Note that the first set of BASE properties (by default guiStyle[0..15]) belong to the generic style
*       used for all controls, when any of those base values is set, it is automatically populated to all
*       controls, so, specific control values overwriting generic style should be set after base values.
*
*       After the first BASE set we have the EXTENDED properties (by default guiStyle[16..23]), those
*       properties are actually common to all controls and can not be overwritten individually (like BASE ones)
*       Some of those properties are: TEXT_SIZE, TEXT_SPACING, LINE_COLOR, BACKGROUND_COLOR
*
*       Custom control properties can be defined using the EXTENDED properties for each independent control.
*
*       TOOL: rGuiStyler is a visual tool to customize raygui style: github.com/raysan5/rguistyler
*
*
*   RAYGUI ICONS (guiIcons):
*       raygui could use a global array containing icons data (allocated on data segment by default),
*       a custom icons set could be loaded over this array using GuiLoadIcons(), but loaded icons set
*       must be same RAYGUI_ICON_SIZE and no more than RAYGUI_ICON_MAX_ICONS will be loaded
*
*       Every icon is codified in binary form, using 1 bit per pixel, so, every 16x16 icon
*       requires 8 integers (16*16/32) to be stored in memory.
*
*       When the icon is draw, actually one quad per pixel is drawn if the bit for that pixel is set.
*
*       The global icons array size is fixed and depends on the number of icons and size:
*
*           static unsigned int guiIcons[RAYGUI_ICON_MAX_ICONS*RAYGUI_ICON_DATA_ELEMENTS];
*
*       guiIcons size is by default: 256*(16*16/32) = 2048*4 = 8192 bytes = 8 KB
*
*       TOOL: rGuiIcons is a visual tool to customize/create raygui icons: github.com/raysan5/rguiicons
*
*   RAYGUI LAYOUT:
*       raygui currently does not provide an auto-layout mechanism like other libraries,
*       layouts must be defined manually on controls drawing, providing the right bounds Rectangle for it.
*
*       TOOL: rGuiLayout is a visual tool to create raygui layouts: github.com/raysan5/rguilayout
*
*   CONFIGURATION:
*       #define RAYGUI_IMPLEMENTATION
*           Generates the implementation of the library into the included file.
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation.
*
*       #define RAYGUI_STANDALONE
*           Avoid raylib.h header inclusion in this file. Data types defined on raylib are defined
*           internally in the library and input management and drawing functions must be provided by
*           the user (check library implementation for further details).
*
*       #define RAYGUI_NO_ICONS
*           Avoid including embedded ricons data (256 icons, 16x16 pixels, 1-bit per pixel, 2KB)
*
*       #define RAYGUI_CUSTOM_ICONS
*           Includes custom ricons.h header defining a set of custom icons,
*           this file can be generated using rGuiIcons tool
*
*       #define RAYGUI_DEBUG_RECS_BOUNDS
*           Draw control bounds rectangles for debug
*
*       #define RAYGUI_DEBUG_TEXT_BOUNDS
*           Draw text bounds rectangles for debug
*
*   VERSIONS HISTORY:
*       4.5-dev (Sep-2024)    Current dev version...
*                         ADDED: guiControlExclusiveMode and guiControlExclusiveRec for exclusive modes
*                         ADDED: GuiValueBoxFloat()
*                         ADDED: GuiDropdonwBox() properties: DROPDOWN_ARROW_HIDDEN, DROPDOWN_ROLL_UP
*                         ADDED: GuiListView() property: LIST_ITEMS_BORDER_WIDTH
*                         ADDED: Multiple new icons
*                         REVIEWED: GuiTabBar(), close tab with mouse middle button
*                         REVIEWED: GuiScrollPanel(), scroll speed proportional to content
*                         REVIEWED: GuiDropdownBox(), support roll up and hidden arrow
*                         REVIEWED: GuiTextBox(), cursor position initialization
*                         REVIEWED: GuiSliderPro(), control value change check
*                         REVIEWED: GuiGrid(), simplified implementation
*                         REVIEWED: GuiIconText(), increase buffer size and reviewed padding
*                         REVIEWED: GuiDrawText(), improved wrap mode drawing
*                         REVIEWED: GuiScrollBar(), minor tweaks
*                         REVIEWED: Functions descriptions, removed wrong return value reference
*                         REDESIGNED: GuiColorPanel(), improved HSV <-> RGBA convertion
*
*       4.0 (12-Sep-2023) ADDED: GuiToggleSlider()
*                         ADDED: GuiColorPickerHSV() and GuiColorPanelHSV()
*                         ADDED: Multiple new icons, mostly compiler related
*                         ADDED: New DEFAULT properties: TEXT_LINE_SPACING, TEXT_ALIGNMENT_VERTICAL, TEXT_WRAP_MODE
*                         ADDED: New enum values: GuiTextAlignment, GuiTextAlignmentVertical, GuiTextWrapMode
*                         ADDED: Support loading styles with custom font charset from external file
*                         REDESIGNED: GuiTextBox(), support mouse cursor positioning
*                         REDESIGNED: GuiDrawText(), support multiline and word-wrap modes (read only)
*                         REDESIGNED: GuiProgressBar() to be more visual, progress affects border color
*                         REDESIGNED: Global alpha consideration moved to GuiDrawRectangle() and GuiDrawText()
*                         REDESIGNED: GuiScrollPanel(), get parameters by reference and return result value
*                         REDESIGNED: GuiToggleGroup(), get parameters by reference and return result value
*                         REDESIGNED: GuiComboBox(), get parameters by reference and return result value
*                         REDESIGNED: GuiCheckBox(), get parameters by reference and return result value
*                         REDESIGNED: GuiSlider(), get parameters by reference and return result value
*                         REDESIGNED: GuiSliderBar(), get parameters by reference and return result value
*                         REDESIGNED: GuiProgressBar(), get parameters by reference and return result value
*                         REDESIGNED: GuiListView(), get parameters by reference and return result value
*                         REDESIGNED: GuiColorPicker(), get parameters by reference and return result value
*                         REDESIGNED: GuiColorPanel(), get parameters by reference and return result value
*                         REDESIGNED: GuiColorBarAlpha(), get parameters by reference and return result value
*                         REDESIGNED: GuiColorBarHue(), get parameters by reference and return result value
*                         REDESIGNED: GuiGrid(), get parameters by reference and return result value
*                         REDESIGNED: GuiGrid(), added extra parameter
*                         REDESIGNED: GuiListViewEx(), change parameters order
*                         REDESIGNED: All controls return result as int value
*                         REVIEWED: GuiScrollPanel() to avoid smallish scroll-bars
*                         REVIEWED: All examples and specially controls_test_suite
*                         RENAMED: gui_file_dialog module to gui_window_file_dialog
*                         UPDATED: All styles to include ISO-8859-15 charset (as much as possible)
*
*       3.6 (10-May-2023) ADDED: New icon: SAND_TIMER
*                         ADDED: GuiLoadStyleFromMemory() (binary only)
*                         REVIEWED: GuiScrollBar() horizontal movement key
*                         REVIEWED: GuiTextBox() crash on cursor movement
*                         REVIEWED: GuiTextBox(), additional inputs support
*                         REVIEWED: GuiLabelButton(), avoid text cut
*                         REVIEWED: GuiTextInputBox(), password input
*                         REVIEWED: Local GetCodepointNext(), aligned with raylib
*                         REDESIGNED: GuiSlider*()/GuiScrollBar() to support out-of-bounds
*
*       3.5 (20-Apr-2023) ADDED: GuiTabBar(), based on GuiToggle()
*                         ADDED: Helper functions to split text in separate lines
*                         ADDED: Multiple new icons, useful for code editing tools
*                         REMOVED: Unneeded icon editing functions
*                         REMOVED: GuiTextBoxMulti(), very limited and broken
*                         REMOVED: MeasureTextEx() dependency, logic directly implemented
*                         REMOVED: DrawTextEx() dependency, logic directly implemented
*                         REVIEWED: GuiScrollBar(), improve mouse-click behaviour
*                         REVIEWED: Library header info, more info, better organized
*                         REDESIGNED: GuiTextBox() to support cursor movement
*                         REDESIGNED: GuiDrawText() to divide drawing by lines
*
*       3.2 (22-May-2022) RENAMED: Some enum values, for unification, avoiding prefixes
*                         REMOVED: GuiScrollBar(), only internal
*                         REDESIGNED: GuiPanel() to support text parameter
*                         REDESIGNED: GuiScrollPanel() to support text parameter
*                         REDESIGNED: GuiColorPicker() to support text parameter
*                         REDESIGNED: GuiColorPanel() to support text parameter
*                         REDESIGNED: GuiColorBarAlpha() to support text parameter
*                         REDESIGNED: GuiColorBarHue() to support text parameter
*                         REDESIGNED: GuiTextInputBox() to support password
*
*       3.1 (12-Jan-2022) REVIEWED: Default style for consistency (aligned with rGuiLayout v2.5 tool)
*                         REVIEWED: GuiLoadStyle() to support compressed font atlas image data and unload previous textures
*                         REVIEWED: External icons usage logic
*                         REVIEWED: GuiLine() for centered alignment when including text
*                         RENAMED: Multiple controls properties definitions to prepend RAYGUI_
*                         RENAMED: RICON_ references to RAYGUI_ICON_ for library consistency
*                         Projects updated and multiple tweaks
*
*       3.0 (04-Nov-2021) Integrated ricons data to avoid external file
*                         REDESIGNED: GuiTextBoxMulti()
*                         REMOVED: GuiImageButton*()
*                         Multiple minor tweaks and bugs corrected
*
*       2.9 (17-Mar-2021) REMOVED: Tooltip API
*       2.8 (03-May-2020) Centralized rectangles drawing to GuiDrawRectangle()
*       2.7 (20-Feb-2020) ADDED: Possible tooltips API
*       2.6 (09-Sep-2019) ADDED: GuiTextInputBox()
*                         REDESIGNED: GuiListView*(), GuiDropdownBox(), GuiSlider*(), GuiProgressBar(), GuiMessageBox()
*                         REVIEWED: GuiTextBox(), GuiSpinner(), GuiValueBox(), GuiLoadStyle()
*                         Replaced property INNER_PADDING by TEXT_PADDING, renamed some properties
*                         ADDED: 8 new custom styles ready to use
*                         Multiple minor tweaks and bugs corrected
*
*       2.5 (28-May-2019) Implemented extended GuiTextBox(), GuiValueBox(), GuiSpinner()
*       2.3 (29-Apr-2019) ADDED: rIcons auxiliar library and support for it, multiple controls reviewed
*                         Refactor all controls drawing mechanism to use control state
*       2.2 (05-Feb-2019) ADDED: GuiScrollBar(), GuiScrollPanel(), reviewed GuiListView(), removed Gui*Ex() controls
*       2.1 (26-Dec-2018) REDESIGNED: GuiCheckBox(), GuiComboBox(), GuiDropdownBox(), GuiToggleGroup() > Use combined text string
*                         REDESIGNED: Style system (breaking change)
*       2.0 (08-Nov-2018) ADDED: Support controls guiLock and custom fonts
*                         REVIEWED: GuiComboBox(), GuiListView()...
*       1.9 (09-Oct-2018) REVIEWED: GuiGrid(), GuiTextBox(), GuiTextBoxMulti(), GuiValueBox()...
*       1.8 (01-May-2018) Lot of rework and redesign to align with rGuiStyler and rGuiLayout
*       1.5 (21-Jun-2017) Working in an improved styles system
*       1.4 (15-Jun-2017) Rewritten all GUI functions (removed useless ones)
*       1.3 (12-Jun-2017) Complete redesign of style system
*       1.1 (01-Jun-2017) Complete review of the library
*       1.0 (07-Jun-2016) Converted to header-only by Ramon Santamaria.
*       0.9 (07-Mar-2016) Reviewed and tested by Albert Martos, Ian Eito, Sergio Martinez and Ramon Santamaria.
*       0.8 (27-Aug-2015) Initial release. Implemented by Kevin Gato, Daniel Nicolás and Ramon Santamaria.
*
*   DEPENDENCIES:
*       raylib 5.0  - Inputs reading (keyboard/mouse), shapes drawing, font loading and text drawing
*
*   STANDALONE MODE:
*       By default raygui depends on raylib mostly for the inputs and the drawing functionality but that dependency can be disabled
*       with the config flag RAYGUI_STANDALONE. In that case is up to the user to provide another backend to cover library needs.
*
*       The following functions should be redefined for a custom backend:
*
*           - Vector2 GetMousePosition(void);
*           - float GetMouseWheelMove(void);
*           - bool IsMouseButtonDown(int button);
*           - bool IsMouseButtonPressed(int button);
*           - bool IsMouseButtonReleased(int button);
*           - bool IsKeyDown(int key);
*           - bool IsKeyPressed(int key);
*           - int GetCharPressed(void);         // -- GuiTextBox(), GuiValueBox()
*
*           - void DrawRectangle(int x, int y, int width, int height, Color color); // -- GuiDrawRectangle()
*           - void DrawRectangleGradientEx(Rectangle rec, Color col1, Color col2, Color col3, Color col4); // -- GuiColorPicker()
*
*           - Font GetFontDefault(void);                            // -- GuiLoadStyleDefault()
*           - Font LoadFontEx(const char *fileName, int fontSize, int *codepoints, int codepointCount); // -- GuiLoadStyle()
*           - Texture2D LoadTextureFromImage(Image image);          // -- GuiLoadStyle(), required to load texture from embedded font atlas image
*           - void SetShapesTexture(Texture2D tex, Rectangle rec);  // -- GuiLoadStyle(), required to set shapes rec to font white rec (optimization)
*           - char *LoadFileText(const char *fileName);             // -- GuiLoadStyle(), required to load charset data
*           - void UnloadFileText(char *text);                      // -- GuiLoadStyle(), required to unload charset data
*           - const char *GetDirectoryPath(const char *filePath);   // -- GuiLoadStyle(), required to find charset/font file from text .rgs
*           - int *LoadCodepoints(const char *text, int *count);    // -- GuiLoadStyle(), required to load required font codepoints list
*           - void UnloadCodepoints(int *codepoints);               // -- GuiLoadStyle(), required to unload codepoints list
*           - unsigned char *DecompressData(const unsigned char *compData, int compDataSize, int *dataSize); // -- GuiLoadStyle()
*
*   CONTRIBUTORS:
*       Ramon Santamaria:   Supervision, review, redesign, update and maintenance
*       Vlad Adrian:        Complete rewrite of GuiTextBox() to support extended features (2019)
*       Sergio Martinez:    Review, testing (2015) and redesign of multiple controls (2018)
*       Adria Arranz:       Testing and implementation of additional controls (2018)
*       Jordi Jorba:        Testing and implementation of additional controls (2018)
*       Albert Martos:      Review and testing of the library (2015)
*       Ian Eito:           Review and testing of the library (2015)
*       Kevin Gato:         Initial implementation of basic components (2014)
*       Daniel Nicolas:     Initial implementation of basic components (2014)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
**********************************************************************************************/

extern (C) @nogc nothrow:


enum RAYGUI_VERSION_MAJOR = 4;
enum RAYGUI_VERSION_MINOR = 5;
enum RAYGUI_VERSION_PATCH = 0;
enum RAYGUI_VERSION = "4.5-dev";

// Function specifiers in case library is build/used as a shared library (Windows)
// NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll

// We are building the library as a Win32 shared library (.dll)

// We are using the library as a Win32 shared library (.dll)

// Function specifiers definition // Functions defined as 'extern' by default (implicit specifiers)

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
// Allow custom memory allocators

alias RAYGUI_MALLOC = malloc;

alias RAYGUI_CALLOC = calloc;

alias RAYGUI_FREE = free;

// Simple log system to avoid printf() calls if required
// NOTE: Avoiding those calls, also avoids const strings memory usage

//----------------------------------------------------------------------------------
// Types and Structures Definition
// NOTE: Some types are required for RAYGUI_STANDALONE usage
//----------------------------------------------------------------------------------

// Boolean type

// Vector2 type

// Vector3 type                 // -- ConvertHSVtoRGB(), ConvertRGBtoHSV()

// Color type, RGBA (32bit)

// Rectangle type

// TODO: Texture2D type is very coupled to raylib, required by Font type
// It should be redesigned to be provided by user

// OpenGL texture id
// Texture base width
// Texture base height
// Mipmap levels, 1 by default
// Data format (PixelFormat type)

// Image, pixel data stored in CPU memory (RAM)

// Image raw data
// Image base width
// Image base height
// Mipmap levels, 1 by default
// Data format (PixelFormat type)

// GlyphInfo, font characters glyphs info

// Character value (Unicode)
// Character offset X when drawing
// Character offset Y when drawing
// Character advance position X
// Character image data

// TODO: Font type is very coupled to raylib, mostly required by GuiLoadStyle()
// It should be redesigned to be provided by user

// Base size (default chars height)
// Number of glyph characters
// Padding around the glyph characters
// Texture atlas containing the glyphs
// Rectangles in texture for the glyphs
// Glyphs info data

// Style property
// NOTE: Used when exporting style as code for convenience
struct GuiStyleProp
{
    ushort controlId; // Control identifier
    ushort propertyId; // Property identifier
    int propertyValue; // Property value
}

/*
// Controls text style -NOT USED-
// NOTE: Text style is defined by control
typedef struct GuiTextStyle {
    unsigned int size;
    int charSpacing;
    int lineSpacing;
    int alignmentH;
    int alignmentV;
    int padding;
} GuiTextStyle;
*/

// Gui control state
enum GuiState
{
    STATE_NORMAL = 0,
    STATE_FOCUSED = 1,
    STATE_PRESSED = 2,
    STATE_DISABLED = 3
}

// Gui control text alignment
enum GuiTextAlignment
{
    TEXT_ALIGN_LEFT = 0,
    TEXT_ALIGN_CENTER = 1,
    TEXT_ALIGN_RIGHT = 2
}

// Gui control text alignment vertical
// NOTE: Text vertical position inside the text bounds
enum GuiTextAlignmentVertical
{
    TEXT_ALIGN_TOP = 0,
    TEXT_ALIGN_MIDDLE = 1,
    TEXT_ALIGN_BOTTOM = 2
}

// Gui control text wrap mode
// NOTE: Useful for multiline text
enum GuiTextWrapMode
{
    TEXT_WRAP_NONE = 0,
    TEXT_WRAP_CHAR = 1,
    TEXT_WRAP_WORD = 2
}

// Gui controls
enum GuiControl
{
    // Default -> populates to all controls when set
    DEFAULT = 0,

    // Basic controls
    LABEL = 1, // Used also for: LABELBUTTON
    BUTTON = 2,
    TOGGLE = 3, // Used also for: TOGGLEGROUP
    SLIDER = 4, // Used also for: SLIDERBAR, TOGGLESLIDER
    PROGRESSBAR = 5,
    CHECKBOX = 6,
    COMBOBOX = 7,
    DROPDOWNBOX = 8,
    TEXTBOX = 9, // Used also for: TEXTBOXMULTI
    VALUEBOX = 10,
    SPINNER = 11, // Uses: BUTTON, VALUEBOX
    LISTVIEW = 12,
    COLORPICKER = 13,
    SCROLLBAR = 14,
    STATUSBAR = 15
}

// Gui base properties for every control
// NOTE: RAYGUI_MAX_PROPS_BASE properties (by default 16 properties)
enum GuiControlProperty
{
    BORDER_COLOR_NORMAL = 0, // Control border color in STATE_NORMAL
    BASE_COLOR_NORMAL = 1, // Control base color in STATE_NORMAL
    TEXT_COLOR_NORMAL = 2, // Control text color in STATE_NORMAL
    BORDER_COLOR_FOCUSED = 3, // Control border color in STATE_FOCUSED
    BASE_COLOR_FOCUSED = 4, // Control base color in STATE_FOCUSED
    TEXT_COLOR_FOCUSED = 5, // Control text color in STATE_FOCUSED
    BORDER_COLOR_PRESSED = 6, // Control border color in STATE_PRESSED
    BASE_COLOR_PRESSED = 7, // Control base color in STATE_PRESSED
    TEXT_COLOR_PRESSED = 8, // Control text color in STATE_PRESSED
    BORDER_COLOR_DISABLED = 9, // Control border color in STATE_DISABLED
    BASE_COLOR_DISABLED = 10, // Control base color in STATE_DISABLED
    TEXT_COLOR_DISABLED = 11, // Control text color in STATE_DISABLED
    BORDER_WIDTH = 12, // Control border size, 0 for no border
    //TEXT_SIZE,                  // Control text size (glyphs max height) -> GLOBAL for all controls
    //TEXT_SPACING,               // Control text spacing between glyphs -> GLOBAL for all controls
    //TEXT_LINE_SPACING           // Control text spacing between lines -> GLOBAL for all controls
    TEXT_PADDING = 13, // Control text padding, not considering border
    TEXT_ALIGNMENT = 14 // Control text horizontal alignment inside control text bound (after border and padding)
    //TEXT_WRAP_MODE              // Control text wrap-mode inside text bounds -> GLOBAL for all controls
}

// TODO: Which text styling properties should be global or per-control?
// At this moment TEXT_PADDING and TEXT_ALIGNMENT is configured and saved per control while
// TEXT_SIZE, TEXT_SPACING, TEXT_LINE_SPACING, TEXT_ALIGNMENT_VERTICAL, TEXT_WRAP_MODE are global and
// should be configured by user as needed while defining the UI layout

// Gui extended properties depend on control
// NOTE: RAYGUI_MAX_PROPS_EXTENDED properties (by default, max 8 properties)
//----------------------------------------------------------------------------------
// DEFAULT extended properties
// NOTE: Those properties are common to all controls or global
// WARNING: We only have 8 slots for those properties by default!!! -> New global control: TEXT?
enum GuiDefaultProperty
{
    TEXT_SIZE = 16, // Text size (glyphs max height)
    TEXT_SPACING = 17, // Text spacing between glyphs
    LINE_COLOR = 18, // Line control color
    BACKGROUND_COLOR = 19, // Background color
    TEXT_LINE_SPACING = 20, // Text spacing between lines
    TEXT_ALIGNMENT_VERTICAL = 21, // Text vertical alignment inside text bounds (after border and padding)
    TEXT_WRAP_MODE = 22 // Text wrap-mode inside text bounds
    //TEXT_DECORATION             // Text decoration: 0-None, 1-Underline, 2-Line-through, 3-Overline
    //TEXT_DECORATION_THICK       // Text decoration line thickness
}

// Other possible text properties:
// TEXT_WEIGHT                  // Normal, Italic, Bold -> Requires specific font change
// TEXT_INDENT                  // Text indentation -> Now using TEXT_PADDING...

// Label
//typedef enum { } GuiLabelProperty;

// Button/Spinner
//typedef enum { } GuiButtonProperty;

// Toggle/ToggleGroup
enum GuiToggleProperty
{
    GROUP_PADDING = 16 // ToggleGroup separation between toggles
}

// Slider/SliderBar
enum GuiSliderProperty
{
    SLIDER_WIDTH = 16, // Slider size of internal bar
    SLIDER_PADDING = 17 // Slider/SliderBar internal bar padding
}

// ProgressBar
enum GuiProgressBarProperty
{
    PROGRESS_PADDING = 16 // ProgressBar internal padding
}

// ScrollBar
enum GuiScrollBarProperty
{
    ARROWS_SIZE = 16, // ScrollBar arrows size
    ARROWS_VISIBLE = 17, // ScrollBar arrows visible
    SCROLL_SLIDER_PADDING = 18, // ScrollBar slider internal padding
    SCROLL_SLIDER_SIZE = 19, // ScrollBar slider size
    SCROLL_PADDING = 20, // ScrollBar scroll padding from arrows
    SCROLL_SPEED = 21 // ScrollBar scrolling speed
}

// CheckBox
enum GuiCheckBoxProperty
{
    CHECK_PADDING = 16 // CheckBox internal check padding
}

// ComboBox
enum GuiComboBoxProperty
{
    COMBO_BUTTON_WIDTH = 16, // ComboBox right button width
    COMBO_BUTTON_SPACING = 17 // ComboBox button separation
}

// DropdownBox
enum GuiDropdownBoxProperty
{
    ARROW_PADDING = 16, // DropdownBox arrow separation from border and items
    DROPDOWN_ITEMS_SPACING = 17, // DropdownBox items separation
    DROPDOWN_ARROW_HIDDEN = 18, // DropdownBox arrow hidden
    DROPDOWN_ROLL_UP = 19 // DropdownBox roll up flag (default rolls down)
}

// TextBox/TextBoxMulti/ValueBox/Spinner
enum GuiTextBoxProperty
{
    TEXT_READONLY = 16 // TextBox in read-only mode: 0-text editable, 1-text no-editable
}

// Spinner
enum GuiSpinnerProperty
{
    SPIN_BUTTON_WIDTH = 16, // Spinner left/right buttons width
    SPIN_BUTTON_SPACING = 17 // Spinner buttons separation
}

// ListView
enum GuiListViewProperty
{
    LIST_ITEMS_HEIGHT = 16, // ListView items height
    LIST_ITEMS_SPACING = 17, // ListView items separation
    SCROLLBAR_WIDTH = 18, // ListView scrollbar size (usually width)
    SCROLLBAR_SIDE = 19, // ListView scrollbar side (0-SCROLLBAR_LEFT_SIDE, 1-SCROLLBAR_RIGHT_SIDE)
    LIST_ITEMS_BORDER_WIDTH = 20 // ListView items border width
}

// ColorPicker
enum GuiColorPickerProperty
{
    COLOR_SELECTOR_SIZE = 16,
    HUEBAR_WIDTH = 17, // ColorPicker right hue bar width
    HUEBAR_PADDING = 18, // ColorPicker right hue bar separation from panel
    HUEBAR_SELECTOR_HEIGHT = 19, // ColorPicker right hue bar selector height
    HUEBAR_SELECTOR_OVERFLOW = 20 // ColorPicker right hue bar selector overflow
}

enum SCROLLBAR_LEFT_SIDE = 0;
enum SCROLLBAR_RIGHT_SIDE = 1;

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Module Functions Declaration
//----------------------------------------------------------------------------------

// Prevents name mangling of functions

// Global gui state control functions
void GuiEnable (); // Enable gui controls (global state)
void GuiDisable (); // Disable gui controls (global state)
void GuiLock (); // Lock gui controls (global state)
void GuiUnlock (); // Unlock gui controls (global state)
bool GuiIsLocked (); // Check if gui is locked (global state)
void GuiSetAlpha (float alpha); // Set gui controls alpha (global state), alpha goes from 0.0f to 1.0f
void GuiSetState (int state); // Set gui state (global state)
int GuiGetState (); // Get gui state (global state)

// Font set/get functions
void GuiSetFont (Font font); // Set gui custom font (global state)
Font GuiGetFont (); // Get gui custom font (global state)

// Style set/get functions
void GuiSetStyle (int control, int property, int value); // Set one style property
int GuiGetStyle (int control, int property); // Get one style property

// Styles loading functions
void GuiLoadStyle (const(char)* fileName); // Load style file over global style variable (.rgs)
void GuiLoadStyleDefault (); // Load style default over global style

// Tooltips management functions
void GuiEnableTooltip (); // Enable gui tooltips (global state)
void GuiDisableTooltip (); // Disable gui tooltips (global state)
void GuiSetTooltip (const(char)* tooltip); // Set tooltip string

// Icons functionality
const(char)* GuiIconText (int iconId, const(char)* text); // Get text with icon id prepended (if supported)

void GuiSetIconScale (int scale); // Set default icon drawing size
uint* GuiGetIcons (); // Get raygui icons data pointer
char** GuiLoadIcons (const(char)* fileName, bool loadIconsName); // Load raygui icons file (.rgi) into internal icons data
void GuiDrawIcon (int iconId, int posX, int posY, int pixelSize, Color color); // Draw icon using pixel size at specified position

// Controls
//----------------------------------------------------------------------------------------------------------
// Container/separator controls, useful for controls organization
int GuiWindowBox (Rectangle bounds, const(char)* title); // Window Box control, shows a window that can be closed
int GuiGroupBox (Rectangle bounds, const(char)* text); // Group Box control with text name
int GuiLine (Rectangle bounds, const(char)* text); // Line separator control, could contain text
int GuiPanel (Rectangle bounds, const(char)* text); // Panel control, useful to group controls
int GuiTabBar (Rectangle bounds, const(char*)* text, int count, int* active); // Tab Bar control, returns TAB to be closed or -1
int GuiScrollPanel (Rectangle bounds, const(char)* text, Rectangle content, Vector2* scroll, Rectangle* view); // Scroll Panel control

// Basic controls set
int GuiLabel (Rectangle bounds, const(char)* text); // Label control
int GuiButton (Rectangle bounds, const(char)* text); // Button control, returns true when clicked
int GuiLabelButton (Rectangle bounds, const(char)* text); // Label button control, returns true when clicked
int GuiToggle (Rectangle bounds, const(char)* text, bool* active); // Toggle Button control
int GuiToggleGroup (Rectangle bounds, const(char)* text, int* active); // Toggle Group control
int GuiToggleSlider (Rectangle bounds, const(char)* text, int* active); // Toggle Slider control
int GuiCheckBox (Rectangle bounds, const(char)* text, bool* checked); // Check Box control, returns true when active
int GuiComboBox (Rectangle bounds, const(char)* text, int* active); // Combo Box control

int GuiDropdownBox (Rectangle bounds, const(char)* text, int* active, bool editMode); // Dropdown Box control
int GuiSpinner (Rectangle bounds, const(char)* text, int* value, int minValue, int maxValue, bool editMode); // Spinner control
int GuiValueBox (Rectangle bounds, const(char)* text, int* value, int minValue, int maxValue, bool editMode); // Value Box control, updates input text with numbers
int GuiValueBoxFloat (Rectangle bounds, const(char)* text, char* textValue, float* value, bool editMode); // Value box control for float values
int GuiTextBox (Rectangle bounds, char* text, int textSize, bool editMode); // Text Box control, updates input text

int GuiSlider (Rectangle bounds, const(char)* textLeft, const(char)* textRight, float* value, float minValue, float maxValue); // Slider control
int GuiSliderBar (Rectangle bounds, const(char)* textLeft, const(char)* textRight, float* value, float minValue, float maxValue); // Slider Bar control
int GuiProgressBar (Rectangle bounds, const(char)* textLeft, const(char)* textRight, float* value, float minValue, float maxValue); // Progress Bar control
int GuiStatusBar (Rectangle bounds, const(char)* text); // Status Bar control, shows info text
int GuiDummyRec (Rectangle bounds, const(char)* text); // Dummy control for placeholders
int GuiGrid (Rectangle bounds, const(char)* text, float spacing, int subdivs, Vector2* mouseCell); // Grid control

// Advance controls set
int GuiListView (Rectangle bounds, const(char)* text, int* scrollIndex, int* active); // List View control
int GuiListViewEx (Rectangle bounds, const(char*)* text, int count, int* scrollIndex, int* active, int* focus); // List View with extended parameters
int GuiMessageBox (Rectangle bounds, const(char)* title, const(char)* message, const(char)* buttons); // Message Box control, displays a message
int GuiTextInputBox (Rectangle bounds, const(char)* title, const(char)* message, const(char)* buttons, char* text, int textMaxSize, bool* secretViewActive); // Text Input Box control, ask for text, supports secret
int GuiColorPicker (Rectangle bounds, const(char)* text, Color* color); // Color Picker control (multiple color controls)
int GuiColorPanel (Rectangle bounds, const(char)* text, Color* color); // Color Panel control
int GuiColorBarAlpha (Rectangle bounds, const(char)* text, float* alpha); // Color Bar Alpha control
int GuiColorBarHue (Rectangle bounds, const(char)* text, float* value); // Color Bar Hue control
int GuiColorPickerHSV (Rectangle bounds, const(char)* text, Vector3* colorHsv); // Color Picker control that avoids conversion to RGB on each call (multiple color controls)
int GuiColorPanelHSV (Rectangle bounds, const(char)* text, Vector3* colorHsv); // Color Panel control that updates Hue-Saturation-Value color value, used by GuiColorPickerHSV()
//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------
// Icons enumeration
//----------------------------------------------------------------------------------
enum GuiIconName
{
    ICON_NONE = 0,
    ICON_FOLDER_FILE_OPEN = 1,
    ICON_FILE_SAVE_CLASSIC = 2,
    ICON_FOLDER_OPEN = 3,
    ICON_FOLDER_SAVE = 4,
    ICON_FILE_OPEN = 5,
    ICON_FILE_SAVE = 6,
    ICON_FILE_EXPORT = 7,
    ICON_FILE_ADD = 8,
    ICON_FILE_DELETE = 9,
    ICON_FILETYPE_TEXT = 10,
    ICON_FILETYPE_AUDIO = 11,
    ICON_FILETYPE_IMAGE = 12,
    ICON_FILETYPE_PLAY = 13,
    ICON_FILETYPE_VIDEO = 14,
    ICON_FILETYPE_INFO = 15,
    ICON_FILE_COPY = 16,
    ICON_FILE_CUT = 17,
    ICON_FILE_PASTE = 18,
    ICON_CURSOR_HAND = 19,
    ICON_CURSOR_POINTER = 20,
    ICON_CURSOR_CLASSIC = 21,
    ICON_PENCIL = 22,
    ICON_PENCIL_BIG = 23,
    ICON_BRUSH_CLASSIC = 24,
    ICON_BRUSH_PAINTER = 25,
    ICON_WATER_DROP = 26,
    ICON_COLOR_PICKER = 27,
    ICON_RUBBER = 28,
    ICON_COLOR_BUCKET = 29,
    ICON_TEXT_T = 30,
    ICON_TEXT_A = 31,
    ICON_SCALE = 32,
    ICON_RESIZE = 33,
    ICON_FILTER_POINT = 34,
    ICON_FILTER_BILINEAR = 35,
    ICON_CROP = 36,
    ICON_CROP_ALPHA = 37,
    ICON_SQUARE_TOGGLE = 38,
    ICON_SYMMETRY = 39,
    ICON_SYMMETRY_HORIZONTAL = 40,
    ICON_SYMMETRY_VERTICAL = 41,
    ICON_LENS = 42,
    ICON_LENS_BIG = 43,
    ICON_EYE_ON = 44,
    ICON_EYE_OFF = 45,
    ICON_FILTER_TOP = 46,
    ICON_FILTER = 47,
    ICON_TARGET_POINT = 48,
    ICON_TARGET_SMALL = 49,
    ICON_TARGET_BIG = 50,
    ICON_TARGET_MOVE = 51,
    ICON_CURSOR_MOVE = 52,
    ICON_CURSOR_SCALE = 53,
    ICON_CURSOR_SCALE_RIGHT = 54,
    ICON_CURSOR_SCALE_LEFT = 55,
    ICON_UNDO = 56,
    ICON_REDO = 57,
    ICON_REREDO = 58,
    ICON_MUTATE = 59,
    ICON_ROTATE = 60,
    ICON_REPEAT = 61,
    ICON_SHUFFLE = 62,
    ICON_EMPTYBOX = 63,
    ICON_TARGET = 64,
    ICON_TARGET_SMALL_FILL = 65,
    ICON_TARGET_BIG_FILL = 66,
    ICON_TARGET_MOVE_FILL = 67,
    ICON_CURSOR_MOVE_FILL = 68,
    ICON_CURSOR_SCALE_FILL = 69,
    ICON_CURSOR_SCALE_RIGHT_FILL = 70,
    ICON_CURSOR_SCALE_LEFT_FILL = 71,
    ICON_UNDO_FILL = 72,
    ICON_REDO_FILL = 73,
    ICON_REREDO_FILL = 74,
    ICON_MUTATE_FILL = 75,
    ICON_ROTATE_FILL = 76,
    ICON_REPEAT_FILL = 77,
    ICON_SHUFFLE_FILL = 78,
    ICON_EMPTYBOX_SMALL = 79,
    ICON_BOX = 80,
    ICON_BOX_TOP = 81,
    ICON_BOX_TOP_RIGHT = 82,
    ICON_BOX_RIGHT = 83,
    ICON_BOX_BOTTOM_RIGHT = 84,
    ICON_BOX_BOTTOM = 85,
    ICON_BOX_BOTTOM_LEFT = 86,
    ICON_BOX_LEFT = 87,
    ICON_BOX_TOP_LEFT = 88,
    ICON_BOX_CENTER = 89,
    ICON_BOX_CIRCLE_MASK = 90,
    ICON_POT = 91,
    ICON_ALPHA_MULTIPLY = 92,
    ICON_ALPHA_CLEAR = 93,
    ICON_DITHERING = 94,
    ICON_MIPMAPS = 95,
    ICON_BOX_GRID = 96,
    ICON_GRID = 97,
    ICON_BOX_CORNERS_SMALL = 98,
    ICON_BOX_CORNERS_BIG = 99,
    ICON_FOUR_BOXES = 100,
    ICON_GRID_FILL = 101,
    ICON_BOX_MULTISIZE = 102,
    ICON_ZOOM_SMALL = 103,
    ICON_ZOOM_MEDIUM = 104,
    ICON_ZOOM_BIG = 105,
    ICON_ZOOM_ALL = 106,
    ICON_ZOOM_CENTER = 107,
    ICON_BOX_DOTS_SMALL = 108,
    ICON_BOX_DOTS_BIG = 109,
    ICON_BOX_CONCENTRIC = 110,
    ICON_BOX_GRID_BIG = 111,
    ICON_OK_TICK = 112,
    ICON_CROSS = 113,
    ICON_ARROW_LEFT = 114,
    ICON_ARROW_RIGHT = 115,
    ICON_ARROW_DOWN = 116,
    ICON_ARROW_UP = 117,
    ICON_ARROW_LEFT_FILL = 118,
    ICON_ARROW_RIGHT_FILL = 119,
    ICON_ARROW_DOWN_FILL = 120,
    ICON_ARROW_UP_FILL = 121,
    ICON_AUDIO = 122,
    ICON_FX = 123,
    ICON_WAVE = 124,
    ICON_WAVE_SINUS = 125,
    ICON_WAVE_SQUARE = 126,
    ICON_WAVE_TRIANGULAR = 127,
    ICON_CROSS_SMALL = 128,
    ICON_PLAYER_PREVIOUS = 129,
    ICON_PLAYER_PLAY_BACK = 130,
    ICON_PLAYER_PLAY = 131,
    ICON_PLAYER_PAUSE = 132,
    ICON_PLAYER_STOP = 133,
    ICON_PLAYER_NEXT = 134,
    ICON_PLAYER_RECORD = 135,
    ICON_MAGNET = 136,
    ICON_LOCK_CLOSE = 137,
    ICON_LOCK_OPEN = 138,
    ICON_CLOCK = 139,
    ICON_TOOLS = 140,
    ICON_GEAR = 141,
    ICON_GEAR_BIG = 142,
    ICON_BIN = 143,
    ICON_HAND_POINTER = 144,
    ICON_LASER = 145,
    ICON_COIN = 146,
    ICON_EXPLOSION = 147,
    ICON_1UP = 148,
    ICON_PLAYER = 149,
    ICON_PLAYER_JUMP = 150,
    ICON_KEY = 151,
    ICON_DEMON = 152,
    ICON_TEXT_POPUP = 153,
    ICON_GEAR_EX = 154,
    ICON_CRACK = 155,
    ICON_CRACK_POINTS = 156,
    ICON_STAR = 157,
    ICON_DOOR = 158,
    ICON_EXIT = 159,
    ICON_MODE_2D = 160,
    ICON_MODE_3D = 161,
    ICON_CUBE = 162,
    ICON_CUBE_FACE_TOP = 163,
    ICON_CUBE_FACE_LEFT = 164,
    ICON_CUBE_FACE_FRONT = 165,
    ICON_CUBE_FACE_BOTTOM = 166,
    ICON_CUBE_FACE_RIGHT = 167,
    ICON_CUBE_FACE_BACK = 168,
    ICON_CAMERA = 169,
    ICON_SPECIAL = 170,
    ICON_LINK_NET = 171,
    ICON_LINK_BOXES = 172,
    ICON_LINK_MULTI = 173,
    ICON_LINK = 174,
    ICON_LINK_BROKE = 175,
    ICON_TEXT_NOTES = 176,
    ICON_NOTEBOOK = 177,
    ICON_SUITCASE = 178,
    ICON_SUITCASE_ZIP = 179,
    ICON_MAILBOX = 180,
    ICON_MONITOR = 181,
    ICON_PRINTER = 182,
    ICON_PHOTO_CAMERA = 183,
    ICON_PHOTO_CAMERA_FLASH = 184,
    ICON_HOUSE = 185,
    ICON_HEART = 186,
    ICON_CORNER = 187,
    ICON_VERTICAL_BARS = 188,
    ICON_VERTICAL_BARS_FILL = 189,
    ICON_LIFE_BARS = 190,
    ICON_INFO = 191,
    ICON_CROSSLINE = 192,
    ICON_HELP = 193,
    ICON_FILETYPE_ALPHA = 194,
    ICON_FILETYPE_HOME = 195,
    ICON_LAYERS_VISIBLE = 196,
    ICON_LAYERS = 197,
    ICON_WINDOW = 198,
    ICON_HIDPI = 199,
    ICON_FILETYPE_BINARY = 200,
    ICON_HEX = 201,
    ICON_SHIELD = 202,
    ICON_FILE_NEW = 203,
    ICON_FOLDER_ADD = 204,
    ICON_ALARM = 205,
    ICON_CPU = 206,
    ICON_ROM = 207,
    ICON_STEP_OVER = 208,
    ICON_STEP_INTO = 209,
    ICON_STEP_OUT = 210,
    ICON_RESTART = 211,
    ICON_BREAKPOINT_ON = 212,
    ICON_BREAKPOINT_OFF = 213,
    ICON_BURGER_MENU = 214,
    ICON_CASE_SENSITIVE = 215,
    ICON_REG_EXP = 216,
    ICON_FOLDER = 217,
    ICON_FILE = 218,
    ICON_SAND_TIMER = 219,
    ICON_WARNING = 220,
    ICON_HELP_BOX = 221,
    ICON_INFO_BOX = 222,
    ICON_PRIORITY = 223,
    ICON_LAYERS_ISO = 224,
    ICON_LAYERS2 = 225,
    ICON_MLAYERS = 226,
    ICON_MAPS = 227,
    ICON_HOT = 228,
    ICON_229 = 229,
    ICON_230 = 230,
    ICON_231 = 231,
    ICON_232 = 232,
    ICON_233 = 233,
    ICON_234 = 234,
    ICON_235 = 235,
    ICON_236 = 236,
    ICON_237 = 237,
    ICON_238 = 238,
    ICON_239 = 239,
    ICON_240 = 240,
    ICON_241 = 241,
    ICON_242 = 242,
    ICON_243 = 243,
    ICON_244 = 244,
    ICON_245 = 245,
    ICON_246 = 246,
    ICON_247 = 247,
    ICON_248 = 248,
    ICON_249 = 249,
    ICON_250 = 250,
    ICON_251 = 251,
    ICON_252 = 252,
    ICON_253 = 253,
    ICON_254 = 254,
    ICON_255 = 255
}

// RAYGUI_H