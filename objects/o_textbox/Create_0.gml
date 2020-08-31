/* The text of a textbox is a 2D array of character structs. When text is assigned to the textbox,
all of the characters are assigned a specific x and y location based on font size, and width of
other characters. There are two cursors for the textbox: a row cursor, and a char cursor. The row
keeps track of what row has been typed, and the char keeps track of what char in that row has been
typed. We do not use the term "column" because not all chars are the same width, and so the concept
does not apply. */

characters = undefined; // character array
cursor_row = -1;
cursor_char = -1;
font_default = undefined;
color_default = draw_get_color();
effect_default = undefined;
typing_rate = 0.3; // rate of 1 means typing increments once each frame
typing_increment = 2; // how far to increase cursor each increment
autoupdate = true;
width = 400;
height = 700;
alignment = TB_ALIGN.LEFT;

/// @desc Set the text, effects included, of the textbox.
function set_text(text) {
	var chars = generate_lines(text); // recall this is a 2D list
	characters = array_create(ds_list_size(chars)); // characters must be an array
	var _x = 0;
	var _y = 0;
	for (var i = 0; i < array_length(characters); i++) {
		characters[i] = array_create(ds_list_size(chars[|i]));
		var new_y = 0;
		_x = 0;
		for (var k = 0; k < array_length(characters[i]); k++) {
			characters[i][k] = chars[|i][|k];
			characters[i][k].set_char_x(_x);
			characters[i][k].set_char_y(_y);
			_x += characters[i][k].width;
			if (characters[i][k].height > new_y) new_y = characters[i][k].height;
		}
		ds_list_destroy(chars[|i]);
		_y += new_y;
	}
	ds_list_destroy(chars);
}

/// @desc Create array of lines.
function generate_lines(text) {
	var words = generate_words(text);
	var lines = ds_list_create();
	var line = ds_list_create();
	for (var i = 0; i < ds_list_size(words); i++) {
		var word = words[|i];
		var word_width = get_char_list_width(word);
		var line_width = get_char_list_width(line);
		if (line_width + word_width > width) {
			if (ds_list_size(line) == 0) show_error("Textbox width too small! Some words are wider than the textbox!", true);
			ds_list_add(lines, line);
			/* The current word is too big, so it become the start of the new line. But note, we don't simply do line = word.
			Instead we create a new list, and append all the elements in word to line. Why? It's because we have to destory 
			the 2D word list later. If we do line = word, we're simply assigning line to reference the same list as word, 
			which is a list in words. If we did this, when we destoryed the words list, we'd also be destroying lines. */
			line = ds_list_create()
			for (var w = 0; w < ds_list_size(word); w++) ds_list_add(line, word[|w]); // joine line and word lists
		} else for (var w = 0; w < ds_list_size(word); w++) ds_list_add(line, word[|w]); // join line and word lists
		ds_list_destroy(word); // this is also words[|i]
	}
	ds_list_destroy(words);
	if (ds_list_size(line) > 0) ds_list_add(lines, line);
	/* Here, we remove spaces from the ends of lines depending on the text alignment of the box. 
	Recall that each line is a list of characters, not of words. For convenience, we're reusing
	some variables from above. */
	if (alignment == TB_ALIGN.LEFT) {
		for (var i = 0; i < ds_list_size(lines); i++) {
			line = lines[|i];
			while (line[|0].character == " ") ds_list_delete(line, 0);
		}
	}
	if (alignment == TB_ALIGN.RIGHT) {
		for (var i = 0; i < ds_list_size(lines); i++) {
			line = lines[|i];
			while (line[|ds_list_size(line) - 1].character == " ") ds_list_delete(line, ds_list_size(line) - 1);
		}
	}
	if (alignment == TB_ALIGN.CENTER) {
		// delete spaces from both sides
		for (var i = 0; i < ds_list_size(lines); i++) {
			line = lines[|i];
			while (line[|0].character == " ") ds_list_delete(line, 0);
			while (line[|ds_list_size(line) - 1].character == " ") ds_list_delete(line, ds_list_size(line) - 1);
		}
	}
	return lines;
}

/* This function returns a 2D ds_list. Do not forget to destroy it once
you are finished with it. */
/// @desc Create array of "words", or char arrays.
function generate_words(text) {
	var list = generate_chars(text); // recall this is linked list
	var words = ds_list_create();
	var word = ds_list_create();
	while (list != undefined) {
		var char = list.data;
		if (char.character == " ") { // check if space reached
			/* Spaces are treated as their own word for line wrapping. So we
			add whatever exists of `word` to `words` as well as adding the 
			space itself. But in the case of consecutive spaces, we need to
			check to only add `word` if it contains any characters. */
			if (ds_list_size(word) > 0) {
				ds_list_add(words, word);
				word = ds_list_create();
			}
			// now add the space by itself
			var temp = ds_list_create();
			ds_list_add(temp, char);
			ds_list_add(words, temp);
		} else ds_list_add(word, char);
		list = list.next;
	}
	// Add last word. Note last word will be empty if last char is space.
	if (ds_list_size(word) > 0) ds_list_add(words, word);
	return words;
}

