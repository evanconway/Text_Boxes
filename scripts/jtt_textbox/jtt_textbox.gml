
function jtt_textbox() constructor {
	text = ds_list_create(); // ds_list of ds_list of text structs (2d list)
	text_original_string = undefined; // keep original string of set text
	effects_default = new JTT_Text(); // effect data is stored in an unused text struct

	/* Typing time is the time, in milliseconds, between each "type". Note that
	if this value is less than the time it takes for one frame to execute, the 
	game will "type" once each frame. */
	typing_time_default = global.JTT_DEFAULT_TYPING_TIME;
	typing_time_stop = global.JTT_DEFAULT_TYPING_TIME_STOP;
	typing_time_pause = global.JTT_DEFAULT_TYPING_TIME_PAUSE;
	typing_time = 0;
	typing_increment = global.JTT_DEFAULT_TYPING_INCREMENT; // how far to increase cursor each increment

	/* If true, next_page() calls will also call set_typing_page_finished(). Since
	most jtt calls create textboxes that are already typed, the default is 
	true. */
	type_on_nextpage = true; 

	chirp = global.JTT_DEFAULT_TYPING_CHIRP;
	chirp_id = undefined;
	chirp_gain = global.JTT_DEFAULT_TYPING_CHIRP_GAIN;
	textbox_width = undefined;
	textbox_height = undefined;
	alignment_text_h = global.JTT_DEFAULT_ALIGN_TEXT_H;
	alignment_text_v = global.JTT_DEFAULT_ALIGN_TEXT_V;
	text_height = 0; // used for bottom and center align, calculated in next_page
	alignment_box_h = global.JTT_DEFAULT_ALIGN_BOX_H;
	alignment_box_v = global.JTT_DEFAULT_ALIGN_BOX_V;

	textbox_display_mode = 0; // 0 for typing, 1 for scrolling

	scroll_modifier = 0;
	scroll_increment = global.JTT_DEFAULT_SCROLL_INCREMENT;

	/* This value is the point from the edge of the text box at which scrolling
	text will begin to fade out. The alpha value of a row of text is set to its
	distance from the edge divided by this value. */ 
	scroll_fade_bound = global.JTT_DEFAULT_SCROLL_FADE_BOUND;

	/* scroll_end is the distance the bottom of the final line must be from
	the top of the textbox before it stops scrolling. A value of 0 means the
	text will be completely off the textbox before it stops. A value of the
	height of the textbox means it will stop once the last line is at the 
	bottom of the text box. */
	scroll_end = global.JTT_DEFAULT_SCROLL_END; 

	cursor = 0;
	cursor_row = 0;

	/* Both of these indicies are inclusive, they are the rows to
	be displayed. They begin undefined, and are set by calling
	next_page. */
	row_i_start = undefined;
	row_i_end = undefined;

	/// @desc Set the text, effects included, of the textbox.
	/// @func set_text(string)
	set_text = function(text_string) {
	
		// reset typing and display values
		cursor = 0;
		cursor_row = 0;
		row_i_start = undefined;
		row_i_end = undefined;
	
		/* If the textbox width and height are not defined, then the text generated
		will not line wrap, and width/height will be set to the width/height of the
		new text. */
		text_original_string = text_string;
		text_height = 0; // scrolling requires text_height of entire list
		var effects = new JTT_Text("", effects_default); // effects copied from default
		for (var i = 0; i < ds_list_size(text); i++) {
			ds_list_destroy(text[|i]);
		}
		ds_list_clear(text);
		var line = ds_list_create(); // list of text structs
		var word = ds_list_create(); // list of text structs
	
		var index = 1;
		var total_length = string_length(text_string);
		while (index <= total_length) {
			/* As a design choice, end_i will always be set to the last character in 
			the parse, INCLUSIVE. So for commands, end_i will be the the index of ">". 
			For text, end_i will be the location of the next space, the character just 
			before the next "<", or the last character in the string. */
			
			var end_i = undefined;
			
			if (string_char_at(text_string, index) == "<") {
				end_i = htmlsafe_string_pos_ext(">", text_string, index); // recall string_pos_ext is startpos exlusive
				if (end_i == 0) show_error("Missing >. Effect tag in set_text not closed properly!", true);
				var command_text = string_copy(text_string, index + 1, end_i - index - 1);
				
				var _command_arr = parse_command_text(command_text);
				
				/*
				Most commands deal with text effects, but there are some that deal with formatting, or
				changing the lines themselves. We have to do those here, instead of in the apply effects
				function, because we have access to our line data here.
				*/
				
				for (var i = 0; i < array_length(_command_arr); i++) {
					var _command = _command_arr[i].command;
					var _args = _command_arr[i].parameters;
					
					// New line, or line break.
					if (_command == "n") {
						var word_width = text_list_width(word);
						/*
						The first if statement in this code may be wrong. I'm not sure there's ever a situation where
						
						*/
						if ((ds_list_size(line) <= 0) && (ds_list_size(word) <= 0)) {
							text_list_add(line, " ", effects, index); // Wait, why do we add a space? Double check this.
							ds_list_add(text, line);
							line = ds_list_create();
						} else if ((textbox_width != undefined) && ((text_list_width(line) + word_width) > textbox_width)) {
							line_remove_bookend_spaces(line); // so lines neither start nor end with spaces, makes align easy
							ds_list_add(text, line);
							text_height += text_list_height(line); // scrolling requies whole text height
							line = word;
							word = ds_list_create();
						} else {
							line_add_word(line, word);
							line_remove_bookend_spaces(line);
							ds_list_add(text, line);
							line = ds_list_create();
							word = ds_list_create();
						}
					}
					
					// Sprite
					if (_command == "sprite") {
						var _sprite = asset_get_index(_args[0]);
						if (_sprite < 0 || asset_get_type(_args[0]) != asset_sprite) {
							show_error("JTT effect error. There is no sprite with name \"" + _args[0] + "\"", true);
						}
						var _sprite_struct = JTT_Text("", effects);
						_sprite_struct.sprite = _sprite;
						
						/*
						Here we add the sprite struct to the 2D list of structs. For the sake of simplicity, we'll
						always treat sprites as entire words by themselves. So to add this to the text lists, we 
						have to first add the existing word to the text list. 
						*/
						
						/*
						if ((textbox_width != undefined) && ((text_list_width(line) + word_width) > textbox_width)) {
							/*
							If the line has no words in it, this means we've found a word so big, the textbox cannot display it.
							We throw an error to force the user to change something, because our code cannot accomodate this.
	
							if (ds_list_size(line) <= 0) show_error("The texbox is not big enough to display the word: " + text_list_string(word), true);
					
							line_remove_bookend_spaces(line); // so lines neither start nor end with spaces, makes align easy
							ds_list_add(text, line);
							text_height += text_list_height(line); // scrolling requies whole text height
							line = word;
							if (space_found) text_list_add(line, " ", effects, index);
							word = ds_list_create();
						} else {
							line_add_word(line, word);
							if (space_found) text_list_add(line, " ", effects, index);
							ds_list_clear(word);
						}
						*/
						
					}
				}
				
				effects = command_apply_effects(_command_arr, effects);
				//effects = command_apply_effects(command_text, effects);
			} else {
				
				/* Recall that at this point in the code, we're inside a loop attempting to parse text. Our
				job here is to find the next valid word, add it to the current line, and figure out line 
				breaks when adding words and lines to the text array. */
				
				/* When parsing non-command text, we first determine the end of the non-command text
				using parse_end_i. We only parse up to the start of the next tag, or the end of the 
				text_string. */
				var parse_end_i = htmlsafe_string_pos_ext("<", text_string, index);
				
				// We subract 1 from the found value because we want our indices to be inclusive.
				parse_end_i -= 1;
				
				/* If there are no remaining tags, we set the end of parse to the end of the string.
				Note that we check for < 0 because, although string_pos_ext returns 0 if no 
				value is found, we are subtracting 1 from it. So the "not found" value will be
				-1. Finally, for this code, there is no situation where "<" could be at the
				current index, which would result in parse_end_i equaling 0. So we can ignore that
				edge case. */
				if (parse_end_i < 0) parse_end_i = total_length;
				
				/* Now we set the position of end_i. Recall from above that end_i will be set to one of
				three places: the position of the next space, the position of character before the next
				"<", or the position of the final character. We do that by calling string_pos_ext. Note
				that we start from index - 1 because the startpos parameter is exclusive, but we want to
				treat our index as inclusive. */
				end_i = htmlsafe_string_pos_ext(" ", text_string, index - 1);
				
				/*
				However, recall that we only parse between index and parse_end_i. This function ignores the
				value of parse_end_i, and so end_i could end up beyond it. We need to clean up the results
				here. Recall that string_pos_ext returns 0 if the given character is not found:
					1. If end_i is 0, then no space was found between index and the end of the string. This 
					means all text between index and parse_end_i is valid, so we set end_i to equal parse_end_i.
					2. If end_i is greater than parse_end_i, then all the text between index and parse_end_i
					is valid, so we set end_i to equal parse_end_i.
					3. If end_i is greater than 0, but less than or equal to parse_end_i, then its current 
					is already correct. We make no changes. */
				if (end_i > parse_end_i || end_i == 0) end_i = parse_end_i;
				
				/* Here we mark some flags to determine which of the three outcomes we got for end_i. Although
				we will always add text to the current word, we will only attempt to add the word to the 
				current line if either a space was found, or we've reached the end of the string. */
				var space_found = (string_char_at(text_string, end_i) == " ");
				var end_of_string = (end_i == total_length);
				
				/* Here we now know how much of the text string to add to the current word. But since we do not
				include spaces when determining the pixel width of a word, we leave the final character of our
				valid text off when we've found a space. That final character is, of course, a space. It will be
				added back later. */
				var text_toadd_length = (space_found) ? end_i - index : end_i - index + 1;
				var text_toadd = string_copy(text_string, index, text_toadd_length);
				text_list_add(word, text_toadd, effects, index);
				var word_width = text_list_width(word); // note that space is added after
				
				/* Now we can determine if we add a word to the current line. If we found a space, or we reached the end 
				of the string, then we can add a word to the current line. This is also where we determine line breaks. */
				if (space_found || end_of_string) {
					
					var new_line_word = text_add_word(word, line, space_found, index, effects);
					word = new_line_word.word;
					line = new_line_word.line;
					
					/*
					// determine line break
					if ((textbox_width != undefined) && ((text_list_width(line) + word_width) > textbox_width)) {
						/*
						If the line has no words in it, this means we've found a word so big, the textbox cannot display it.
						We throw an error to force the user to change something, because our code cannot accomodate this.
						//
						if (ds_list_size(line) <= 0) show_error("The texbox is not big enough to display the word: " + text_list_string(word), true);
					
						line_remove_bookend_spaces(line); // so lines neither start nor end with spaces, makes align easy
						ds_list_add(text, line);
						text_height += text_list_height(line); // scrolling requies whole text height
						line = word;
						if (space_found) text_list_add(line, " ", effects, index);
						word = ds_list_create();
					} else {
						line_add_word(line, word);
						if (space_found) text_list_add(line, " ", effects, index);
						ds_list_clear(word);
					}
					*/
				}
			}
			index = end_i + 1;
		}
		
		// add remaining line and word values
		if (ds_list_size(line) >  0 || ds_list_size(word) > 0) {
			line_add_word(line, word);
			line_remove_bookend_spaces(line);
			ds_list_add(text, line);
			text_height += text_list_height(line); // scrolling requies whole text height
		}
		ds_list_destroy(word);
		
		/* When creating single line textboxes, the width and height start undefined.
		Once we have determined the text list, we can set these values. */
		if (textbox_width == undefined) {
			textbox_width = text_list_width(text[|0]);
			textbox_height = text_list_height(text[|0]);
		}
	}
	
	/*
	Add given word, and line, to the text. Returns new values for each. 
	This function can only be called from "set_text". index and effects are only 
	required if space_found is included. */
	/// @func text_add_word(word, line, *space_found, *index, *effects)
	text_add_word = function(_word, _line) {
		var _space_found = (argument_count > 2) ? argument[2] : false;
		var _index = (argument_count > 3) ? argument[3] : 0;
		var _effects = (argument_count > 4) ? argument[4] : undefined;
		var _word_width = text_list_width(_word); // note that space is added after
		
		if ((textbox_width != undefined) && ((text_list_width(_line) + _word_width) > textbox_width)) {
			/*
			If the line has no words in it, this means we've found a word so big, the textbox cannot display it.
			We throw an error to force the user to change something, because our code cannot accomodate this.
			*/
			if (ds_list_size(_line) <= 0) show_error("The texbox is not big enough to display the word: " + text_list_string(_word), true);
					
			line_remove_bookend_spaces(_line); // so lines neither start nor end with spaces, makes align easy
			ds_list_add(text, _line);
			text_height += text_list_height(_line); // scrolling requies whole text height
			_line = _word;
			if (_space_found) text_list_add(_line, " ", _effects, _index);
			_word = ds_list_create();
		} else {
			line_add_word(_line, _word);
			if (_space_found) text_list_add(_line, " ", _effects, _index);
			ds_list_clear(_word);
		}
		
		return {
			line: _line,
			word: _word
		}
	}
	
	/// @desc Set horizontal alignment of text.
	/// @func set_text_align_h(new_align_h)
	set_text_align_h = function(new_align_h) {
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
	/// @func set_text_align_v(new_align_v)
	set_text_align_v = function(new_align_v) {
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
	/// @func set_box_align_h(new_align_h)
	set_box_align_h = function(new_align_h) {
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
	/// @func set_box_align_v(new_align_v)
	set_box_align_v = function(new_align_v) {
		if (new_align_v == alignment_box_v) {
			return;
		}
		if ((new_align_v != fa_top) && (new_align_v != fa_bottom) && (new_align_v != fa_center)) {
			show_error("Invalid alignment value!", true);
			return;
		}
		alignment_box_v = new_align_v;
	}
	
	/// @desc Set all alignments.
	/// @func set_alignments(box_v, box_h, text_v, text_h)
	set_alignments = function(box_v, box_h, text_v, text_h) {
		set_box_align_v(box_v);
		set_box_align_h(box_h);
		set_text_align_v(text_v);
		set_text_align_h(text_h);
		return;
	}
	
	/// @desc Return color based on command text.
	tb_get_color = function(new_color) {
		var color_change = undefined;
		if (new_color == "no_color") color_change = effects_default.text_color;
		else if (new_color == "aqua") color_change = c_aqua;
		else if (new_color == "black") color_change = c_black;
		else if (new_color == "blue") color_change = c_blue;
		else if (new_color == "ltblue") color_change = make_color_rgb(0, 191, 255);
		else if (new_color == "brown") color_change = make_color_rgb(102, 51, 0);
		else if (new_color == "dkgray") color_change = c_dkgray;
		else if (new_color == "fuchsia") color_change = c_fuchsia;
		else if (new_color == "pink") color_change = make_color_rgb(255, 105, 180);
		else if (new_color == "gray") color_change = c_gray;
		else if (new_color == "grey") color_change = c_gray;
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
	
		// Here we will check for a valid rgb code, assuming a color has not yet been found.
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
		
			var valid_rgb = true;
			if (string_digits(rgb_r) != rgb_r) valid_rgb = false;
			if (string_digits(rgb_g) != rgb_g) valid_rgb = false;
			if (string_digits(rgb_b) != rgb_b) valid_rgb = false;
		
			if (valid_rgb) {
				color_change = make_color_rgb(string_digits(rgb_r), string_digits(rgb_g), string_digits(rgb_b));
			}
		}
		return color_change;
	}

	/// @desc Return array of effects and their arguments.
	parse_command_text = function(all_command_text) {
		/*
		Note that this parsing code is not optimal, but the way we're doing it makes it
		easier for ourselves to understand.
		*/
		
		/* 
		First we split the text up into individual commands, and put them in an array.
		Commands are separated by spaces.
		*/
		var _commands = [];
		var _command = "";
		for (var i = 1; i <= string_length(all_command_text); i++) {
			var c = string_char_at(all_command_text, i);
			if (c != " ") {
				_command += c;
			} else {
				/*
				We only add a command text to our array if it's not empty.
				If we do, reset command.
				*/
				if (_command != "") {
					array_push(_commands, _command);
					_command = ""
				}
			}
		}
		// add final command
		if (_command != "") array_push(_commands, _command);
		
		/*
		Now that we have an array of separated texts, we need to separate the commands themselves
		from the parameters of these commands. We'll replace the text in each slot in the array
		with a struct containing the command itself, and the parameters.
		*/
		for (var i = 0; i < array_length(_commands); i++) {
			// split out command
			var _command_text = _commands[i];
			var _command = "";
			var c = 1;
			while (string_char_at(_command_text, c) != ":" && c <= string_length(_command_text)) {
				_command = string_lower(_command); // set to lower case to ensure correct matching later
				_command += string_char_at(_command_text, c);
				c++;
			}
			
			/*
			Here, c will be at the location of the colon in the command text, if it exists. Otherwise
			it will be beyond the length of the string. Therefore we can just begin parsing out parameters
			by checking for length of string instead of worrying about whether the current character is
			a colon. But remember since c is AT the location of the colon, we must increase it one place.
			*/
			c++;
			var _parameters = [];
			var _param = "";
			while (c <= string_length(_command_text)) {
				if (string_char_at(_command_text, c) != ",") {
					_param += string_char_at(_command_text, c);
				} else {
					array_push(_parameters, _param);
					_param = "";
				}
				c++;
			}
			// add final parameter
			if (_param != "") array_push(_parameters, _param);
			
			/*
			Now we have the command by itself as a string, and the parameters split into an array.
			These values can now replace the original string in the commands array.
			*/
			_commands[i] = {
				command: _command,
				parameters: _parameters
			}
		}
		
		return _commands;
	}

	/// @desc Get new effects of given struct based on _command_arr.
	command_apply_effects = function(_command_arr, _effects) {
		/*
		If the command array is empty, we reset the effects. Note
		that this is a design choice, and not a logical reminder. This
		makes resetting effects in a string very easy. Just type <>
		*/
		if (array_length(_command_arr) <= 0) {
			return effects_default;
		}
		
		// If that's not the case, continue with creating effects.
		
		/*
		In order to only change effects marked in commands, we create a new text
		struct by passing in the current effects to copy them.
		*/
		var new_effects = new JTT_Text("", _effects);
		
		// Now we can iterate though each command and arguments, and apply them to the effects struct.
		for (var i = 0; i < array_length(_command_arr); i++) {
			var _command = _command_arr[i].command;
			var _args = _command_arr[i].parameters; // I think these are technically arguments?
			
			// color commands
			var new_color = tb_get_color(_command);
			if (new_color != undefined) new_effects.text_color = new_color;
			
			// first parse commands that use string arguments:
			
			// font
			if (_command == "f") {
				// attemp to set new font
				var new_font = asset_get_index(_args[0]);
				if ((new_font >= 0) && (asset_get_type(_args[0]) == asset_font)) {
					new_effects.font = new_font;
				}
			}
			
			// From here on, all commands only use real numbers for arguments. We'll convert them now.
			for (var p = 0; p < array_length(_args); p++) {
				/* 
				A key parameter value is "nc" or "no change". This will fill the slot of an
				argument list, but make no changes. Useful for when you only want to
				change the second parameter in an effect. If the parameter is "nc", we
				skip over it
				*/
				if (_args[p] == "nc") {
					_args[p] = undefined;
				} else {
					/*
					Here we'll attempt to convert the parameter to a number. If we can't,
					The user has given improper input, and we'll throw an error.
					*/
					try {
						_args[p] = real(_args[p]);
					} catch (err) {
						show_debug_message(err);
						show_error("JTT Error: Text effect param (" + string(_args[p] + ") is not a real number!"), true);
					}
				}
			}
			
			// movement effects
			if (_command == "no_move") new_effects.effect_m = TB_EFFECT_MOVE.NONE;
			else if (_command == "offset") {
				new_effects.effect_m = TB_EFFECT_MOVE.OFFSET;
				var new_offset_x = 0;
				if (array_length(_args) >= 1) { // x left
					new_offset_x += (_args[0] * -1);
				}
				if (array_length(_args) >= 2) { // x right
					new_offset_x += _args[1];
				}
				var new_offset_y = 0;
				if (array_length(_args) >= 3) { // y up
					new_offset_y += (_args[2] * -1);
				}
				if (array_length(_args) >= 4) { // y down
					new_offset_y += _args[3];
				}
				new_effects.position_offset_x = new_offset_x;
				new_effects.position_offset_y = new_offset_y;
			} else if (_command == "wave") {
				new_effects.effect_m = TB_EFFECT_MOVE.WAVE;
				if (array_length(_args) >= 1) {
					new_effects.wave_magnitude = clamp(_args[0], 0, 10000);
				}
				if (array_length(_args) >= 2) {
					new_effects.wave_increment = clamp(_args[1], 0, 10000);
				}
				if (array_length(_args) >= 3) {
					new_effects.wave_offset = clamp((_args[2]), 0, 2 * pi);
				}
			} else if (_command == "float") {
				new_effects.effect_m = TB_EFFECT_MOVE.FLOAT;
				if (array_length(_args) >= 1) {
					new_effects.float_magnitude = clamp(_args[0], 0, 10000);
				}
				if (array_length(_args) >= 2) {
					new_effects.float_increment = clamp((_args[1]), 0, 2 * pi);
				}
			} else if (_command == "shake") {
				new_effects.effect_m = TB_EFFECT_MOVE.SHAKE;
				if (array_length(_args) >= 1) {
					new_effects.shake_magnitude = clamp(_args[0], 0, 10000);
				}
				if (array_length(_args) >= 2) {
					new_effects.shake_time_max = clamp(_args[1], 0, 10000);
				}
			} else if (_command == "wshake") {
				new_effects.effect_m = TB_EFFECT_MOVE.WSHAKE;
				if (array_length(_args) >= 1) {
					new_effects.shake_magnitude = clamp(_args[0], 0, 10000);
				}
				if (array_length(_args) >= 2) {
					new_effects.shake_time_max = clamp(_args[1], 0, 10000);
				}
			}
			
			// alpha effects
			if (_command == "no_alpha") new_effects.effect_a = TB_EFFECT_ALPHA.NONE;
			else if (_command == "pulse") {
				new_effects.effect_a = TB_EFFECT_ALPHA.PULSE;
				if (array_length(_args) >= 1) {
					new_effects.pulse_alpha_max = clamp((_args[0]), 0, 1);
				}
				if (array_length(_args) >= 2) {
					new_effects.pulse_alpha_min = clamp((_args[1]), 0, new_effects.pulse_alpha_max);
				}
				if (array_length(_args) >= 3) {
					new_effects.pulse_increment = clamp((_args[2]), 0, 1);
				}
			} else if (_command == "blink") {
				new_effects.effect_a = TB_EFFECT_ALPHA.BLINK;
				if (array_length(_args) >= 1) {
					new_effects.blink_alpha_on = clamp((_args[0]), 0, 1);
				}
				if (array_length(_args) >= 2) {
					new_effects.blink_alpha_off = clamp((_args[1]), 0, 1);
				}
				if (array_length(_args) >= 3) {
					new_effects.blink_time_on = _args[2];
				}
				if (array_length(_args) >= 4) {
					new_effects.blink_time_off = _args[3];
				}
			}
			
			// color effects
			if (_command == "no_color") new_effects.effect_c = TB_EFFECT_COLOR.NONE;
			else if (_command == "chromatic") {
				new_effects.effect_c = TB_EFFECT_COLOR.CHROMATIC;
				if (array_length(_args) >= 1) {
					new_effects.chromatic_max = clamp(_args[0], 0, 255);
				}
				if (array_length(_args) >= 2) {
					new_effects.chromatic_min = clamp(_args[1], 0, 255);
				}
				if (array_length(_args) >= 3) {
					new_effects.chromatic_increment = _args[2];
				}
			}
		}
	
		return new_effects;
	}

	/// @desc Set new display values to next displayable chunk of text.
	/// @func next_page()
	next_page = function() {
		// Note that for scrolling, the entire text is always displayable.
		if (ds_list_size(text) <= 0) {
			show_error("Cannot go to next page, text not set!", true);
		}
		typing_time = 0;
		scroll_modifier = 0;
	
		// pages
		/* This code moves row_i_start and row_i_end to the next 
		set of rows that can fit in the textbox. */
		if (textbox_display_mode == 0) {
			text_height = 0;
			/* Find start and end indicies of rows that fit in
			the text box height. */
		
			/* Set start to the beginning if undefined, to 
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
		}
	
		// scrolling
		if (textbox_display_mode == 1) {
			row_i_start = 0;
			row_i_end = ds_list_size(text) - 1;
		}
	
		if (type_on_nextpage) {
			set_typing_page_finished();
		} else {
			set_typing_start();
		}
	}

	/// @desc Set textbox to next logical state
	/// @func advance()
	advance = function() {
		/* For the two display modes, typing and scrolling, there are basically 3
		states: text set but typing/scrolling not started, typing/scrolling started
		but not finished, and typing/scrolling finished. This detects which state
		the box is in, and sets it to the next one. */
		
		/* next_page() sets up the starting values if the text been set but not begun.
		It works for both display modes. */
		if (row_i_start == undefined) {
			next_page();
		} else {
			if (textbox_display_mode == 0) {
				if (get_typing_page_finished()) {
					next_page();
				} else {
					set_typing_page_finished();
				}
			} else {
				if (get_scrolling_finished()) {
					next_page();
				} else {
					set_scrolling_finished();
				}
			}	
		}
	}

	/// @desc Return true if the whole text fits in the box.
	/// @func get_fits_onepage()
	get_fits_onepage = function() {
		if (row_i_start == 0 && row_i_end == (ds_list_size(text) - 1)) {
			return true;
		}
		return false;
	}

	/// @desc Return true if typing of current page complete.
	/// @func get_typing_page_finished()
	get_typing_page_finished = function() {
		if (cursor_row < row_i_end) return false;
	
		if (cursor_row > row_i_end) {
			show_error("Cursor_row was larger than row_i_end. This should not be possible. Review code.", true);
		}
	
		// if we make it here, cursor must be at final row
		if (cursor < text_list_length(text[|cursor_row])) return false;
		return true;
	}

	/// @desc Return true if typing of all pages is complete.
	/// @func get_typing_all_finished()
	get_typing_all_finished = function() {
		if (get_typing_page_finished() && row_i_end == ds_list_size(text) - 1) {
			return true;
		}
		return false;
	}

	/// @desc Set typing cursor values to finished.
	/// @func set_typing_page_finished()
	set_typing_page_finished = function() {
		if (ds_list_size(text) <= 0) {
			show_error("Cannot set typing finished, text not set!", true);
		} else {
			cursor_row = row_i_end;
			cursor = text_list_length(text[|cursor_row]);
		}
	}

	/// @desc Set typing cursor values to start of displayable chunk
	/// @func set_typing_start()
	set_typing_start = function() {
		if (row_i_start == undefined) {
			show_error("Cannot set typing start, next_page() not called!", true);
		} else {
			cursor = 0
			cursor_row = row_i_start;
		}
	}

	/// @desc Return true if text at end scrolling position
	/// @func get_scrolling_finished()
	get_scrolling_finished = function() {
		var end_modifier = (text_height + textbox_height - scroll_end) * -1;
		return scroll_modifier <= end_modifier;
	}

	/// @desc Set scroll_modifier to end scrolling position
	/// @func set_scrolling_finished()
	set_scrolling_finished = function() {
		scroll_modifier = (text_height + textbox_height - scroll_end) * -1;
	}

	/// @desc Set scroll_modifier back to start position
	/// @func set_scrolling_start
	set_scrolling_start = function() {
		scroll_modifier = 0;
	}

	/// @desc Determine character typing, and update char structs.
	update = function() {
		
		// typing effect
		/* We don't bother to check display_mode since for scrolling textboxes, 
		the typing will automatically be set to finished. */
		if ((row_i_start != undefined) && !get_typing_page_finished()) {
			// run update logic until caught up
			if (typing_time <= 0) {
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
					else {
						cursor += _typing_increment;
					
						/* There is a bug created from slop with game makers numbers. We're 
						going to try and solve that here by forcing cursor to be a smaller
						resolution.*/
						cursor *= 100;
						cursor = floor(cursor + 0.5);
						cursor /= 100;
					}
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
					if (char_at_cursor == "." || char_at_cursor == "!" || char_at_cursor == "?") {
						_typing_increment = 0;
						typing_time += typing_time_stop;
					}
					if (char_at_cursor == "," || char_at_cursor == ";" || char_at_cursor == ":") {
						_typing_increment = 0;
						typing_time += typing_time_pause;
					}
				}
			}
		
			typing_time -= 1; // typing_time counts down updates
		}
	
		// scrolling effect
		if ((row_i_start != undefined) && (textbox_display_mode == 1)) {
			scroll_modifier -= scroll_increment;
			var end_modifier = (text_height + textbox_height - scroll_end) * -1;
			if (scroll_modifier <= end_modifier) {
				scroll_modifier = end_modifier
			}
		}
	
		// update text structs
		for (var i = 0; i < ds_list_size(text); i++) {
			for (var k = 0; k < ds_list_size(text[|i]); k++) {
				text[|i][|k].update();
			}
		}
	}

	/// @desc Draw the textbox.
	/// @func draw(x, y)
	draw = function(x, y) {
		if (global.JTT_AUTO_UPDATE) update();
		
		var original_color = draw_get_color();
		var original_alpha = draw_get_alpha();
		var original_font = draw_get_font();
	
		if (global.JTT_DEBUGGING) {
			draw_set_color(c_gray);
			draw_set_alpha(1);
			var box_x = x;
			var box_y = y;
			if (alignment_box_h == fa_right) box_x -= textbox_width;
			if (alignment_box_h == fa_center) box_x -= floor(textbox_width / 2 + 0.5);
			if (alignment_box_v == fa_bottom) box_y -= textbox_height;
			if (alignment_box_v == fa_center) box_y -= floor(textbox_height / 2 + 0.5);
			draw_rectangle(box_x, box_y, box_x + textbox_width, box_y + textbox_height, true);
			draw_set_color(c_fuchsia);
			var radius = 4;
			draw_circle(x, y, radius, false);
		}
	
		if (row_i_start == undefined) {
			exit;
		}

		draw_set_valign(fa_top);
		draw_set_halign(fa_left);

		/* To determine the y position of the text, we first find
		the top and bottom of the box. */
		var box_top = y;
		if (alignment_box_v == fa_bottom) box_top -= textbox_height;
		if (alignment_box_v == fa_center) box_top -= floor(textbox_height / 2 + 0.5);
		var box_bottom = box_top + textbox_height;

		/* Now we find the starting y position of the text, we start 
		by assuming we are scrolling the text, so the text will start at
		the bottom. */
		var _y = floor(box_bottom + scroll_modifier + 0.5);

		// Assign different values based on alignment if page displayed. 
		if (textbox_display_mode == 0) {
			if (alignment_text_v == fa_top) _y = box_top;
			if (alignment_text_v == fa_bottom) _y = box_bottom - text_height;
			if (alignment_text_v == fa_center) _y = box_top + floor(textbox_height / 2 + 0.5) - floor(text_height / 2 + 0.5);
		}

		for (var irow = row_i_start; irow <= cursor_row; irow++) {
			var row_height = text_list_height(text[|irow]);
	
			// we only draw the row if it is within the bounds of the box
			if ((_y >= box_top) && ((_y + row_height) <= box_bottom)) {
	
				// Now we determine x position with same process
				var _x = x;
				if (alignment_box_h == fa_right) _x -= textbox_width;
				if (alignment_box_h == fa_center) _x -= floor(textbox_width / 2 + 0.5);
				if (alignment_text_h == fa_right) _x = _x + textbox_width - text_list_width(text[|irow]);
				if (alignment_text_h == fa_center) _x = _x + textbox_width / 2 - text_list_width(text[|irow]) / 2;
	
				// irow is changed when we reach end of typing, so we store value here
				var row_size = ds_list_size(text[|irow]);
		
				var _cursor_char = floor(cursor);
		
				// Iterate over each struct in the row to prepare for draw. 
				for (var istruct = 0; istruct < row_size; istruct++) {
					var text_struct = text[|irow][|istruct];
					draw_set_font(text_struct.font);
					draw_set_color(text_struct.draw_color);
					draw_set_alpha(text_struct.alpha);
					var draw_x = _x + text_struct.draw_mod_x;
					var draw_y = _y + text_struct.draw_mod_y;
			
					/* Here we determine the alpha of a line of text when scrolling. If the text is
					beyond the bounding value, the alpha modifier is 1. If not, it is the percentage 
					distance between the edge and the boudning value. Note that the bottom row takes
					precedent over the top. */
					var alpha_scroll_mod = 1;
					if ((textbox_display_mode == 1) && (scroll_fade_bound > 0)) {
						if (_y < (box_top + scroll_fade_bound)) {
							alpha_scroll_mod = (_y - box_top) / scroll_fade_bound;
						}
						if ((_y + row_height) > (box_bottom - scroll_fade_bound)) {
							alpha_scroll_mod = (box_bottom - (_y + row_height)) / scroll_fade_bound;
						}
					}
					draw_set_alpha(text_struct.alpha * alpha_scroll_mod);
			
					// if we are not on the cursor row, we can just draw the text
					if (irow < cursor_row) {
						draw_text(draw_x, draw_y, text_struct.text);
					} else {
				
						/* But if we are, we must check to see if the text goes beyond
						the cursor. In which case we'll only draw a portion of the string.*/
						var str_length = string_length(text_struct.text)
				
						// we subtract the length of each struct from _cursor char
						if (str_length < _cursor_char) {
							_cursor_char -= str_length;
							if (str_length > 0) {
								draw_text(draw_x, draw_y, text_struct.text);
							}
						} else {
							/* Once cursor char is smaller than the struct, we draw that 
							portion of the struct. This is the end of drawing. */ 
							istruct = row_size;
							var _text = string_copy(text_struct.text, 1, _cursor_char);
							draw_text(draw_x, draw_y, _text);
						}
					}
					_x += text_struct.get_width();
				}
			}
			_y += row_height;
		}
	
		draw_set_color(original_color);
		draw_set_alpha(original_alpha);
		draw_set_font(original_font);
	}
}
