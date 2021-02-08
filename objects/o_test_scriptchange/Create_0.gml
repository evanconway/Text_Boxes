/// @description Insert description here
// You can write your code in this editor

game_set_speed(60, gamespeed_fps);
global.JTT_DEFAULT_TYPING_CHIRP = snd_textbox_default;
script_text = jtt_create_box_typing(500, 500, "<fall fade>The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.");
script_text.set_text_align_h(fa_left);
