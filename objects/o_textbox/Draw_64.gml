
draw_set_valign(fa_top);
draw_set_halign(fa_left);

cursor_row = array_length(characters) - 1; // for debug, will be deleted.


for (var i = 0; i <= cursor_row; i++) {
	var limit = array_length(characters[i]) - 1;
	for (var k = 0; k <= limit; k++) {
		var c = characters[i][k];
		if (c.font != undefined) draw_set_font(c.font);
		if (c.char_color != undefined) draw_set_color(c.char_color);
		draw_text(x + c.draw_x, y + c.draw_y, c.character);
	}
}
