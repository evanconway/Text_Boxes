/// @description Insert description here
// You can write your code in this editor

var _n = 0;

if (state == _n++) {
	if (keyboard_check_pressed(vk_space)) {
		state++;
		textbox.set_text("This is the next bit of text displayed after keypress.");
		textbox.advance();
	}
} else if (state == _n++) {
	
} else if (state == _n++) {
	
}
