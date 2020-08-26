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
width = 200;
height = 70;

/// @desc Set the text, effects included, of the textbox.
function set_text(text) {

}

/// @desc Create array of "words", or char arrays.
function generate_words(text) {
	var chars = generate_chars(text);
	var words = [];
	var words_i = 0;
	
	var word = [];
	var word_i = 0;
	
	for (var i = 0; i < array_length(chars); i++) {
		var char = chars[i];
		if (char.character == " ") {
			if (array_length(word) > 0) {
				words[words_i++] = word;
				word = [];
				word_i = 0;
			}
			words[words_i++] = [char];
		} else word[word_i++] = char;
	}
	return words;
}

/// @desc Create an array of chars from text with effects parsed.
function generate_chars(text) {
	var chars = [];
	var char_i = 0;
	var mode = 0; // 0 for parsing text, 1 for parsing effects
	var effect = undefined;
	var color = color_default;
	var font = font_default;
	var param_mode = 0; // 0 for detect param, 1 for detect value
	var param_detect = "";
	var value_detect = "";
	for (var i = 0; i < string_length(text); i++) {
		var c = text[i];
		if (mode == 0) {
			if (c == "<") { // detect start of param tag
				param_mode = 0;
				param_detect = "";
				value_detect = "";
				mode = 1;
			} else chars[char_i++] = new tb_character(c, font, color, effect);
		} else {
			if (param_mode == 0) {
				if (c == " ") param_mode = 1; // detect start of value detection
				else param_detect += c;
			} else {
				if (c != ">") value_detect += c;
				else {
					if (param_detect == "color") {
						if (value_detect == "default") color = color_default;
					}
					if (param_detect == "font") {
						font = font_default;
					}
					if (param_detect == "effect") {
						effect = undefined;
					}
				}
			}
		}
	}
}

/// @desc Return the pixel width of the given character array
function get_char_array_width(char_array) {
	var result = 0;
	for (var i = 0; i < array_length(char_array); i++) {
		result += char_array[i].width;
	}
	return result;
}

/// @desc Displays the textbox, and starts typing.
function start() {
	
}

/// @desc Resets textbox and textbox no longer displays
function stop() {
	
}
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