draw_set_valign(fa_top);
draw_set_halign(fa_left);

var _x = 0;
var _y = 40;

/*
cursor_row = ds_list_size(text) - 1;
cursor_row = 2;
cursor_char = 4
*/

/* When we reach the final row, we remove the text length
of each char from _cursor_char until it's smaller than 
the length of the next struct. Then we draw the portion
of that struct up to _cursor_char. */
var _cursor_char = floor(cursor_char);

for (var irow = 0; irow <= cursor_row; irow++) {
	_x = 40;
	var row_height = 0;
	for (var ichar = 0; ichar < ds_list_size(text[|irow]); ichar++) {
		var text_struct = text[|irow][|ichar];
		draw_set_font(text_struct.font);
		draw_set_color(text_struct.text_color);
		var draw_x = _x + text_struct.draw_mod_x;
		var draw_y = _y + text_struct.draw_mod_y;
		if (text_struct.get_height() > row_height) row_height = text_struct.get_height();
		if (irow != cursor_row) draw_text(draw_x, draw_y, text_struct.text);
		else {
			if (string_length(text_struct.text) < _cursor_char) {
				_cursor_char -= string_length(text_struct.text);
				draw_text(draw_x, draw_y, text_struct.text);
			} else {
				// if we reach this block, we have reached the end of typing
				ichar = ds_list_size(text[|irow]);
				var _text = string_copy(text_struct.text, 1, _cursor_char);
				draw_text(draw_x, draw_y, _text);
			}
		}
		
		_x += text_struct.get_width();
	}
	_y += row_height;
}
