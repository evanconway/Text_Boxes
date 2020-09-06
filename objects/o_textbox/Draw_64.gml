if (row_i_start == undefined) {
	exit;
}

draw_set_valign(fa_top);
draw_set_halign(fa_left);

if (global.JTT_DEBUGGING) {
	draw_set_color(c_gray);
	draw_set_alpha(1);
	var box_x = x;
	var box_y = y;
	if (alignment_box_h == fa_right) box_x -= textbox_width;
	if (alignment_box_h == fa_center) box_x -= floor(textbox_width / 2 + 0.5);
	if (alignment_box_v == fa_bottom) box_y -= textbox_height;
	if (alignment_box_v == fa_center) box_y -= floor(textbox_height / 2 + 0.5);
	draw_rectangle(box_x, box_y, box_x + textbox_width, box_y + textbox_height, true);
}

/* To determine the y position of the text, we first find
the top and bottom of the box. */
var box_top = y;
if (alignment_box_v == fa_bottom) box_top -= textbox_height;
if (alignment_box_v == fa_center) box_top -= floor(textbox_height / 2 + 0.5);
var box_bottom = box_top + textbox_height;

/* Now we find the starting y position of the text, we start 
by assuming we are scrolling the text, so the text will start at
the bottom. */
var _y = floor(box_bottom + scroll_modifier + 0.5);

// Assign different values based on alignment if page displayed. 
if (reading_mode == 0) {
	if (alignment_text_v == fa_top) _y = box_top;
	if (alignment_text_v == fa_bottom) _y = box_bottom - text_height;
	if (alignment_text_v == fa_center) _y = box_top + floor(textbox_height / 2 + 0.5) - floor(text_height / 2 + 0.5);
}

for (var irow = row_i_start; irow <= cursor_row; irow++) {
	var row_height = text_list_height(text[|irow]);
	
	// we only draw the row if it is within the bounds of the box
	if ((_y >= box_top) && ((_y + row_height) <= box_bottom)) {
	
		// Now we determine x position with same process
		var _x = x;
		if (alignment_box_h == fa_right) _x -= textbox_width;
		if (alignment_box_h == fa_center) _x -= floor(textbox_width / 2 + 0.5);
		if (alignment_text_h == fa_right) _x = _x + textbox_width - text_list_width(text[|irow]);
		if (alignment_text_h == fa_center) _x = _x + textbox_width / 2 - text_list_width(text[|irow]) / 2;
	
		// irow is changed when we reach end of typing, so we store value here
		var row_size = ds_list_size(text[|irow]);
		
		var _cursor_char = floor(cursor);
		
		// Draw each struct in the row. 
		for (var istruct = 0; istruct < row_size; istruct++) {
			var text_struct = text[|irow][|istruct];
			draw_set_font(text_struct.font);
			draw_set_color(text_struct.draw_color);
			draw_set_alpha(text_struct.alpha);
			var draw_x = _x + text_struct.draw_mod_x;
			var draw_y = _y + text_struct.draw_mod_y;
			
			/* Here we determine the alpha of a line of text when scrolling. If the text is
			beyond the bounding value, the alpha modifier is 1. If not, it is the percentage 
			distance between the edge and the boudning value. Note that the bottom row takes
			precedent over the top. */
			var alpha_scroll_mod = 1;
			if ((reading_mode == 1) && (scroll_fade_bound > 0)) {
				if (_y < (box_top + scroll_fade_bound)) {
					alpha_scroll_mod = (_y - box_top) / scroll_fade_bound;
				}
				if ((_y + row_height) > (box_bottom - scroll_fade_bound)) {
					alpha_scroll_mod = (box_bottom - (_y + row_height)) / scroll_fade_bound;
				}
			}
			draw_set_alpha(text_struct.alpha * alpha_scroll_mod);
			
			// if we are not on the cursor row, we can just draw the text
			if (irow < cursor_row) {
				draw_text(draw_x, draw_y, text_struct.text);
			} else {
				
				/* But if we are, we must check to see if the text goes beyond
				the cursor. In which case we'll only draw a portion of the string.*/
				var str_length = string_length(text_struct.text)
				
				// we subtract the length of each struct from _cursor char
				if (str_length < _cursor_char) {
					_cursor_char -= str_length;
					draw_text(draw_x, draw_y, text_struct.text);
				} else {
					/* Once cursor char is smaller than the struct, we draw that 
					portion of the struct. This is the end of drawing. */ 
					istruct = row_size;
					var _text = string_copy(text_struct.text, 1, _cursor_char);
					draw_text(draw_x, draw_y, _text);
				}
			}
			_x += text_struct.get_width();
		}
	}
	_y += row_height;
}
