text = ds_list_create(); // ds_list of text structs
text_original_string = undefined; // keep original string of set text
cursor = 0;
cursor_max = 0; // num of chars in text, set by set_text
font_default = f_textbox_default;
color_default = c_white;
effect_default = TB_EFFECT.NONE;

/* Typing time is the time, in milliseconds, between each "type". Note that
if this value is less than the time it takes for one frame to execute, the 
game will "type" once each frame. */
typing_time_default = 100;
typing_time_period = 500;
typing_time_pause = 300;
typing_time = typing_time_default;
type_on_textset = false;

typing_increment = 2.2; // how far to increase cursor each increment
chirp = snd_textbox_default;
chirp_id = undefined;
chirp_gain = 0.5;
autoupdate = true;
width = 500;
height = 500;
alignment_h = fa_center;
alignment_v = fa_center;
text_height = 0; // used for bottom and center align

/// @desc Set the text, effects included, of the textbox.
function set_text(text_string) {
	text_original_string = text_string;
	cursor_max = 0;
	text_height = 0;
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
		/* As a design choice, end_i will always be set to the last character in 
		the parse, INCLUSIVE. So for commands, end_i will be the the index of ">". 
		For text, end_i will the location of the next space, the character just 
		before the next "<", or the last character in the string.*/
		
		if (string_char_at(text_string, index) == "<") {
			var end_i = htmlsafe_string_pos_ext(">", text_string, index); // recall string_pos_ext is startpos exlusive
			if (end_i == 0) show_error("Missing >. Effect tag in set_text not closed properly!", true);
			var command_text = string_copy(text_string, index + 1, end_i - index - 1);
			var effects = command_get_effects(command_text, font, color, effect);
			font = effects.font;
			color = effects.clr;
			effect = effects.effect;
			delete effects;
			index = end_i + 1;
		} else {
			
			/* We only parse up to the start of the next tag, or the end of the text_string.
			We subract 1 from the found value because our end_i must always be inclusive. 
			If there is no remaining tags, we set the end of parse to the end of the string.
			Note that we check for <= 0 because, although string_pos_ext returns 0 if no 
			value is found, we are subtracting 1 from it. So the not found value will be
			-1. Finally, for this code, there is no situation where "<" could be at the
			current index, so we can ignore that edge case. */
			var parse_end_i = htmlsafe_string_pos_ext("<", text_string, index) - 1;
			if (parse_end_i <= 0) parse_end_i = total_length;
			
			/* To ensure correct line breaks, we have to get all the text from index to the next space,
			or the end of the parsable text. We have to keep track of whether we found a space or not
			because we don't include spaces when checking word width for line breaks. The space must
			be added back once the word position is determined. Also, we start from index - 1 because 
			the startpos parameter is exclusive. We need to be able to detect spaces by themselves. */
			var end_i = htmlsafe_string_pos_ext(" ", text_string, index - 1);
			var space_found = (end_i > 0 && end_i <= parse_end_i) ? true : false;
			if (end_i > parse_end_i || end_i == 0) end_i = parse_end_i;
			
			// The text we add to the word at first must not include the space.
			var text_toadd_length = (space_found) ? end_i - index : end_i - index + 1;
			var text_toadd = string_copy(text_string, index, text_toadd_length);
			
			list_add_text(word, text_toadd, font, color, effect, index);
			var word_width = text_list_width(word); // note that space is added after
			
			// determine line break
			if (text_list_width(line) + word_width > width) {
				var examine = text_list_string(line);
				line_remove_last_space(line);
				examine = text_list_string(line);
				ds_list_add(text, line);
				text_height += text_list_height(line);
				cursor_max += text_list_length(line);
				line = word;
				if (space_found) list_add_text(line, " ", font, color, effect, index);
				word = ds_list_create();
			} else {
				line_add_word(line, word);
				if (space_found) list_add_text(line, " ", font, color, effect, index);
				struct_list_clear(word);
			}
			index = end_i + 1;
		}
	}
	
	// add remaining line and word values
	if (ds_list_size(line) >  0 || ds_list_size(word) > 0) {
		line_add_word(line, word);
		line_remove_last_space(line);
		ds_list_add(text, line);
		cursor_max += text_list_length(line);
		text_height += text_list_height(line);
	}
	if (type_on_textset) cursor = cursor_max;
	struct_list_destroy(word);
	return text;
}

/// @desc Set horizontal alignment of text.
function set_align_h(new_align_h) {
	if (new_align_h == alignment_h) {
		return;
	}
	if ((new_align_h != fa_left) && (new_align_h != fa_right) && (new_align_h != fa_center)) {
		show_error("Invalid alignment value!", true);
		return;
	}
	alignment_h = new_align_h;
}

