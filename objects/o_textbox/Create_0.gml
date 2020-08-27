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
color_default = undefined;
typing_rate = 0.3; // rate of 1 means typing increments once each frame
typing_increment = 2; // how far to increase cursor each increment
autoupdate = true;
width = 500;
height = 70;
alignment = TB_ALIGN.LEFT;

/// @desc Set the text, effects included, of the textbox.
function set_text(text) {
	characters = generate_lines(text);
	var _x = 0;
	var _y = 0;
	for (var i = 0; i < array_length(characters); i++) {
		var new_y = 0;
		_x = 0;
		for (var k = 0; k < array_length(characters[i]); k++) {
			characters[i][k].char_x = _x;
			characters[i][k].char_y = _y;
			_x += characters[i][k].width;
			if (characters[i][k].height > new_y) new_y = characters[i][k].height;
		}
		_y += new_y;
	}
}

/// @desc Create array of lines.
function generate_lines(text) {
	var words = generate_words(text);
	var lines = ds_list_create();
	var line = ds_list_create();
	for (var i = 0; i < array_length(words); i++) {
		var word = words[i];
		var word_width = get_char_list_width(word);
		var line_width = get_char_list_width(line);
		if (line_width + word_width > width) {
			if (ds_list_size(line) == 0) show_error("Textbox width too small! Some words are wider than the textbox!", true);
			ds_list_add(lines, line);
			line = word;
		} else for (var w = 0; w < ds_list_size(word); w++) ds_list_add(line, ds_list_find_value(word, w));
	}
	
	/* Here, we remove spaces from the ends of lines depending on the text alignment of the box. */
	if (alignment == TB_ALIGN.LEFT) {
		for (var i = 0; i < array_length(lines); i++) {
			
		}
	}
	if (alignment == TB_ALIGN.RIGHT) {
		
	}
	if (alignment == TB_ALIGN.CENTER) {
		
	}
	
	return lines;
}

/// @desc Create array of "words", or char arrays.
function generate_words(text) {
	var list = generate_chars(text); // recall this is linked list
	var words = ds_list_create();
	var word = ds_list_create();
	while (list != undefined) {
		var char = list.data;
		if (char.character == " ") {
			if (ds_list_size(word) > 0) {
				ds_list_add(words, word);
				word = ds_list_create();
			}
			var temp = ds_list_create();
			ds_list_add(temp, char);
			ds_list_add(words, temp);
		} else ds_list_add(word, char);
		list = list.next;
	}
	ds_list_add(words, word);
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
	var effect = undefined;
	var color = color_default;
	var font = font_default;
	var param_mode = 0; // 0 for detect param, 1 for detect value
	var param_detect = "";
	var value_detect = "";
	for (var i = 1; i <= string_length(text); i++) { // recall that strings are 1 based in gml
		var c = string_char_at(text, i);
		if (mode == 0) {
			if (c == "<") { // detect start of param tag
				param_mode = 0;
				param_detect = "";
				value_detect = "";
				mode = 1;
			} else {
				/* When adding the first character, we simply set the data of the first node. For
				all other elements, we create a new node and set the data of that new node. This avoids
				adding an empty final node. */
				if (tail.data == undefined) tail.data = new tb_character(c, font, color, effect);
				else {
					tail.next = { // the debugger does not show this line as working, very frustrating
						data: new tb_character(c, font, color, effect),
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
	return head;
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
	for (var i = 0; i <= cursor_row; i++) {
		for (var k = 0; k <= cursor_char; k++) {
			characters[i][k].update();
		}
	}
}