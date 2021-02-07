/// @description Insert description here
// You can write your code in this editor

game_set_speed(60, gamespeed_fps);
global.JTT_DEFAULT_TYPING_CHIRP = snd_textbox_default;
script_text = jtt_create_box_typing(600, 400, "<red shake:2,0.3>Call<> me <yellow float>Ishmael<>.<n>Some years ag<blue>o,<> never mind how long <wave red>precisely<>, having little or no money in my purse, and nothing particular to interest me on shore, I thought I<n> would sail about a little and see the watery part of the world.");
script_text.set_text_align_h(fa_center);
