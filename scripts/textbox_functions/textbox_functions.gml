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

/// @desc Create textbox character.
/// @func tb_character(character, font, color, effect, index)
function tb_character(c, f, r, e, i) constructor {
	
	// character vars
	character = c;
	font = f;
	
	/* We keep track of the index because it lets us easily offset different
	effects from other characters if necessary. The wave is a good example. */
	index = i; 
	char_color = r;
	if (font != undefined) draw_set_font(font);
	width = string_width(character);
	height = string_height(character);
	char_x = 0;
	char_y = 0;
	draw_x = char_x;
	draw_y = char_y;
	effect = e;
	
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
	
	if (argument_count > 3) effect = argument[3];
	
	function set_char_x(new_x) {
		char_x = new_x;
		draw_x = new_x;
	}
	
	function set_char_y(new_y) {
		char_y = new_y;
		draw_y = new_y;
	}
	
	function update() {
		if (effect == TB_EFFECT.NONE) {
			draw_x = char_x;
			draw_y = char_y;
			return;
		}
		
		if (effect == TB_EFFECT.FLOAT) {
			draw_x = char_x;
			float_time += float_rate;
			if (float_time >= 1) {
				while (float_time >= 1) float_time--;
				float_value += pi/float_magnitude/4; // magic number
			}
			var y_offset = floor(sin(float_value) * float_magnitude + 0.5);
			draw_y = char_y + y_offset;
			return;
		}
		
		if (effect == TB_EFFECT.WAVE) {
			draw_x = char_x;
			wave_time += wave_rate;
			if (wave_time >= 1) {
				while (wave_time >= 1) wave_time--;
				wave_value += pi/wave_magnitude/4; // magic number
			}
			/* Notice the index modifier in the sin function. This ensures that each character using this
			effect recieves a slightly different position. This is the only real difference between the wave
			and float effects. */
			var y_offset = floor(sin(wave_value - index*0.9) * wave_magnitude + 0.5);
			draw_y = char_y + y_offset;
			return;
		}
		
		if (effect == TB_EFFECT.SHAKE) {
			shake_time += shake_rate;
			if (shake_time >= 1) {
				while (shake_time >= 1) shake_time--;
				draw_x = char_x + irandom_range(shake_magnitude * -1, shake_magnitude);
				draw_y = char_y + irandom_range(shake_magnitude * -1, shake_magnitude);
			}
			return;
		}
	}
}
