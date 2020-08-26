
for (var i = 0; i <= cursor_row; i++) {
	for (var k = 0; k <= cursor_char; k++) {
		var c = characters[i][k];
		draw_set_font(c.font);
		draw_set_color(c.char_color);
		draw_text(c.char_x, c.char_y, c.character);
	}
}

