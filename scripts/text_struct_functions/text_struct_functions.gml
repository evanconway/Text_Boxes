global.TEXTBOX_DELTA_TIME = 0;
global.JTT_DEBUGGING = true;

enum TB_EFFECT_MOVE {
	OFFSET,
	WAVE,
	FLOAT,
	SHAKE,
	WSHAKE,
	NONE
}

enum TB_EFFECT_ALPHA {
	PULSE,
	BLINK,
	NONE
}

enum TB_EFFECT_COLOR {
	CHROMATIC,
	NONE
}

/// @desc Create textbox text struct.
/// @func JTT_Text(*text, *effects, *index)
function JTT_Text() constructor {
	text = (argument_count > 0) ? argument[0] : "";
	
	var has_fx = (argument_count > 1) ? true : false;
	var effects = (has_fx) ? argument[1] : undefined;
	
	font = (has_fx) ? effects.font : global.JTT_DEFAULT_FONT;
	
	/* We keep track of the index because it lets us easily offset different
	effects from other characters if necessary. The wave is a good example. */
	index = (argument_count > 2) ? argument[2] : 0;
	
	text_color = (has_fx) ? effects.text_color : global.JTT_DEFAULT_COLOR;
	draw_color = text_color;
	width = 0;
	height = 0;
	calculate_width = true; // marked when text changed
	calculate_height = true;
	draw_mod_x = 0;
	draw_mod_y = 0;
	effect_m = (has_fx) ? effects.effect_m : global.JTT_DEFAULT_EFFECT_MOVE;
	effect_a = (has_fx) ? effects.effect_a : global.JTT_DEFAULT_EFFECT_ALPHA;
	effect_c = (has_fx) ? effects.effect_c : global.JTT_DEFAULT_EFFECT_COLOR;
	alpha = 1;
	
	// movement effects
	position_offset_x = (has_fx) ? effects.position_offset_x : global.JTT_DEFAULT_OFFSET_X;
	position_offset_y = (has_fx) ? effects.position_offset_y : global.JTT_DEFAULT_OFFSET_Y;
	
	float_magnitude = (has_fx) ? effects.float_magnitude : global.JTT_DEFAULT_FLOAT_MAGNITUDE;
	float_increment = (has_fx) ? effects.float_increment : global.JTT_DEFAULT_FLOAT_INCREMENT;
	float_value = 0;
	
	wave_magnitude = (has_fx) ? effects.wave_magnitude : global.JTT_DEFAULT_WAVE_MAGNITUDE;
	wave_increment = (has_fx) ? effects.wave_increment: global.JTT_DEFAULT_WAVE_INCREMENT;
	wave_offset = (has_fx) ? effects.wave_offset : global.JTT_DEFAULT_WAVE_OFFSET;
	wave_value = 0;
	
	shake_magnitude = (has_fx) ? effects.shake_magnitude : global.JTT_DEFAULT_SHAKE_MAGNITUDE; // x/y offset will be between negative and positive of this value, inclusive
	shake_time = (has_fx) ? effects.shake_time : global.JTT_DEFAULT_SHAKE_TIME; // number of shakes per update
	shake_value = 0;
	
	// alpha effects
	pulse_alpha_max = (has_fx) ? effects.pulse_alpha_max : global.JTT_DEFAULT_PULSE_ALPHA_MAX;
	pulse_alpha_min = (has_fx) ? effects.pulse_alpha_min : global.JTT_DEFAULT_PULSE_ALPHA_MIN;
	pulse_increment = (has_fx) ? effects.pulse_increment : global.JTT_DEFAULT_PULSE_INCREMENT;
	
	blink_alpha_on = (has_fx) ? effects.blink_alpha_on : global.JTT_DEFAULT_BLINK_ALPHA_ON;
	blink_alpha_off = (has_fx) ? effects.blink_alpha_off : global.JTT_DEFAULT_BLINK_ALPHA_OFF;
	blink_time_on = (has_fx) ? effects.blink_time_on : global.JTT_DEFAULT_BLINK_TIME_ON;
	blink_time_off = (has_fx) ? effects.blink_time_off : global.JTT_DEFAULT_BLINK_TIME_OFF;
	blink_time = blink_time_on;
	
	// color effects
	chromatic_increment = (has_fx) ? effects.chromatic_increment : global.JTT_DEFAULT_CHROMATIC_INCREMENT;
	chromatic_max = (has_fx) ? effects.chromatic_max : global.JTT_DEFAULT_CHROMATIC_MAX;
	chromatic_min = (has_fx) ? effects.chromatic_min : global.JTT_DEFAULT_CHROMATIC_MIN;
	chromatic_r = chromatic_max;
	chromatic_g = chromatic_min;
	chromatic_b = chromatic_min;
	chromatic_state = 0;
	
	add_text = function(new_text) {
		text += new_text;
		calculate_width = true;
		calculate_height = true;
	}
	
	set_text = function(new_text) {
		text = new_text;
		calculate_width = true;
		calculate_height = true;
	}
	
	get_width = function() {
		if (calculate_width) {
			draw_set_font(font);
			width = string_width(text);
			calculate_width = false;
		}
		return width;
	}
	
	get_height = function() {
		if (calculate_height) {
			draw_set_font(font);
			height = string_height(text);
			calculate_height = false;
		}
		return height;
	}
	
	update = function() {
		
		// movement effects
		if (effect_m == TB_EFFECT_MOVE.NONE) {
			draw_mod_x = 0;
			draw_mod_y = 0;
		}
		
		if (effect_m == TB_EFFECT_MOVE.OFFSET) {
			draw_mod_x = position_offset_x;
			draw_mod_y = position_offset_y;
		}
		
		if (effect_m == TB_EFFECT_MOVE.FLOAT) {
			draw_mod_x = 0;
			float_value += float_increment;
			draw_mod_y = floor(sin(float_value) * float_magnitude + 0.5);
		}
		
		if (effect_m == TB_EFFECT_MOVE.WAVE) {
			draw_mod_x = 0;
			wave_value += wave_increment;
			/* The wave value is how we keep track of the offset between characters. Offset is designed
			to be the position in the sine function you want the next character to be in terms of pi. 
			So if your offset is 1, then when a character is at 3pi, the next character will be at 4pi,
			the next at 5pi, and so on.*/
			//wave_value += wave_offset; 
			
			/* Notice the index modifier in the sin function. This ensures that each character using this
			effect recieves different position. The -1 ensures the values move through in reverse, which
			makes the first character look like it's "leading" the wave. */
			draw_mod_y = floor(sin((index * -1 * wave_offset + wave_value)) * wave_magnitude + 0.5);
		}
		
		if ((effect_m == TB_EFFECT_MOVE.SHAKE) || (effect_m == TB_EFFECT_MOVE.WSHAKE)) {
			shake_value += shake_time;
			while (shake_value >= 1) {
				shake_value -= 1;
				if (shake_magnitude > 0) {
					draw_mod_x = irandom_range(shake_magnitude * -1, shake_magnitude);
					draw_mod_y = irandom_range(shake_magnitude * -1, shake_magnitude);
				} else {
					draw_mod_x = irandom_range(0, 1);
					draw_mod_y = irandom_range(0, 1);
				}
			}
		}
		
		// alpha effects
		if (effect_a == TB_EFFECT_ALPHA.NONE) {
			alpha = 1;
		}
		
		if (effect_a == TB_EFFECT_ALPHA.PULSE) {
			alpha += pulse_increment;
			if (alpha >= pulse_alpha_max) {
				alpha = pulse_alpha_max;
				pulse_increment *= -1;
			}
			if (alpha <= pulse_alpha_min) {
				alpha = pulse_alpha_min;
				pulse_increment *= -1;
			}
		}
		
		if (effect_a == TB_EFFECT_ALPHA.BLINK) {
			/*
			Blink time will be set positive when counting time 
			on, and negative when counting time off
			*/
			if (blink_time > 0) {
				alpha = blink_alpha_on;
				blink_time -= 1;
				if (blink_time <= 0) {
					blink_time = blink_time_off * -1;
				}
			} else {
				alpha = blink_alpha_off;
				blink_time += 1;
				if (blink_time >= 0) {
					blink_time = blink_time_on;
				}
			}
		}
		
		// color effects
		if (effect_c == TB_EFFECT_COLOR.NONE) {
			draw_color = text_color;
		}
		
		if (effect_c == TB_EFFECT_COLOR.CHROMATIC) {
			
			if (chromatic_state == 0) {
				chromatic_g += chromatic_increment;
				if (chromatic_g >= chromatic_max) {
					chromatic_g = chromatic_max;
					chromatic_state += 1;
				}
			} else if (chromatic_state == 1) {
				chromatic_r -= chromatic_increment;
				if (chromatic_r <= chromatic_min) {
					chromatic_r = chromatic_min;
					chromatic_state += 1;
				}
			} else if (chromatic_state == 2) {
				chromatic_b += chromatic_increment;
				if (chromatic_b >= chromatic_max) {
					chromatic_b = chromatic_max;
					chromatic_state += 1;
				}
			} else if (chromatic_state == 3) {
				chromatic_g -= chromatic_increment;
				if (chromatic_g <= chromatic_min) {
					chromatic_g = chromatic_min;
					chromatic_state += 1;
				}
			} else if (chromatic_state == 4) {
				chromatic_r += chromatic_increment;
				if (chromatic_r >= chromatic_max) {
					chromatic_r = chromatic_max;
					chromatic_state += 1;
				}
			} else if (chromatic_state == 5) {
				chromatic_b -= chromatic_increment;
				if (chromatic_b <= chromatic_min) {
					chromatic_b = chromatic_min;
					chromatic_state = 0;
				}
			}
			draw_color = make_color_rgb(chromatic_r, chromatic_g, chromatic_b);
		}
	}
}

