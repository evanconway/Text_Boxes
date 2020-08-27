// textbox enums
enum TB_ALIGN {
	LEFT,
	RIGHT,
	CENTER
}

/// @desc Create textbox character.
/// @func tb_character(character, font, color, *effect)
function tb_character(c, f, r) constructor {
	character = c;
	font = f;
	char_color = r;
	if (font != undefined) draw_set_font(font);
	width = string_width(character);
	height = string_height(character);
	char_x = 0;
	char_y = 0;
	effect = undefined;
	if (argument_count > 3) effect = argument[3];
	
	function update() {
		
	}
}
