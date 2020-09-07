/// @description Insert description here
// You can write your code in this editor

view_enabled = true;
view_visible[0] = true;
camera_set_view_pos(view_camera[0], 0, 0);

var gui_w_c = floor(display_get_gui_width() / 2 + 0.5);
var gui_h_c = floor(display_get_gui_height() / 2 + 0.5);

text = jtt_create_box_typing_gui(gui_w_c, gui_h_c, 400, 300);
text.set_alignments(fa_center, fa_center, fa_center, fa_center);
//text.effects_default.font = f_handwriting;
//text.effects_default.effect_m = TB_EFFECT_MOVE.SHAKE;
//text.effects_default.shake_magnitude = 0;
//text.effects_default.shake_time_max = 400;

greeting = "I can add effects really easily. I just <float>put<> them right in the <pulse>text.<> " +
			"It takes care of line wrapping and text alignment <wshake>automatically<>. " +
			"It even makes the text <float>spill<> over into another box if it's too big for one. " +
			"And of course the typing <wave:5>effect<> was a lot of work. ";
