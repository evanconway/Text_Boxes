text = ds_list_create(); // ds_list of text structs
text_original_string = undefined; // keep original string of set text
effects_default = new JTT_Text(); // effect data is stored in an unused text struct

/* Typing time is the time, in milliseconds, between each "type". Note that
if this value is less than the time it takes for one frame to execute, the 
game will "type" once each frame. */
typing_time_default = 100;
typing_time_period = 500;
typing_time_pause = 300;
typing_time = 0;

typing_increment = 2.2; // how far to increase cursor each increment
chirp = snd_textbox_default;
chirp_id = undefined;
chirp_gain = 0.5;
autoupdate = true;
textbox_width = 300;
textbox_height = 100;
alignment_text_h = fa_left;
alignment_text_v = fa_top;
text_height = 0; // used for bottom and center align, calculated in next_page
alignment_box_h = fa_center;
alignment_box_v = fa_center;

reading_mode = 0; // 0 for pages, 1 for scrolling
scroll_modifier = 0;
scroll_increment = 0.3;
cursor = 0;
cursor_row = 0;

/* This value is the point from the edge of the text box at which scrolling
text will begin to fade out. The alpha value of a row of text is set to its
distance from the edge divided by this value. */ 
scroll_fade_bound = 10;

/* Both of these indicies are inclusive, they are the rows to
be displayed. They being undefined, and are set by calling
jtt_next_page. */
row_i_start = undefined;
row_i_end = undefined;

/// @desc Set the text, effects included, of the textbox.
function set_text(text_string) {
	text_original_string = text_string;
	var effects = new JTT_Text("", effects_default); // effects copied from default
	for (var i = 0; i < ds_list_size(text); i++) {
		ds_list_destroy(text[|i]);
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
			effects = command_apply_effects(command_text, effects);
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
			
			text_list_add(word, text_toadd, effects, index);
			var word_width = text_list_width(word); // note that space is added after
			
			// determine line break
			if (text_list_width(line) + word_width > textbox_width) {
				line_remove_last_space(line); // so lines neither start nor end with spaces, makes align easy
				ds_list_add(text, line);
				line = word;
				if (space_found) text_list_add(line, " ", effects, index);
				word = ds_list_create();
			} else {
				line_add_word(line, word);
				if (space_found) text_list_add(line, " ", effects, index);
				ds_list_clear(word);
			}
			index = end_i + 1;
		}
	}
	
	// add remaining line and word values
	if (ds_list_size(line) >  0 || ds_list_size(word) > 0) {
		line_add_word(line, word);
		line_remove_last_space(line);
		ds_list_add(text, line);
	}
	ds_list_destroy(word);
	return text;
}

/// @desc Set horizontal alignment of text.
function set_text_align_h(new_align_h) {
	if (new_align_h == alignment_text_h) {
		return;
	}
	if ((new_align_h != fa_left) && (new_align_h != fa_right) && (new_align_h != fa_center)) {
		show_error("Invalid alignment value!", true);
		return;
	}
	alignment_text_h = new_align_h;
}

/// @desc Set vertical alignment of text.
function set_text_align_v(new_align_v) {
	if (new_align_v == alignment_text_v) {
		return;
	}
	if ((new_align_v != fa_top) && (new_align_v != fa_bottom) && (new_align_v != fa_center)) {
		show_error("Invalid alignment value!", true);
		return;
	}
	alignment_text_v = new_align_v;
}

/// @desc Set horizontal alignment of box.
function set_box_align_h(new_align_h) {
	if (new_align_h == alignment_box_h) {
		return;
	}
	if ((new_align_h != fa_left) && (new_align_h != fa_right) && (new_align_h != fa_center)) {
		show_error("Invalid alignment value!", true);
		return;
	}
	alignment_box_h = new_align_h;
}

