/// @desc Create textbox character.
/// @param character
/// @param font
/// @param color
/// @param *effect
function tb_character(c, f, r, e) constructor {
	character = c;
	font = f;
	char_color = r;
	draw_set_font(font);
	width = string_width(character);
	height = string_height(character);
	char_x = 0;
	char_y = 0;
	effect = 
	update = function() {
		
	}
}
