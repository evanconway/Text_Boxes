// These functions are for the user to create different kinds of text boxes.

/// @func jtt_create(x, y, text)
function jtt_create_label(_x, _y, text) {
	var result = instance_create_depth(_x, _y, 0, o_textbox);
	result.set_text(text); // width and height are automatically set here
	return result;
}

/// @func jtt_create_gui(x, y, text)
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