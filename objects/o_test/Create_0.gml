/// @description Insert description here
// You can write your code in this editor

game_set_speed(30, gamespeed_fps);

textbox = instance_create_depth(100, 100, 50, o_textbox);
textbox.set_text("<shake>Call<none> me <red>Ishmael<default>. Some <aqua float>years<none default> ago, never mind how long precisely, having little or no <yellow>money<default> in my purse, and nothing particular to interest me on shore, I thought I would <wave>sail<none> about a little and see the <blue>watery<default> part of the world. It is a way I have of driving off the spleen and regulating the circulation. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the street, and methodically knocking people's hats off-then, I account it high time to get to sea as soon as I can. This is my substitute for pistol and ball. With a philosophical flourish Cato throws himself upon his sword; I quietly take to the ship. There is nothing surprising in this. If they but knew it, almost all men in their degree, some time or other, cherish very nearly the same feelings towards the ocean with me.");
//textbox.set_text("The quick brown fox jumps over the lazy dog.");

delta_vals = array_create(100, 0);
delta_index = 0;
