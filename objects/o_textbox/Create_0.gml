text = ds_list_create(); // ds_list of text structs
cursor_char = 0;
font_default = draw_get_font();
color_default = draw_get_color();
effect_default = TB_EFFECT.NONE;
typing_frames = 3.2; // frames between each "type", values less than 1 result in 0 frames
typing_frames_period = typing_frames * 15;
typing_frames_pause = typing_frames * 10;
typing_increment = 1.7; // how far to increase cursor each increment
typing_time = typing_frames;
autoupdate = true;
width = 800;
height = 700;
alignment = TB_ALIGN.LEFT;

/// @desc Set the text, effects included, of the textbox.
function set_text(text_string) {
	var font = font_default;
	var color = color_default;
	var effect = effect_default;
	for (var i = 0; i < ds_list_size(text); i++) {
		struct_list_destroy(text[|i]);
	}
	ds_list_clear(text);
	var line = ds_list_create();
	var word = ds_list_create();
	
	var index = 1;
	var total_length = string_length(text_string);
	while (index <= total_length) {
		/* As a design choice, end_i and text_end_i will always be set to the last
		character in the parse, INCLUSIVE. So for commands, end_i will be the the
		index of ">". For text, end_i will the location of the next space, the 
		character just before the next "<", or the last character in the string.*/
		
		if (string_char_at(text_string, index) == "<") {
			var end_i = htmlsafe_string_pos_ext(">", text_string, index); // recall string_pos_ext is startpos exlusive
			if (end_i == 0) show_error("Missing >. Effect tag in set_text not closed properly!", true);
			var command_text = string_copy(text_string, index + 1, end_i - index - 1);
			var effects = command_get_effects_arr(command_text, font, color, effect);
			font = effects[@ 0];
			color = effects[@ 1];
			effect = effects[@ 2];
			index = end_i + 1;
		} else {
			
			/* We only parse up to the start of the next tag, or the end of the text_string.
			We subract 1 from the found value because our end_i must always be inclusive. 
			If there is no remaining tags, we set the end of parse to the end of the string.
			Note that we check for <= 0 because, although string_pos_ext returns 0 if no 
			value is found, we are subtracting 1 from it. So the not found value will be
			-1. Finally, for this code, there is no situation where "<" could be at index
			1, so we can ignore that edge case. */
			var parse_end_i = htmlsafe_string_pos_ext("<", text_string, index) - 1;
			if (parse_end_i <= 0) parse_end_i = total_length;
			
			/* To ensure correct line breaks, we have to get all the text from index to the next space,
			or the end of the parsable text. We have to keep track of whether we found a space or not
			because we don't include spaces when checking word width for line breaks. The space must
			be added back once the word position is determined. */
			var end_i = htmlsafe_string_pos_ext(" ", text_string, index);
			var space_found = (end_i > 0 && end_i <= parse_end_i) ? true : false;
			if (end_i > parse_end_i || end_i == 0) end_i = parse_end_i;
			
			// The text we add to the word at first must not include the space.
			var text_toadd_length = (space_found) ? end_i - index : end_i - index + 1;
			var text_toadd = string_copy(text_string, index, text_toadd_length);
			
			word_add_text(word, text_toadd, font, color, effect, index);
			var word_width = text_list_width(word); // note that space is added after
			if (space_found) word_add_text(word, " ", font, color, effect, index);
			if (text_list_width(line) + word_width > width) {
				ds_list_add(text, line);
				line = word;
				word = ds_list_create();
			} else {
				line_add_word(line, word);
				struct_list_clear(word);
			}
			
			index = end_i + 1;
		}
	}
	
	// add remaining line and word values
	if (ds_list_size(line) >  0 || ds_list_size(word) > 0) {
		line_add_word(line, word);
		ds_list_add(text, line);
	}
	struct_list_destroy(word);
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

/* Adds text to existing structs if the effects are the same, otherwise 
creates new ones. */
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

function struct_list_destroy(list) {
	for (var i = 0; i < ds_list_size(list); i++) {
		delete list[|i];
	}
	ds_list_destroy(list);
}

function struct_list_clear(list) {
	for (var i = 0; i < ds_list_size(list); i++) {
		delete list[|i];
	}
	ds_list_clear(list);
}

/* Adds text to existing structs if the effects are the same, otherwise 
creates new ones. */
function word_add_text(word, text, font, color, effect, index) {
	
	if (effect == TB_EFFECT.WAVE || effect == TB_EFFECT.SHAKE) {
		for (var i = 1; i <= string_length(text); i++) {
			var c = string_char_at(text, i);
			ds_list_add(word, new tb_text(font, color, effect, c, index + i));
		}
		return;
	}
	
	// if word is empty, add new struct
	if (ds_list_size(word) == 0) {
		ds_list_add(word, new tb_text(font, color, effect, text, index));
		return;
	}
	
	var last_struct = word[|ds_list_size(word) - 1];
	if (last_struct.font == font &&
		last_struct.text_color == color &&
		last_struct.effect  == effect) {
			last_struct.add_text(text);
	} else {
		ds_list_add(word, new tb_text(font, color, effect, text, index));
	}
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
		if (is_number(rgb_r) && is_number(rgb_g) && is_number(rgb_b)) {
			color_change = make_color_rgb(string_digits(rgb_r), string_digits(rgb_g), string_digits(rgb_b));
		}
	}
	return color_change;
}

/// @desc Returns true if given string contains only number characters.
function is_number(s) {
	return string_digits(s) == s;
}

/// @desc Return the character at the given character index.
function text_char_at(ichar) {
	ichar = floor(ichar);
	for (var irow = 0; irow < ds_list_size(text); irow++) {
		for (var i = 0; i < ds_list_size(text[|irow]); i++) {
			var struct_text = text[|irow][|i].text;
			if (ichar > string_length(struct_text)) ichar -= string_length(struct_text);
			else return string_char_at(struct_text, ichar);	
		}
	}
	return undefined;
}

/// @desc Determine character typing, and update char structs.
function update() {
	if (typing_time <= 0) {
		typing_time += typing_frames;
		
		/* increase character cursor. We iterate over the new
		"typing_increment" number of times. But we stop if we
		encounter punctiation. */
		var _typing_increment = typing_increment;
		while (_typing_increment > 0) {
			if (_typing_increment >= 1) cursor_char++;
			else cursor_char += _typing_increment;
			_typing_increment -= 1;
			var char_at_cursor = text_char_at(cursor_char);
			if (char_at_cursor == ".") {
				_typing_increment = 0;
				typing_time = typing_frames_period;
			}
			if (char_at_cursor == "," || char_at_cursor == ";") {
				_typing_increment = 0;
				typing_time = typing_frames_pause;
			}
		}
	}
	typing_time--;
	
	for (var i = 0; i < ds_list_size(text); i++) {
		for (var k = 0; k < ds_list_size(text[|i]); k++) {
			text[|i][|k].update();
		}
	}
}
