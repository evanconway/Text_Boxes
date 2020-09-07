/// @description Insert description here
// You can write your code in this editor

view_enabled = true;
view_visible[0] = true;
camera_set_view_pos(view_camera[0], 0, 0);

var gui_w_c = floor(display_get_gui_width() / 2 + 0.5);
var gui_h_c = floor(display_get_gui_height() / 2 + 0.5);

text = jtt_create_box_typing_gui(gui_w_c, gui_h_c, 300, 300);
text.set_alignments(fa_center, fa_center, fa_center, fa_center);
text.scroll_increment = 0.7;
//text.effects_default.font = f_handwriting;
//text.effects_default.effect_m = TB_EFFECT_MOVE.SHAKE;
//text.effects_default.shake_magnitude = 0;
//text.effects_default.shake_time_max = 400;

greeting = "I just need to fill this thing up with text so I can see if my linebreak code is still working properly. And also to see if the new \"advance\" function works correctly. This should be more than enough text to fill out multiple pages.";

text.set_text(greeting);
