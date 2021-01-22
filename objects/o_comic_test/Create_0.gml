/// @description Insert description here
// You can write your code in this editor

view_enabled = true;
view_visible[0] = true;

res = 300;

surface_resize(application_surface, res, res);
display_set_gui_size(res, res);
camera_set_view_pos(view_camera[0], 0, 0);
window_set_size(res * 3, res * 3);
display_reset(0, true);

state = 0;

global.JTT_DEFAULT_TYPING_CHIRP = snd_textbox_default;
textbox = jtt_create_box_typing_gui(0, 0, res, res);
textbox.set_text("I'm the first text. Notice how I appear to line wrap correctly.");
textbox.advance();

show_debug_message("Fits one page: " + string(textbox.get_fits_onepage()));
