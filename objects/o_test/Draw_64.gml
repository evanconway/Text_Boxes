/// @description Insert description here
// You can write your code in this editor

var arr_length = array_length(delta_vals);
delta_vals[@delta_index] = global.DELTA_TIME;
delta_index += 1;
if (delta_index >= arr_length) delta_index = 0;

var delta_avg = 0;
var delta_min = delta_vals[@0];
var delta_max = delta_vals[@0];
for (var i = 0; i < arr_length; i++) {
	var val = delta_vals[@i];
	delta_avg += val;
	if (val > delta_max) delta_max = val;
	if (val < delta_min) delta_min = val;
}
delta_avg = floor(delta_avg / arr_length + 0.5);
var delta_diff = delta_max - delta_min;

draw_set_font(f_textbox_default);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_lime);
draw_text(10, 10, "Gamespeed: " + string(game_get_speed(gamespeed_fps)));
draw_text(10, 30, "FPS_REAL: " + string(fps_real));
draw_text(10, 50, "DELTA_AVG: " + string(delta_avg));
draw_text(10, 70, "DELTA_DIFF: " + string(delta_diff));