/// @desc Set vertical alignment of text.
function set_align_v(new_align_v) {
	if (new_align_v == alignment_v) {
		return;
	}
	if ((new_align_v != fa_top) && (new_align_v != fa_bottom) && (new_align_v != fa_center)) {
		show_error("Invalid alignment value!", true);
		return;
	}
	alignment_v = new_align_v;
}

function command_get_effects(command_text, _font, _color, _effect) {
	var command = "";
	for (var i = 1; i <= string_length(command_text); i++) {
		var c = string_char_at(command_text, i);
		if (i == string_length(command_text)) command += c;
		if (c == " " || i == string_length(command_text)) {
			command = string_lower(command);
			var new_color = tb_get_color(command);
			if (new_color != undefined) _color = new_color;
			
			// _effects
			if(command == "none") _effect = TB_EFFECT.NONE;
			else if(command == "wave") _effect = TB_EFFECT.WAVE;
			else if(command == "float") _effect = TB_EFFECT.FLOAT;
			else if(command == "shake") _effect = TB_EFFECT.SHAKE;
			command = "";
		} else command += c;
	}
	return { font: _font, clr: _color, effect: _effect };
}

/// @desc Remove space at end of line, if it exists.
function line_remove_last_space(line) {
	if (ds_list_size(line) == 0) return;
	var last_struct = line[|ds_list_size(line) - 1];
	var text_length = string_length(last_struct.text);
	var last_char = string_char_at(last_struct.text, text_length);
	if (last_char == " ") {
		if (text_length == 1) {
			ds_list_delete(line, ds_list_size(line) - 1);
		} else {
			last_struct.set_text(string_delete(last_struct.text, text_length, 1));
		}
	}
}

/// @desc Return true if effect, color, and font of 2 text structs are the same.
function text_struct_equal(a, b) {
	var result = true;
	if (a.font != b.font) result = false;
	if (a.text_color != b.text_color) result = false;
	if (a.effect != b.effect) result = false;
	return result;
}

/// @desc Add text to existing structs if the effects are the same, otherwise create new ones.
function line_add_word(line, word) {
	if (ds_list_size(line) == 0) {
		for (var i = 0; i < ds_list_size(word); i++) ds_list_add(line, word[|i]);
		return;
	} 
	for (var i = 0; i < ds_list_size(word); i++) {
		var last_struct = line[|ds_list_size(line) - 1];
		var word_struct = word[|i];
		if ((text_struct_equal(last_struct, word_struct)) && (word[|i].effect != TB_EFFECT.WAVE) && (word[|i].effect != TB_EFFECT.SHAKE)) {
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
function list_add_text(list, text, font, color, effect, index) {
	if (text == "") return;
	if (effect == TB_EFFECT.WAVE || effect == TB_EFFECT.SHAKE) {
		for (var i = 1; i <= string_length(text); i++) {
			var c = string_char_at(text, i);
			ds_list_add(list, new tb_text(font, color, effect, c, index + i));
		}
		return;
	}
	
	// if list is empty, add new struct
	if (ds_list_size(list) == 0) {
		ds_list_add(list, new tb_text(font, color, effect, text, index));
		return;
	}
	
	var last_struct = list[|ds_list_size(list) - 1];
	if ((last_struct.font == font) &&
		(last_struct.text_color == color) &&
		(last_struct.effect  == effect)) {
			last_struct.add_text(text);
	} else {
		ds_list_add(list, new tb_text(font, color, effect, text, index));
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
	debug_delta_time();
	if (cursor < cursor_max) {
		if (typing_time <= 0) {
			typing_time += typing_time_default;
			
			if (chirp != undefined) {
				if (chirp_id != undefined) audio_sound_gain(chirp_id, 0, 30);
				//if (chirp_id != undefined) audio_stop_sound(chirp_id);
				chirp_id = audio_play_sound(chirp, 1, false);
				var chirp_gain_default = audio_sound_get_gain(chirp);
				audio_sound_gain(chirp_id, chirp_gain * chirp_gain_default, 0);
			}
			
			/* increase character cursor. We iterate over the new
			"typing_increment" number of times. But we stop if we
			encounter punctiation. */
			var _typing_increment = typing_increment;
			while (_typing_increment > 0) {
				if (_typing_increment >= 1) cursor++;
				else cursor += _typing_increment;
				_typing_increment -= 1;
				var char_at_cursor = text_char_at(cursor);
				if (char_at_cursor == ".") {
					_typing_increment = 0;
					typing_time += typing_time_period;
				}
				if (char_at_cursor == "," || char_at_cursor == ";") {
					_typing_increment = 0;
					typing_time += typing_time_pause;
				}
			}
		}
		
		/* Note that delta_time is the time in microseconds since the last frame. Our
		time variables are in milliseconds. */
		typing_time -= global.DELTA_TIME / 1000;
	}
	
	for (var i = 0; i < ds_list_size(text); i++) {
		for (var k = 0; k < ds_list_size(text[|i]); k++) {
			text[|i][|k].update();
		}
	}
}