/// @desc Create a linked list of chars from text with effects parsed.
function generate_chars(text) {
	var head = {
		data: undefined,
		next: undefined
	};
	var tail = head;
	var mode = 0; // 0 for parsing text, 1 for parsing effects
	var effect = effect_default;
	var color = color_default;
	var font = font_default;
	var param_mode = 0; // 0 for detect param, 1 for detect value
	var param_detect = "";
	var value_detect = "";
	for (var i = 1; i <= string_length(text); i++) { // recall that strings are 1 based in gml
		var c = string_char_at(text, i);
		if (mode == 0) {
			if (c == "<") { // detect start of param tag
				mode = 1;
				param_mode = 0;
				param_detect = "";
				value_detect = "";
			} else {
				/* When adding the first character, we simply set the data of the first node. For
				all other elements, we create a new node and set the data of that new node. This avoids
				adding an empty final node. */
				if (tail.data == undefined) tail.data = new tb_character(c, font, color, effect, i);
				else {
					tail.next = { // the debugger does not show this line as working, very frustrating
						data: new tb_character(c, font, color, effect, i),
						next: undefined
					};
					tail = tail.next;
				}
			}
		} else {
			if (param_mode == 0) {
				if (c == " ") param_mode = 1; // detect start of value detection
				else param_detect += c;
			} else {
				if (c != ">") value_detect += c;
				else {
					mode = 0;
					param_detect = string_lower(param_detect);
					value_detect = string_lower(value_detect);
					if (param_detect == "color") {
						if (value_detect == "default") color = color_default;
						else color = get_tb_color(value_detect);
					}
					if (param_detect == "font") {
						font = font_default;
					}
					if (param_detect == "effect") {
						if (value_detect == "none") effect = TB_EFFECT.NONE;
						else if (value_detect == "wave") effect = TB_EFFECT.WAVE;
						else if (value_detect == "shake") effect = TB_EFFECT.SHAKE;
						else if (value_detect == "float") effect = TB_EFFECT.FLOAT;
					}
					if (param_detect == "reset" && value_detect == "all") {
						font = font_default;
						color = color_default;
						effect = effect_default;
					}
				}
			}
		}
	}
	return head;
}

function get_tb_color(new_color) {
	var color_change = undefined;
	if (new_color == "aqua") color_change = c_aqua;
	if (new_color == "black") color_change = c_black;
	if (new_color == "blue") color_change = c_blue;
	if (new_color == "dkgray") color_change = c_dkgray;
	if (new_color == "fuchsia") color_change = c_fuchsia;
	if (new_color == "gray") color_change = c_gray;
	if (new_color == "green") color_change = c_green;
	if (new_color == "lime") color_change = c_lime;
	if (new_color == "ltgray") color_change = c_ltgray;
	if (new_color == "maroon") color_change = c_maroon;
	if (new_color == "navy") color_change = c_navy;
	if (new_color == "olive") color_change = c_olive;
	if (new_color == "orange") color_change = c_orange;
	if (new_color == "purple") color_change = c_purple;
	if (new_color == "red") color_change = c_red;
	if (new_color == "silver") color_change = c_silver;
	if (new_color == "teal") color_change = c_teal;
	if (new_color == "white") color_change = c_white;
	if (new_color == "yellow") color_change = c_yellow;
	
	// Here we will check for a valid rbg code, assuming a color has not yet been found.
	if (color_change == undefined) {
		var rgb_r = "";
		var rgb_g = "";
		var rgb_b = "";
		var detecting = 0;
		for (var i = 1; i <= string_length(new_color) && detecting < 3; i++) {
			var c = string_char_at(new_color, i);
			if (c == ",") detecting++;
			else {
				if (detecting == 0) rgb_r += c;
				if (detecting == 1) rgb_g += c;
				if (detecting == 2) rgb_b += c;
			}
		}
		try color_change = make_color_rgb(string_digits(rgb_r), string_digits(rgb_g), string_digits(rgb_b));
		catch (error) show_error("Invalid RGB values for textbox! Error: " + error.message, true);
	}
	
	if (color_change == undefined) show_error(string(new_color) + "is an invalid textbox color!", true);
	return color_change;
}

/// @desc Return the pixel width of the given character array
function get_char_list_width(char_list) {
	var result = 0;
	for (var i = 0; i < ds_list_size(char_list); i++) {
		result += ds_list_find_value(char_list, i).width;
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
	for (var i = 0; i < array_length(characters); i++) {
		for (var k = 0; k < array_length(characters[i]); k++) {
			characters[i][k].update();
		}
	}
}
