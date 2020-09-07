/// @description Insert description here
// You can write your code in this editor

view_enabled = true;
view_visible[0] = true;
camera_set_view_pos(view_camera[0], 100, 100);

var gui_w_c = floor(display_get_gui_width() / 2 + 0.5);
var gui_h_c = floor(display_get_gui_height() / 2 + 0.5);

text = jtt_create_box_gui(gui_w_c, gui_h_c, 600, 600);
text.set_alignments(fa_center, fa_center, fa_center, fa_center);

var greeting = "<f:f_handwriting shake:0,200>Hello!<n> It's good to meet you.<n> Welcome " +
				"to the <pink>literature club!<no_color><n> You're gonna die... of happiness! Be sure to " +
				"say hi to all the other members before you <244,6,98>leave<no_color> today!<n><n><n>" +
				"may god have <red pulse>mercy<> on your soul...";
				
text.set_text(greeting);
