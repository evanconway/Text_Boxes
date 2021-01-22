/// @description Insert description here
// You can write your code in this editor

var _n = 0;

if (state == _n++) {
	if (keyboard_check_pressed(vk_space)) {
		state++;
		/*
		There is a bug with setting text. Text can only be set when the textbox is 
		first created. We have to find out why setting it again doesn't work. 
		*/
		textbox.set_text("this is the next bit of text displayed after keypress");
	}
} else if (state == _n++) {
	
} else if (state == _n++) {
	
}