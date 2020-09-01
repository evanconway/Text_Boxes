if (text == undefined) exit;

draw_set_valign(fa_top);
draw_set_halign(fa_left);

var _x = 0;
var _y = 40;

for (var irow = 0; irow < ds_list_size(text); irow++) {
	_x = 40;
	var row_height = 0;
	for (var icol = 0; icol < ds_list_size(text[|irow]); icol++) {
		var text_struct = text[|irow][|icol];
		draw_set_font(text_struct.font);
		draw_set_color(text_struct.text_color);
		var draw_x = _x + text_struct.draw_mod_x;
		var draw_y = _y + text_struct.draw_mod_y;
		draw_text(draw_x, draw_y, text_struct.text);
		if (text_struct.get_height() > row_height) row_height = text_struct.get_height();
		_x += text_struct.get_width();
	}
	_y += row_height;
}
