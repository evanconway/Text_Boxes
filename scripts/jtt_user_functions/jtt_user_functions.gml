// These functions are for the user to create different kinds of text boxes.

global.TEXTBOX_DELTA_TIME = 0;
global.JTT_DEBUGGING = false;
global.JTT_AUTO_UPDATE = true;
global.JTT_ADVANCE_ON_CREATE = true;

// default textbox settings
global.JTT_DEFAULT_ALIGN_BOX_V = fa_top;
global.JTT_DEFAULT_ALIGN_BOX_H = fa_left;
global.JTT_DEFAULT_ALIGN_TEXT_V = fa_top;
global.JTT_DEFAULT_ALIGN_TEXT_H = fa_left;
global.JTT_DEFAULT_TYPING_TIME = 100;
global.JTT_DEFAULT_TYPING_TIME_STOP = 500;
global.JTT_DEFAULT_TYPING_TIME_PAUSE = 200;
global.JTT_DEFAULT_TYPING_INCREMENT = 2.2;
global.JTT_DEFAULT_TYPING_CHIRP = undefined;
global.JTT_DEFAULT_TYPING_CHIRP_GAIN = 0.5;
global.JTT_DEFAULT_SCROLL_INCREMENT = 0.3;
global.JTT_DEFAULT_SCROLL_FADE_BOUND = 10;
global.JTT_DEFAULT_SCROLL_END = 0;

// default effect settings
global.JTT_DEFAULT_FONT = f_jtt_default;
global.JTT_DEFAULT_COLOR = c_white;
global.JTT_DEFAULT_EFFECT_MOVE = TB_EFFECT_MOVE.NONE;
global.JTT_DEFAULT_EFFECT_ALPHA = TB_EFFECT_ALPHA.NONE;
global.JTT_DEFAULT_EFFECT_COLOR = TB_EFFECT_COLOR.NONE;
global.JTT_DEFAULT_OFFSET_X = 2;
global.JTT_DEFAULT_OFFSET_Y = 2;
global.JTT_DEFAULT_FLOAT_MAGNITUDE = 3;
global.JTT_DEFAULT_FLOAT_TIME = 55; // time in ms between increments
global.JTT_DEFAULT_FLOAT_INCREMENT = 0.2;
global.JTT_DEFAULT_WAVE_MAGNITUDE = 2;
global.JTT_DEFAULT_WAVE_TIME = 85; // time in ms between increments
global.JTT_DEFAULT_WAVE_OFFSET = 0.2; // position in sine function in terms of pi
global.JTT_DEFAULT_SHAKE_MAGNITUDE = 1;
global.JTT_DEFAULT_SHAKE_TIME = 80;
global.JTT_DEFAULT_PULSE_ALPHA_MAX = 1;
global.JTT_DEFAULT_PULSE_ALPHA_MIN = 0.4;
global.JTT_DEFAULT_PULSE_TIME = 80;
global.JTT_DEFAULT_PULSE_INCREMENT = 0.05;
global.JTT_DEFAULT_BLINK_ALPHA_ON = 1;
global.JTT_DEFAULT_BLINK_ALPHA_OFF = 0;
global.JTT_DEFAULT_BLINK_TIME_ON = 500;
global.JTT_DEFAULT_BLINK_TIME_OFF = 167;
global.JTT_DEFAULT_CHROMATIC_MAX = 255;
global.JTT_DEFAULT_CHROMATIC_MIN = 0 ;
global.JTT_DEFAULT_CHROMATIC_TIME = 30;
global.JTT_DEFAULT_CHROMATIC_INCREMENT = 10;

/// @func jtt_create_label(x, y, text)
function jtt_create_label(_x, _y, text) {
	var result = instance_create_depth(_x, _y, 0, o_textbox);
	result.set_text(text); // width and height are automatically set here
	result.advance();
	return result;
}

/// @func jtt_create_label_gui(x, y, text)
function jtt_create_label_gui(_x, _y, text) {
	var result = jtt_create_label(_x, _y, text);
	result.is_gui = true;
	return result;
}

/// @func jtt_create_box(x, y, width, height, *text)
function jtt_create_box(_x, _y, width, height) {
	var result = instance_create_depth(_x, _y, 0, o_textbox);
	result.textbox_width = width;
	result.textbox_height = height;
	if ((argument_count > 4) && (argument[4] != undefined)) {
		result.set_text(argument[4]);
		if (global.JTT_ADVANCE_ON_CREATE) {
			result.advance();
		}
	}
	return result;
}

/// @func jtt_create_box_gui(x, y, width, height, *text)
function jtt_create_box_gui(_x, _y, width, height) {
	var text = (argument_count > 4) ? argument[4] : undefined;
	var result = jtt_create_box(_x, _y, width, height, text);
	result.is_gui = true;
	return result;
}

/// @func jtt_create_box_typing(x, y, width, height, *text)
function jtt_create_box_typing(_x, _y, width, height) {
	var result = jtt_create_box(_x, _y, width, height);
	result.type_on_nextpage = false;
	if ((argument_count > 4) && (argument[4] != undefined)) {
		result.set_text(argument[4]);
		if (global.JTT_ADVANCE_ON_CREATE) {
			result.advance();
		}
	}
	return result;
}

/// @func jtt_create_box_typing_gui(x, y, width, height, *text)
function jtt_create_box_typing_gui(_x, _y, width, height) {
	var text = (argument_count > 4) ? argument[4] : undefined;
	var result = jtt_create_box_typing(_x, _y, width, height, text);
	result.is_gui = true;
	return result;
}

/// @func jtt_create_box_scrolling(x, y, width, height, *text)
function jtt_create_box_scrolling(_x, _y, width, height) {
	var result = jtt_create_box(_x, _y, width, height);
	result.textbox_display_mode = 1;
	if ((argument_count > 4) && (argument[4] != undefined)) {
		result.set_text(argument[4]);
		if (global.JTT_ADVANCE_ON_CREATE) {
			result.advance();
		}
	}
	return result;
}

/// @func jtt_create_box_scrolling_gui(x, y, width, height, *text)
function jtt_create_box_scrolling_gui(_x, _y, width, height) {
	var text = (argument_count > 4) ? argument[4] : undefined;
	var result = jtt_create_box_scrolling(_x, _y, width, height, text);
	result.is_gui = true;
	return result;
}