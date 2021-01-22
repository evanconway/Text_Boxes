/// @description Insert description here
// You can write your code in this editor

var _n = 0;

if (state == _n++) {
	if (keyboard_check_pressed(vk_space)) {
		if (textbox.get_typing_all_finished()) {
			state++;
			textbox.set_text("This is the next bit of text displayed after keypress.");
			textbox.advance();	
		} else {
			textbox.advance();
		}
	}
} else if (state == _n++) {
	if (keyboard_check_pressed(vk_space)) {
		textbox.advance();
	}
} else if (state == _n++) {
	
}
