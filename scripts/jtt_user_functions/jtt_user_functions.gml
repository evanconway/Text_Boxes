// These functions are for the user to create different kinds of text boxes.

/// @func jtt_create(x, y, text, *alignment_h, *alignment_v)
function jtt_create(_x, _y, text) {
	var result = instance_create_depth(_x, _y, 0, o_textbox);
	result.is_gui = false;
	result.set_text(text); // width and height are automatically set here
	result.jtt_next_page();
	result.jtt_set_typing_finished();
	
	// alignments
	if ((argument_count > 3) && (argument[3] != undefined)) {
		result.set_box_align_h(argument[3]);
		result.set_text_align_h(argument[3]);
	}
	if ((argument_count > 4) && (argument[4] != undefined)) {
		result.set_box_align_v(argument[4]);
		result.set_text_align_v(argument[4]);
	}
	return result;
}

/// @func jtt_create_gui(x, y, text, *alignment_h, *alignment_v)
function jtt_create_gui(_x, _y, text) {
	var _align_h = (argument_count > 3) ? argument[3] : undefined;
	var _align_v = (argument_count > 4) ? argument[4] : undefined;
	var result = jtt_create(_x, _y, text, _align_h, _align_v);
	result.is_gui = true;
	return result;
}

/// @func jtt_create_box(x, y, width, height, *align_box_h, *align_box_v, *align_text_h, *align_text_v)
function jtt_create_box(_x, _y, _width, _height) {
	
}