/// @desc Return true if given text requires 1 struct per character
function jtt_text_req_ind_struct(text_struct) {
	if (text_struct.effect_m == TB_EFFECT_MOVE.SHAKE) return true;
	if (text_struct.effect_m == TB_EFFECT_MOVE.WAVE) return true;
	return false;
}

/// @desc Return true if effect values of given text structs are equal
function jtt_text_fx_equal(a, b) {
	if (a.font != b.font) return false;
	if (a.text_color != b.text_color) return false;
	if (a.effect_m != b.effect_m) return false;
	if (a.effect_a != b.effect_a) return false;
	if (a.effect_c != b.effect_c) return false;
	if (a.position_offset_x != b.position_offset_x) return false;
	if (a.position_offset_y != b.position_offset_y) return false;
	if (a.float_magnitude != b.float_magnitude) return false;
	if (a.float_increment != b.float_increment) return false;
	if (a.wave_magnitude != b.wave_magnitude) return false;
	if (a.wave_increment != b.wave_increment) return false;
	if (a.wave_offset != b.wave_offset) return false;
	if (a.shake_magnitude != b.shake_magnitude) return false;
	if (a.shake_time != b.shake_time) return false;
	if (a.pulse_alpha_max != b.pulse_alpha_max) return false;
	if (a.pulse_alpha_min != b.pulse_alpha_min ) return false;
	if (a.pulse_increment != b.pulse_increment) return false;
	if (a.blink_alpha_on != b.blink_alpha_on) return false;
	if (a.blink_alpha_off != b.blink_alpha_off) return false;
	if (a.blink_time_on != b.blink_time_on) return false;
	if (a.blink_time_off != b.blink_time_off) return false;
	if (a.chromatic_increment != b.chromatic_increment) return false;
	if (a.chromatic_max != b.chromatic_max) return false;
	if (a.chromatic_min != b.chromatic_min) return false;
	return true;
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
