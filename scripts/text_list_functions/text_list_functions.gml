
/// @desc Return pixel width of ds_list of text structs.
function text_list_width(list) {
	var width = 0;
	for (var i = 0; i < ds_list_size(list); i++) {
		width += list[|i].get_width();
	}
	return width;
}

function text_list_height(list) {
	var height = 0;
	for (var i = 0; i < ds_list_size(list); i++) {
		if (list[|i].get_height() > height) {
			height = list[|i].get_height();
		}
	}
	return height;
}

/// @desc Return the combined string length of a list of text structs.
function text_list_length(list) {
	var result = 0;
	for (var i = 0; i < ds_list_size(list); i++) {
		result += string_length(list[|i].text);
	}
	return result;
}

/// @desc Return the combined string value of a list of text structs.
function text_list_string(list) {
	var result = "'";
	for (var i = 0; i < ds_list_size(list); i++) {
		result += list[|i].text;
	}
	return result + "'";
}

/// @desc Remove space at end of line, if it exists.
function line_remove_bookend_spaces(line) {
	if (ds_list_size(line) == 0) return;
	
	// remove starting space
	var struct = line[|0];
	var text_length = string_length(struct.text);
	var first_char = string_char_at(struct.text, 1);
	if (first_char == " ") {
		if (text_length == 1) {
			ds_list_delete(line, 0);
		} else {
			struct.set_text(string_delete(struct.text, 1, 1));
		}
	}
	
	// remove last space
	struct = line[|ds_list_size(line) - 1];
	text_length = string_length(struct.text);
	var last_char = string_char_at(struct.text, text_length);
	if (last_char == " ") {
		if (text_length == 1) {
			ds_list_delete(line, ds_list_size(line) - 1);
		} else {
			struct.set_text(string_delete(struct.text, text_length, 1));
		}
	}
}

/// @desc Add text list to other list, appending text instead of adding structs if possible
function line_add_word(line, word) {
	if (ds_list_size(line) == 0) {
		for (var i = 0; i < ds_list_size(word); i++) ds_list_add(line, word[|i]);
		return;
	} 
	for (var i = 0; i < ds_list_size(word); i++) {
		var last_struct = line[|ds_list_size(line) - 1];
		var word_struct = word[|i];
		if (jtt_text_fx_equal(last_struct, word_struct) && !jtt_text_req_ind_struct(word_struct) && last_struct.sprite == undefined && word_struct.sprite == undefined) {
			last_struct.add_text(word[|i].text);
		} else {
			ds_list_add(line, word[|i]);
		}
	}
}

/// @desc Add text to existing structs if effects are the same, otherwise creates new ones.
function text_list_add(list, text, effects, index) {
	if (text == "") return;
	if (jtt_text_req_ind_struct(effects)) {
		for (var i = 1; i <= string_length(text); i++) {
			var c = string_char_at(text, i);
			ds_list_add(list, new JTT_Text(c, effects, index + i));
		}
		return;
	}
	
	// if list is empty, add new struct
	if (ds_list_size(list) == 0) {
		ds_list_add(list, new JTT_Text(text, effects, index));
		return;
	}
	
	var last_struct = list[|ds_list_size(list) - 1];
	if (jtt_text_fx_equal(effects, last_struct) && last_struct.sprite == undefined) {
			last_struct.add_text(text);
	} else {
		ds_list_add(list, new JTT_Text(text, effects, index));
	}
}

/// @desc Return the character in the text list at the given character index.
function text_list_char_at(list, ichar) {
	ichar = floor(ichar);
	for (var i = 0; i < ds_list_size(list); i++) {
		var struct_text = list[|i].text;
		if (ichar > string_length(struct_text)) ichar -= string_length(struct_text);
		else return string_char_at(struct_text, ichar);	
	}
	return undefined;
}