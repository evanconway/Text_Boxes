draw_set_valign(fa_top);
draw_set_halign(fa_left);

if (jtt_debugging) {
	draw_set_color(c_gray);
	draw_set_alpha(1);
	var box_x = x;
	var box_y = y;
	if (alignment_box_h == fa_right) box_x -= width;
	if (alignment_box_h == fa_center) box_x -= floor(width / 2 + 0.5);
	if (alignment_box_v == fa_bottom) box_y -= height;
	if (alignment_box_v == fa_center) box_y -= floor(height / 2 + 0.5);
	draw_rectangle(box_x, box_y, box_x + width, box_y + height, true);
}

/* To draw the text, we iterate over each row and struct
in the 2D text list. Each time, we subtract the string
length of the struct at irow/ichar from _cursor_char. once
the length of the struct is larger than _cursor_char, we
draw the correct portion of the struct, and we are done. */
var _cursor_char = floor(cursor);

// To determine the y position of the text, we first assume text and box are top aligned.
var _y = y;

// Now we adjust the starting y position based on box alignment
if (alignment_box_v == fa_bottom) _y -= height;
if (alignment_box_v == fa_center) _y -= floor(height / 2 + 0.5);
// Next adjust starting y position based on text alignment

if (alignment_text_v == fa_bottom) _y = _y + height - text_height;
if (alignment_text_v == fa_center) _y = _y + floor(height / 2 + 0.5) - floor(text_height / 2 + 0.5);

for (var irow = 0; irow < ds_list_size(text); irow++) {
	// Now we determine x position with same process
	var _x = x;
	if (alignment_box_h == fa_right) _x -= width;
	if (alignment_box_h == fa_center) _x -= floor(width / 2 + 0.5);
	if (alignment_text_h == fa_right) _x = _x + width - text_list_width(text[|irow]);
	if (alignment_text_h == fa_center) _x = _x + width / 2 - text_list_width(text[|irow]) / 2;
	
	var row_height = 0;
	// irow is changed when we reach end of typing, so we store value here
	var row_size = ds_list_size(text[|irow]);
	for (var istruct = 0; istruct < row_size; istruct++) {
		var text_struct = text[|irow][|istruct];
		draw_set_font(text_struct.font);
		draw_set_color(text_struct.draw_color);
		draw_set_alpha(text_struct.alpha);
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
