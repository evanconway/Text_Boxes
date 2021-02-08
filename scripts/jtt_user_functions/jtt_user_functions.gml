// These functions are for the user to create different kinds of text boxes.

global.JTT_DEBUGGING = false;
global.JTT_AUTO_UPDATE = true;
global.JTT_ADVANCE_ON_CREATE = true;

// default textbox settings
global.JTT_DEFAULT_ALIGN_BOX_V = fa_top;
global.JTT_DEFAULT_ALIGN_BOX_H = fa_left;
global.JTT_DEFAULT_ALIGN_TEXT_V = fa_top;
global.JTT_DEFAULT_ALIGN_TEXT_H = fa_left;
global.JTT_DEFAULT_TYPING_TIME = 6; // number of updates between types 
global.JTT_DEFAULT_TYPING_TIME_STOP = 40; // number of  additional updates to wait after typing end punctuation
global.JTT_DEFAULT_TYPING_TIME_PAUSE = 15; // number of additional updates to wait after typing pause punctuation
global.JTT_DEFAULT_TYPING_INCREMENT = 2.2; // number of chars to type when typing time reaches 1  
global.JTT_DEFAULT_TYPING_CHIRP = undefined;
global.JTT_DEFAULT_TYPING_CHIRP_GAIN = 0.5;
global.JTT_DEFAULT_SCROLL_INCREMENT = 0.3; // amount to advance scroll each update
global.JTT_DEFAULT_SCROLL_FADE_BOUND = 10;
global.JTT_DEFAULT_SCROLL_END = 0;

// default effect settings
// entry
global.JTT_DEFAULT_FALL_MAGNITUDE = 20; // the starting offset
global.JTT_DEFAULT_FALL_INCREMENT = 0.9; // this is the percentage the offset becomes each step
global.JTT_DEFAULT_RISE_MAGNITUDE = 20; // same as fall
global.JTT_DEFAULT_RISE_INCREMENT = 0.9;
global.JTT_DEFAULT_FADE_ALPHA_START = 0;
global.JTT_DEFAULT_FADE_ALPHA_END = 1;
global.JTT_DEFAULT_FADE_ALPHA_INCREMENT = 0.04;

// everything else
global.JTT_DEFAULT_FONT = f_jtt_default;
global.JTT_DEFAULT_COLOR = c_white;
global.JTT_DEFAULT_ALPHA_SET = 0.5; // set text alpha 
global.JTT_DEFAULT_EFFECT_ENTER_MOVE = TB_EFFECT_ENTER_MOVE.NONE;
global.JTT_DEFAULT_EFFECT_ENTER_ALPHA = TB_EFFECT_ENTER_ALPHA.NONE;
global.JTT_DEFAULT_EFFECT_MOVE = TB_EFFECT_MOVE.NONE;
global.JTT_DEFAULT_EFFECT_ALPHA = TB_EFFECT_ALPHA.NONE;
global.JTT_DEFAULT_EFFECT_COLOR = TB_EFFECT_COLOR.NONE;
global.JTT_DEFAULT_OFFSET_X = 2;
global.JTT_DEFAULT_OFFSET_Y = 2;
global.JTT_DEFAULT_FLOAT_MAGNITUDE = 3; // distance up/down in pixels text will float
global.JTT_DEFAULT_FLOAT_INCREMENT = 0.07; // amount to increase position along sine function
global.JTT_DEFAULT_WAVE_MAGNITUDE = 2; // distance up/down in pixels text will wave
global.JTT_DEFAULT_WAVE_INCREMENT = 0.1; // amount to increase position along sine function
global.JTT_DEFAULT_WAVE_OFFSET = 1.2; // amount each character offset along sine function
global.JTT_DEFAULT_SHAKE_MAGNITUDE = 2; // distance up/down/left/right in pixels text will shake, 0 yields 1 pixel shake
global.JTT_DEFAULT_SHAKE_TIME = 0.2; // number of shakes per update, non-integer values accepted
global.JTT_DEFAULT_PULSE_ALPHA_MAX = 1;
global.JTT_DEFAULT_PULSE_ALPHA_MIN = 0.4;
global.JTT_DEFAULT_PULSE_INCREMENT = 0.01; // amount alpha changed each update
global.JTT_DEFAULT_BLINK_ALPHA_ON = 1;
global.JTT_DEFAULT_BLINK_ALPHA_OFF = 0;
global.JTT_DEFAULT_BLINK_TIME_ON = 40; // number of updates text visible, integers only
global.JTT_DEFAULT_BLINK_TIME_OFF = 40; // number of updates text invisible, integers only
global.JTT_DEFAULT_CHROMATIC_MAX = 255; // max rgb value for each color red, green, blue
global.JTT_DEFAULT_CHROMATIC_MIN = 0 ; // min rgb value for each color red, green, blue
global.JTT_DEFAULT_CHROMATIC_INCREMENT = 5; // change in rgb each update

/// @func jtt_create_box(*width, *height, *text)
function jtt_create_box() {
	var result = new jtt_textbox();
	result.textbox_width = (argument_count > 0) ? argument[0] : undefined;
	result.textbox_height = (argument_count > 1) ? argument[1] : undefined;
	if ((argument_count > 2) && (is_string(argument[2]))) {
		result.set_text(argument[2]);
		if (global.JTT_ADVANCE_ON_CREATE) {
			result.advance();
		}
	}
	return result;
}

/// @func jtt_create_box_typing(*width, *height, *text)
function jtt_create_box_typing() {
	var result = new jtt_textbox();
	result.textbox_width = (argument_count > 0) ? argument[0] : undefined;
	result.textbox_height = (argument_count > 1) ? argument[1] : undefined;
	result.type_on_nextpage = false;
	if ((argument_count > 2) && (argument[2] != undefined)) {
		result.set_text(argument[2]);
		if (global.JTT_ADVANCE_ON_CREATE) {
			result.advance();
		}
	}
	return result;
}

/// @func jtt_create_box_scrolling(width, height, *text)
function jtt_create_box_scrolling(width, height) {
	var result = new jtt_textbox();
	result.textbox_width = width;
	result.textbox_height = height;
	result.textbox_display_mode = 1;
	if ((argument_count > 2) && (argument[2] != undefined)) {
		result.set_text(argument[2]);
		if (global.JTT_ADVANCE_ON_CREATE) {
			result.advance();
		}
	}
	return result;
}
