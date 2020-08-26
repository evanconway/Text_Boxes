/* The text of a textbox is a 2D array of character structs. When text is assigned to the textbox,
all of the characters are assigned a specific x and y location based on font size, and width of
other characters. There are two cursors for the textbox: a row cursor, and a char cursor. The row
keeps track of what row has been typed, and the char keeps track of what char in that row has been
typed. We do not use the term "column" because not all chars are the same width, and so the concept
does not apply. */

characters = undefined; // character array
cursor_row = 0;
cursor_char = 0;
font_default = undefined;
color_default = undefined;
typing_rate = 0.3; // rate of 1 means typing increments once each frame
typing_increment = 2; // how far to increase cursor each increment
autoupdate = true;

/// @desc Set auto update to true or false, manually update if false.
/// @param autoupdate
function set_autoupdate(a) {
	autoupdate = a;
}

/// @desc Determine character typing, and update char structs.
function update() {
	for (var i = 0; i <= cursor_row; i++) {
		for (var k = 0; k <= cursor_char; k++) {
			characters[i][k].update();
		}
	}
}