/// @desc Set vertical alignment of box.
function set_box_align_v(new_align_v) {
	if (new_align_v == alignment_box_v) {
		return;
	}
	if ((new_align_v != fa_top) && (new_align_v != fa_bottom) && (new_align_v != fa_center)) {
		show_error("Invalid alignment value!", true);
		return;
	}
	alignment_box_v = new_align_v;
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

/// @desc Add text to existing structs if the effects are the same, otherwise create new ones.
function line_add_word(line, word) {
	if (ds_list_size(line) == 0) {
		for (var i = 0; i < ds_list_size(word); i++) ds_list_add(line, word[|i]);
		return;
	} 
	for (var i = 0; i < ds_list_size(word); i++) {
		var last_struct = line[|ds_list_size(line) - 1];
		var word_struct = word[|i];
		if (jtt_text_fx_equal(last_struct, word_struct) && !jtt_text_req_ind_struct(word_struct)) {
			last_struct.add_text(word[|i].text);
		} else {
			ds_list_add(line, word[|i]);
		}
	}
}

/// @desc Add text to existing structs if effects are the same, otherwise creates new ones.
function text_list_add(list, text, effects, index) {
	if (text == "") return;
	if (jtt_text_req_ind_struct(effects)) {
		for (var i = 1; i <= string_length(text); i++) {
			var c = string_char_at(text, i);
			ds_list_add(list, new JTT_Text(c, effects, index + i));
		}
		return;
	}
	
	// if list is empty, add new struct
	if (ds_list_size(list) == 0) {
		ds_list_add(list, new JTT_Text(text, effects, index));
		return;
	}
	
	var last_struct = list[|ds_list_size(list) - 1];
	if (jtt_text_fx_equal(effects, last_struct)) {
			last_struct.add_text(text);
	} else {
		ds_list_add(list, new JTT_Text(text, effects, index));
	}
}

/// @desc Return color based on command text.
function tb_get_color(new_color) {
	var color_change = undefined;
	if (new_color == "no_color") color_change = effects_default.text_color;
	else if (new_color == "aqua") color_change = c_aqua;
	else if (new_color == "black") color_change = c_black;
	else if (new_color == "blue") color_change = c_blue;
	else if (new_color == "brown") color_change = make_color_rgb(102, 51, 0);
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

/// @desc Get new effects of given struct based on command_text.
function command_apply_effects(command_text, _effects) {
	if (command_text == "") {
		return new JTT_Text();
	}
	var new_effects = new JTT_Text("", _effects);
	var command = "";
	for (var i = 1; i <= string_length(command_text); i++) {
		var c = string_char_at(command_text, i);
		if (i == string_length(command_text)) command += c;
		if (c == " " || i == string_length(command_text)) {
			command = string_lower(command);
			/* At this point, the "command" string could also include any parameters. The start of 
			parameters is indicated with a colon, and each parameter is separated by a comma. These 
			must be parsed out. */
			var param_i = string_pos(":", command);
			var params = ds_list_create();
			if (param_i > 0) {
				// colon found, parse parameters
				var parameter = "";
				for (var k = param_i + 1; k <= string_length(command); k++) {
					var c = string_char_at(command, k);
					if (k == string_length(command)) parameter += c;
					if ((c == ",") || (k == string_length(command))) {
						/* Parameter complete, note that all effect parameters are numbers,
						so we convert to number before adding to params list. */
						ds_list_add(params, real(string_digits(parameter)));
						parameter = "";
					} else {
						parameter += c;
					}
				}
				command = string_copy(command, 1, param_i - 1);
			}
			
			var new_color = tb_get_color(command);
			if (new_color != undefined) new_effects.text_color = new_color;
			
			// movement effects
			if (command == "no_move") new_effects.effect_m = TB_EFFECT_MOVE.NONE;
			else if (command == "offset") {
				new_effects.effect_m = TB_EFFECT_MOVE.OFFSET;
				var new_offset_x = 0;
				if (params[|0] != undefined) { // x left
					new_offset_x += (params[|0] * -1);
				}
				if (params[|1] != undefined) { // x right
					new_offset_x += params[|1];
				}
				var new_offset_y = 0;
				if (params[|2] != undefined) { // y up
					new_offset_y += (params[|2] * -1);
				}
				if (params[|3] != undefined) { // y down
					new_offset_y += params[|3];
				}
				new_effects.position_offset_x = new_offset_x;
				new_effects.position_offset_y = new_offset_y;
			} else if (command == "wave") {
				new_effects.effect_m = TB_EFFECT_MOVE.WAVE;
				if (params[|0] != undefined) {
					new_effects.wave_magnitude = clamp(params[|0], 1, 10000);
				}
				if (params[|1] != undefined) {
					new_effects.wave_time_max = clamp(params[|1], 1, 10000);
				}
				if (params[|2] != undefined) {
					new_effects.wave_offset = clamp((params[|2] / 1000), 0, 2);
				}
			} else if (command == "float") {
				new_effects.effect_m = TB_EFFECT_MOVE.FLOAT;
				if (params[|0] != undefined) {
					new_effects.float_magnitude = clamp(params[|0], 1, 10000);
				}
				if (params[|1] != undefined) {
					new_effects.float_time_max = clamp(params[|1], 1, 10000);
				}
				if (params[|2] != undefined) {
					new_effects.float_increment = clamp((params[|2] / 1000), 0, 2);
				}
			} else if (command == "shake") {
				new_effects.effect_m = TB_EFFECT_MOVE.SHAKE;
				if (params[|0] != undefined) {
					new_effects.shake_magnitude = clamp(params[|0], 1, 10000);
				}
				if (params[|1] != undefined) {
					new_effects.shake_time_max = clamp(params[|1], 1, 10000);
				}
			} else if (command == "wshake") {
				new_effects.effect_m = TB_EFFECT_MOVE.WSHAKE;
				if (params[|0] != undefined) {
					new_effects.shake_magnitude = clamp(params[|0], 1, 10000);
				}
				if (params[|1] != undefined) {
					new_effects.shake_time_max = clamp(params[|1], 1, 10000);
				}
			}
			
			// alpha effects
			if (command == "no_alpha") new_effects.effect_a = TB_EFFECT_ALPHA.NONE;
			else if (command == "pulse") {
				new_effects.effect_a = TB_EFFECT_ALPHA.PULSE;
				if (params[|0] != undefined) {
					new_effects.pulse_alpha_max = clamp((params[|0] / 1000), new_effects.pulse_alpha_min, 2000);
				}
				if (params[|1] != undefined) {
					new_effects.pulse_alpha_min = clamp((params[|1] / 1000), 0, new_effects.pulse_alpha_max);
				}
				if (params[|2] != undefined) {
					new_effects.pulse_time_max = clamp(params[|2], 1, 10000);
				}
				if (params[|3] != undefined) {
					new_effects.pulse_increment = clamp((params[|3] / 1000), 0, 1000);
				}
			} else if (command == "blink") {
				new_effects.effect_a = TB_EFFECT_ALPHA.BLINK;
				if (params[|0] != undefined) {
					new_effects.blink_alpha_on = clamp((params[|0] / 1000), new_effects.blink_alpha_off, 1000);
				}
				if (params[|1] != undefined) {
					new_effects.blink_alpha_off = clamp((params[|1] / 1000), 0, new_effects.blink_alpha_on);
				}
				if (params[|2] != undefined) {
					new_effects.blink_time_on = clamp(params[|2], 1, 10000);
				}
				if (params[|3] != undefined) {
					new_effects.blink_time_off = clamp(params[|3], 1, 10000);
				}
			}
			
			// color effects
			if (command == "no_color") new_effects.effect_c = TB_EFFECT_COLOR.NONE;
			else if (command == "chromatic") {
				new_effects.effect_c = TB_EFFECT_COLOR.CHROMATIC;
			}
			
			ds_list_destroy(params);
			command = "";
		} else {
			command += c;
		}
	}
	return new_effects;
}

/// @desc Return the character in the text list at the given character index.
function text_list_char_at(list, ichar) {
	ichar = floor(ichar);
	for (var i = 0; i < ds_list_size(list); i++) {
		var struct_text = list[|i].text;
		if (ichar > string_length(struct_text)) ichar -= string_length(struct_text);
		else return string_char_at(struct_text, ichar);	
	}
	return undefined;
}

/// @desc Set new display values to begin displaying text
function jtt_next_page() {
	typing_time = 0;
	text_height = 0;
	scroll_modifier = 0;
	if (reading_mode == 0) { // pages
		/* Find start and end indicies of rows that fit in
		the text box height. */
		
		/* Set start the beginning if undefined, to 
		the next row, or the beginning if row_i_end 
		was already at the end of text. */
		if (row_i_start == undefined) {
			row_i_start = 0;
			row_i_end = 0;
		} else {
			row_i_start = row_i_end + 1;
		}
		if (row_i_start >= ds_list_size(text)) {
			row_i_start = 0;			
		}
		
		/* Set the variables for the first line. The textbox will
		always display a minimum of one line, even if it does
		not fit within the height. */
		var page_height = text_list_height(text[|row_i_start]);
		text_height = page_height;
		
		// Iterate over rows, increase row_i_end if they fit.
		row_i_end = row_i_start;
		var checking = true;
		while (checking && (row_i_end < (ds_list_size(text) - 1))) {
			var next_height = text_list_height(text[|(row_i_end + 1)]);
			if ((page_height + next_height) < textbox_height) {
				row_i_end += 1;
				page_height += next_height;
				text_height += next_height;
			} else {
				checking = false;
			}
		}
	} else if (reading_mode == 1) { // scrolling
		row_i_start = 0;
		row_i_end = ds_list_size(text) - 1;
	}
	
	// set cursor
	cursor = 0
	cursor_row = row_i_start;
}

/// @desc Return true if typing complete.
function jtt_get_typing_finished() {
	if (cursor_row < row_i_end) return false;
	// if we make it here, we can assume cursor row is at final row
	if (cursor < text_list_length(text[|cursor_row])) return false;
	return true;
}

/// @desc Set typing cursor values to finished.
function jtt_set_typing_finished() {
	if (text_original_string != undefined) {
		cursor_row = row_i_end;
		cursor = text_list_length(text[|cursor_row]);
	}
}

/// @desc Determine character typing, and update char structs.
function update() {
	textbox_delta_time();
	
	// typing effect
	if ((row_i_start != undefined) && !jtt_get_typing_finished()) {
		// run update logic until caught up
		while (typing_time <= 0) {
			typing_time += typing_time_default;
			
			/* Play typing chirp sound. Notice that we check if typing_time
			is greater than 0 before running. We only update the audio if
			typing_time has caught up. */
			if ((chirp != undefined) && (typing_time > 0)) {
				if (chirp_id != undefined) audio_sound_gain(chirp_id, 0, 30);
				//if (chirp_id != undefined) audio_stop_sound(chirp_id);
				chirp_id = audio_play_sound(chirp, 1, false);
				var chirp_gain_default = audio_sound_get_gain(chirp);
				audio_sound_gain(chirp_id, chirp_gain * chirp_gain_default, 0);
			}

			/* This loop increases the cursor by typing increment, but stops if it
			encounters punctuation. It also ensures the cursor wraps when reaching
			the end of the row. */
			var row_length = text_list_length(text[|cursor_row]);
			var _typing_increment = typing_increment;
			while (_typing_increment > 0) {
				
				// increase the value of the cursor
				if (_typing_increment >= 1) cursor += 1;
				else cursor += _typing_increment;
				_typing_increment -= 1;
				
				/* Here we calculate cursor wrap. Since our code floors the cursor when
				checking positions, the cursor will not wrap until it is a full integer
				beyond the length of the row. */
				if (cursor >= (row_length + 1)) {
					// We only change the cursor if we're not on the last row
					if (cursor_row < row_i_end) {
						cursor = 1;
						cursor_row += 1;
						row_length = text_list_length(text[|cursor_row]);
					} else {
						cursor = row_length;
					}
				}
				
				var char_at_cursor = text_list_char_at(text[|cursor_row], cursor);
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
		typing_time -= global.TEXTBOX_DELTA_TIME / 1000;
	}
	
	// scrolling effect
	if ((row_i_start != undefined) && (reading_mode == 1)) {
		scroll_modifier -= scroll_increment;
	}
	
	// update text structs
	for (var i = 0; i < ds_list_size(text); i++) {
		for (var k = 0; k < ds_list_size(text[|i]); k++) {
			text[|i][|k].update();
		}
	}
}
