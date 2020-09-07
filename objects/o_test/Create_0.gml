/// @description Insert description here
// You can write your code in this editor

game_set_speed(60, gamespeed_fps);
display_reset(0, true);
box_x = floor(camera_get_view_width(view_camera[0]) / 2);
box_y = floor(camera_get_view_height(view_camera[0]) / 2);
textbox = instance_create_depth(box_x, box_y, 50, o_textbox);
textbox.set_text("<shake>Call<> me <chromatic wave:2,70,180>Ishmael<>. Some <aqua float>years<> ago, <blink:1000,300,700,200 green>never<> <pulse:1000,300,300,200>mind<> how long precisely, having little or no <yellow>money<> in my purse, and nothing particular to <185,66,245 pulse>interest<> me on shore, I thought I would <wave>sail<> about a little and see the <blue>watery<> part of the world. It is a way I have of <wshake:3,100>driving<> off the <offset:10,0,0,0>spleen<> and regulating the <white wave>circulation<>. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before <wave brown>coffin warehouses<>, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the <gray>street<>, and methodically knocking people's hats off-then, I account it high time to get to sea as soon as I can. This is my substitute for <orange>pistol and ball<>. With a philosophical flourish Cato <float blink>throws<> himself upon his sword; I quietly take to the ship. There is nothing surprising in this. If they but knew it, almost all men in their degree, some time or other, cherish very nearly the same feelings towards the ocean with me.");
textbox.textbox_display_mode = 1;
textbox.jtt_next_page();
textbox.jtt_set_typing_finished();

var def_val = 1000000/game_get_speed(gamespeed_fps);
delta_vals = array_create(100, def_val);
delta_index = 0;

continue_text = instance_create_depth(box_x, (box_y + textbox.textbox_height), 0, o_textbox);
continue_text.set_text("<white pulse float:1>Continue...");
continue_text.jtt_next_page();
continue_text.jtt_set_typing_finished();
continue_text.alignment_box_h = fa_center;
continue_text.alignment_box_v = fa_top;
continue_text.alignment_text_h = fa_center;
continue_text.alignment_text_v = fa_top;
