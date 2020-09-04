draw_set_valign(fa_top);
draw_set_halign(fa_left);

draw_set_color(c_gray);
draw_rectangle(x, y, x + width, y + height, true);

/* To draw the text, we iterate over each row and struct
in the 2D text list. Each time, we subtract the string
length of the struct at irow/ichar from _cursor_char. once
the length of the struct is larger than _cursor_char, we
draw the correct portion of the struct, and we are done. */
var _cursor_char = floor(cursor);

var _x = x;
var _y = y;
if (alignment_v == fa_bottom) _y = y + height - text_height;
if (alignment_v == fa_center) _y = y + height / 2 - text_height / 2;

for (var irow = 0; irow < ds_list_size(text); irow++) {
	if (alignment_h == fa_left) _x = x;
	if (alignment_h == fa_right) _x = x + width - text_list_width(text[|irow]);
	if (alignment_h == fa_center) _x = x + width / 2 - text_list_width(text[|irow]) / 2;
	
	var row_height = 0;
	// irow is changed when we reach end of typing, so we store value here
	var row_size = ds_list_size(text[|irow]);
	for (var istruct = 0; istruct < row_size; istruct++) {
		var text_struct = text[|irow][|istruct];
		draw_set_font(text_struct.font);
		draw_set_color(text_struct.text_color);
		var draw_x = _x + text_struct.draw_mod_x;
		var draw_y = _y + text_struct.draw_mod_y;
		if (text_struct.get_height() > row_height) row_height = text_struct.get_height();
		
		if (string_length(text_struct.text) < _cursor_char) {
			_cursor_char -= string_length(text_struct.text);
			draw_text(draw_x, draw_y, text_struct.text);
		} else {
			// if we reach this block, we have reached the end of typing
			istruct = ds_list_size(text[|irow]);
			irow = ds_list_size(text);
			var _text = string_copy(text_struct.text, 1, _cursor_char);
			draw_text(draw_x, draw_y, _text);
		}
		_x += text_struct.get_width();
	}
	_y += row_height;
}
