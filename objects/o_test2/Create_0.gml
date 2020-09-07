/// @description Insert description here
// You can write your code in this editor

view_enabled = true;
view_visible[0] = true;
camera_set_view_pos(view_camera[0], 100, 100);



box_room = jtt_create_box(200, 200, 100, 100);
box_gui = jtt_create_box_gui(display_get_gui_width(), display_get_gui_height(), 300, 300);

box_room.set_alignments(fa_center, fa_center, fa_center, fa_center);
box_gui.set_alignments(fa_bottom, fa_right, fa_center, fa_right);

box_room.set_text("I am the room text.");
box_gui.set_text("<f:f_handwriting offset:0,0,6,0>I am the gui text.<> As you can see I'm quite a bit <wshake>bigger<>. Do not underestimate me... for I am <orange>MIGHTY!!!<>");
