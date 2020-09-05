/// @description Insert description here
// You can write your code in this editor

draw_set_font(f_textbox_default);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_lime);
draw_text(10, 10, "Gamespeed: " + string(game_get_speed(gamespeed_fps)));
draw_text(10, 30, "FPS_REAL: " + string(fps_real));
