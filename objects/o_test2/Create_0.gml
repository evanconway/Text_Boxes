/// @description Insert description here
// You can write your code in this editor

view_enabled = true;
view_visible[0] = true;
camera_set_view_pos(view_camera[0], 0, 0);

var gui_w_c = floor(display_get_gui_width() / 2 + 0.5);
var gui_h_c = floor(display_get_gui_height() / 2 + 0.5);

global.JTT_DEFAULT_ALIGN_BOX_H = fa_center;
global.JTT_DEFAULT_ALIGN_BOX_V = fa_center;
global.JTT_DEFAULT_ALIGN_TEXT_H = fa_center;
global.JTT_DEFAULT_ALIGN_TEXT_V = fa_top;
global.JTT_DEFAULT_SCROLL_INCREMENT = 1.5;
/*
global.JTT_DEFAULT_FONT = f_handwriting;
global.JTT_DEFAULT_EFFECT_MOVE = TB_EFFECT_MOVE.SHAKE;
global.JTT_DEFAULT_SHAKE_MAGNITUDE = 0;
global.JTT_DEFAULT_SHAKE_TIME = 400;
*/

text = jtt_create_box_scrolling(600, 400);

greeting = "<wave>Hello!<><n><n> Welcome to <blink>\"Just<> The Text\"!<n><n> Just <wshake:2,100>The<> <green>Text<> is a textbox system that supports numerous effects such as <chromatic>color change<>, <pulse>pulsing<>, typing, and scrolling.";

text.set_text(greeting);
text.advance();
