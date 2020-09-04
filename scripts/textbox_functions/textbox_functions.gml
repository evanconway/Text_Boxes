function delta_time_debug() {
	var max_time = 1000000/game_get_speed(gamespeed_fps);
	return (delta_time > max_time) ? max_time : delta_time;
}

// textbox enums
enum TB_ALIGN {
	LEFT,
	RIGHT,
	CENTER
}

enum TB_EFFECT {
	WAVE,
	FLOAT,
	SHAKE,
	NONE
}

/// @desc Return pixel width of ds_list of text structs.
function text_list_width(list) {
	var width = 0;
	for (var i = 0; i < ds_list_size(list); i++) {
		width += list[|i].get_width();
	}
	return width;
}

/// @desc Return the combined string length of a list of text structs.
function text_list_length(list) {
	var result = 0;
	for (var i = 0; i < ds_list_size(list); i++) {
		result += string_length(list[|i].text);
	}
	return result;
}

/// @desc Create textbox text struct.
/// @func tb_text(font, color, effect, *text, *index)
function tb_text(fnt, col, fx) constructor {
	text = "";
	if (argument_count > 3) text = argument[3];
	font = fnt;
	
	/* We keep track of the index because it lets us easily offset different
	effects from other characters if necessary. The wave is a good example. */
	index = 0;
	if (argument_count > 4) index = argument[4];
	
	text_color = col;
	width = 0;
	height = 0;
	calculate_width = true; // marked when text changed
	calculate_height = true;
	draw_mod_x = 0;
	draw_mod_y = 0;
	effect = fx;
	
	// effect specific vars
	float_magnitude = 3;
	float_time_max = 50;
	float_time = float_time_max;
	float_value = 0;
	
	wave_magnitude = 2;
	wave_time_max = 50;
	wave_time = wave_time_max;
	wave_value = 0;
	
	shake_magnitude = 1; // x/y offset will be between negative and positive of this value, inclusive
	shake_time_max = 80; // time in ms that character will be at a position
	shake_time = shake_time_max;
	
	function add_text(new_text) {
		text += new_text;
		calculate_width = true;
		calculate_height = true;
	}
	
	function get_width() {
		if (calculate_width) {
			draw_set_font(font);
			width = string_width(text);
			calculate_width = false;
		}
		return width;
	}
	
	function get_height() {
		if (calculate_height) {
			draw_set_font(font);
			height = string_height(text);
			calculate_height = false;
		}
		return height;
	}
	
	function update() {
		if (effect == TB_EFFECT.NONE) {
			draw_mod_x = 0;
			draw_mod_y = 0;
			return;
		}
		
		if (effect == TB_EFFECT.FLOAT) {
			draw_mod_x = 0;
			float_time -= delta_time_debug()/1000;
			if (float_time <= 0) {
				float_time = float_time_max;
				float_value += pi/float_magnitude/4; // magic number
				if (float_value > 2 * pi) float_value -= 2 * pi;
			}
			draw_mod_y = floor(sin(float_value) * float_magnitude + 0.5);
			return;
		}
		
		if (effect == TB_EFFECT.WAVE) {
			draw_mod_x = 0;
			wave_time -= delta_time_debug()/1000;
			if (wave_time <= 0) {
				wave_time = wave_time_max;
				wave_value += pi/wave_magnitude/4; // magic number
				if (wave_value > 2 * pi) wave_value -= 2 * pi;
			}
			/* Notice the index modifier in the sin function. This ensures that each character using this
			effect recieves a slightly different position. This is the only real difference between the wave
			and float effects. */
			draw_mod_y = floor(sin(wave_value - index*0.9) * wave_magnitude + 0.5);
			return;
		}
		
		if (effect == TB_EFFECT.SHAKE) {
			shake_time -= delta_time_debug()/1000;
			if (shake_time <= 0) {
				shake_time = shake_time_max;
				draw_mod_x = irandom_range(shake_magnitude * -1, shake_magnitude);
				draw_mod_y = irandom_range(shake_magnitude * -1, shake_magnitude);
			}
			return;
		}
	}
}

/* string_pos_ext appears to be bugged in html builds for now. It behaves like
string_pos, and ignores the starting index. */
/// @desc same as string_pos_ext
function htmlsafe_string_pos_ext(substr, str, startpos) {
	var rest_of_string = string_delete(str, 1, startpos)
	var pos = string_pos(substr, rest_of_string);
	if (pos == 0) return 0;
	return pos + startpos;
}
