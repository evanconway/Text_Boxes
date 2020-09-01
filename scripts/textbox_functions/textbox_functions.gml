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
	calculate_width = false; // marked when text changed
	calculate_height = false;
	draw_mod_x = 0;
	draw_mod_y = 0;
	effect = fx;
	
	// effect specific vars
	float_rate = 0.3;
	float_magnitude = 3;
	float_time = 0;
	float_value = 0;
	
	wave_rate = 0.3;
	wave_magnitude = 2;
	wave_time = 0;
	wave_value = 0;
	
	shake_magnitude = 1; // x/y offset will be between negative and positive of this value, inclusive
	shake_rate = 0.2;
	shake_time = 0;
	
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
			float_time += float_rate;
			if (float_time >= 1) {
				while (float_time >= 1) float_time--;
				float_value += pi/float_magnitude/4; // magic number
			}
			draw_mod_y = floor(sin(float_value) * float_magnitude + 0.5);
			return;
		}
		
		if (effect == TB_EFFECT.WAVE) {
			draw_mod_x = 0;
			wave_time += wave_rate;
			if (wave_time >= 1) {
				while (wave_time >= 1) wave_time--;
				wave_value += pi/wave_magnitude/4; // magic number
			}
			/* Notice the index modifier in the sin function. This ensures that each character using this
			effect recieves a slightly different position. This is the only real difference between the wave
			and float effects. */
			draw_mod_y = floor(sin(wave_value - index*0.9) * wave_magnitude + 0.5);
			return;
		}
		
		if (effect == TB_EFFECT.SHAKE) {
			shake_time += shake_rate;
			if (shake_time >= 1) {
				while (shake_time >= 1) shake_time--;
				draw_mod_x = irandom_range(shake_magnitude * -1, shake_magnitude);
				draw_mod_y = irandom_range(shake_magnitude * -1, shake_magnitude);
			}
			return;
		}
	}
}
