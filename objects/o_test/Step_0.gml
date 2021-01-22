/// @description Insert description here
// You can write your code in this editor

//textbox.set_text("<shake>Call<> me <chromatic wave>Ishmael<>. Some <aqua float>years<> ago, never mind how long precisely, having little or no <yellow>money<> in my purse, and nothing particular to <185,66,245>interest<> me on shore, I thought I would <wave>sail<> about a little and see the <blue>watery<> part of the world. It is a way I have of <wshake>driving<> off the spleen and regulating the <white pulse wave>circulation<>. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before <wave brown>coffin warehouses<>, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the <gray>street<>, and methodically knocking people's hats off-then, I account it high time to get to sea as soon as I can. This is my substitute for <orange>pistol and ball<>. With a philosophical flourish Cato <float blink>throws<> himself upon his sword; I quietly take to the ship. There is nothing surprising in this. If they but knew it, almost all men in their degree, some time or other, cherish very nearly the same feelings towards the ocean with me.");

continue_text.visible = textbox.get_typing_all_finished();

var gamespeed = game_get_speed(gamespeed_fps);
if (keyboard_check_pressed(vk_f1)) gamespeed -= 30;
if (keyboard_check_pressed(vk_f2)) gamespeed += 30;
gamespeed = clamp(gamespeed, 30, 1000);
game_set_speed(gamespeed, gamespeed_fps);

if (keyboard_check_pressed(vk_space)) {
	textbox.next_page();
}

// text align
if (keyboard_check_pressed(vk_left)) {
	if (textbox.alignment_text_h == fa_right) textbox.set_text_align_h(fa_center);
	else if (textbox.alignment_text_h == fa_center) textbox.set_text_align_h(fa_left);
}
if (keyboard_check_pressed(vk_right)) {
	if (textbox.alignment_text_h == fa_left) textbox.set_text_align_h(fa_center);
	else if (textbox.alignment_text_h == fa_center) textbox.set_text_align_h(fa_right);
}
if (keyboard_check_pressed(vk_up)) {
	if (textbox.alignment_text_v == fa_bottom) textbox.set_text_align_v(fa_center);
	else if (textbox.alignment_text_v == fa_center) textbox.set_text_align_v(fa_top);
}
if (keyboard_check_pressed(vk_down)) {
	if (textbox.alignment_text_v == fa_top) textbox.set_text_align_v(fa_center);
	else if (textbox.alignment_text_v == fa_center) textbox.set_text_align_v(fa_bottom);
}

// box align
if (keyboard_check_pressed(ord("D"))) {
	if (textbox.alignment_box_h == fa_right) textbox.set_box_align_h(fa_center);
	else if (textbox.alignment_box_h == fa_center) textbox.set_box_align_h(fa_left);
}
if (keyboard_check_pressed(ord("A"))) {
	if (textbox.alignment_box_h == fa_left) textbox.set_box_align_h(fa_center);
	else if (textbox.alignment_box_h == fa_center) textbox.set_box_align_h(fa_right);
}
if (keyboard_check_pressed(ord("S"))) {
	if (textbox.alignment_box_v == fa_bottom) textbox.set_box_align_v(fa_center);
	else if (textbox.alignment_box_v == fa_center) textbox.set_box_align_v(fa_top);
}
if (keyboard_check_pressed(ord("W"))) {
	if (textbox.alignment_box_v == fa_top) textbox.set_box_align_v(fa_center);
	else if (textbox.alignment_box_v == fa_center) textbox.set_box_align_v(fa_bottom);
}