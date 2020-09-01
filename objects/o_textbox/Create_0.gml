

text = undefined; // ds_list of text structs
cursor_row = -1;
cursor_char = -1;
font_default = draw_get_font();
color_default = draw_get_color();
effect_default = TB_EFFECT.NONE;
typing_rate = 0.3; // rate of 1 means typing increments once each frame
typing_increment = 2; // how far to increase cursor each increment
autoupdate = true;
width = 400;
height = 700;
alignment = TB_ALIGN.LEFT;

/// @desc Set the text, effects included, of the textbox.
function set_text(text_string) {
	show_debug_message("set text called");
	var font = font_default;
	var color = color_default;
	var effect = effect_default;
	if (text != undefined) {
		for (var i = 0; i < ds_list_size(text); i++) {
			ds_list_destroy(text[|i]);
		}
	}
	show_debug_message("Previous text list destroyed.");
	text = ds_list_create();
	var line = ds_list_create();
	var word = ds_list_create();
	
	// iterate over every character in the string
	for (var i = 1; i <= string_length(text_string); i++) {
		var c = string_char_at(text_string, i);
		show_debug_message("top of loop, index: " + string(i) + " character: " + c);
		
		// determine if checking for text or effect tags
		if (c == "<") {
			var start_i = i + 1;
			var end_i = string_pos_ext(">", text_string, start_i);
			show_debug_message("parsing effect tag from index: " + string(i) + " to " + string(end_i));
			var command_text = string_copy(text_string, i + 1, end_i - i - 1);
			var effects = command_get_effects_arr(command_text, font, color, effect);
			font = effects[0];
			color = effects[1];
			effect = effects[2];
			i = end_i;
			show_debug_message("Effects parsed! Index set to " + string(i));
		} else {
			// add character logic
			show_debug_message("adding character '" + c + "' to word.");
			if (c == " ") {
				var line_width = text_list_width(line);
				var word_width = text_list_width(word);
				if (line_width + word_width > width) {
					ds_list_add(text, line);
					word_add_char(word, c, font, color, effect, i); // add space after checking width
					line = word;
					word = ds_list_create();
				} else {
					word_add_char(word, c, font, color, effect, i);
					line_add_word(line, word);
					word = ds_list_create();
				}
			} else word_add_char(word, c, font, color, effect, i);
		}
	}
	
	// add remaining line and word values
	if (ds_list_size(line) >  0 || ds_list_size(word) > 0) {
		line_add_word(line, word);
		ds_list_add(text, line);
	}
	
	show_debug_message("Text generated");
	return text;
}

function command_get_effects_arr(command_text, font, color, effect) {
	var command = "";
	for (var i = 1; i <= string_length(command_text); i++) {
		var c = string_char_at(command_text, i);
		if (i == string_length(command_text)) command += c;
		if (c == " " || i == string_length(command_text)) {
			command = string_lower(command);
			var new_color = tb_get_color(command);
			if (new_color != undefined) color = new_color;
			
			// effects
			if(command == "none") effect = TB_EFFECT.NONE;
			else if(command == "wave") effect = TB_EFFECT.WAVE;
			else if(command == "float") effect = TB_EFFECT.FLOAT;
			else if(command == "shake") effect = TB_EFFECT.SHAKE;
			command = "";
		} else command += c;
	}
	return [font, color, effect];
}

function line_add_word(line, word) {
	if (ds_list_size(line) == 0) {
		for (var i = 0; i < ds_list_size(word); i++) ds_list_add(line, word[|i]);
		return;
	} 
	for (var i = 0; i < ds_list_size(word); i++) {
		var last_struct = line[|ds_list_size(line) - 1];
		if (last_struct.font == word[|i].font &&
			last_struct.text_color == word[|i].text_color &&
			last_struct.effect  == word[|i].effect &&
			word[|i].effect != TB_EFFECT.WAVE &&
			word[|i].effect != TB_EFFECT.SHAKE) {
			last_struct.add_text(word[|i].text);
		} else ds_list_add(line, word[|i]);
	}
}

function word_add_char(word, character, font, color, effect, index) {
	if (ds_list_size(word) == 0) {
		ds_list_add(word, new tb_text(font, color, effect, character, index));
		return;
	}
	if (effect != TB_EFFECT.WAVE && effect != TB_EFFECT.SHAKE) {
		var last_struct = word[|ds_list_size(word) - 1];
		last_struct.add_text(character);
	} else ds_list_add(word, new tb_text(font, color, effect, character, index));
}

function tb_get_color(new_color) {
	var color_change = undefined;
	if (new_color == "default") color_change = color_default;
	else if (new_color == "aqua") color_change = c_aqua;
	else if (new_color == "black") color_change = c_black;
	else if (new_color == "blue") color_change = c_blue;
	else if (new_color == "dkgray") color_change = c_dkgray;
	else if (new_color == "fuchsia") color_change = c_fuchsia;
	else if (new_color == "gray") color_change = c_gray;
	else if (new_color == "green") color_change = c_green;
	else if (new_color == "lime") color_change = c_lime;
	else if (new_color == "ltgray") color_change = c_ltgray;
	else if (new_color == "maroon") color_change = c_maroon;
	else if (new_color == "navy") color_change = c_navy;
	else if (new_color == "olive") color_change = c_olive;
	else if (new_color == "orange") color_change = c_orange;
	else if (new_color == "purple") color_change = c_purple;
	else if (new_color == "red") color_change = c_red;
	else if (new_color == "silver") color_change = c_silver;
	else if (new_color == "teal") color_change = c_teal;
	else if (new_color == "white") color_change = c_white;
	else if (new_color == "yellow") color_change = c_yellow;
	
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
		catch (e) {};
	}
	return color_change;
}

/// @desc Determine character typing, and update char structs.
function update() {
	if (text == undefined) return;
	for (var i = 0; i < ds_list_size(text); i++) {
		for (var k = 0; k < ds_list_size(text[|i]); k++) {
			text[|i][|k].update();
		}
	}
}
