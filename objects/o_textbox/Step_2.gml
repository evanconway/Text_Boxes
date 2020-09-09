/// @desc Auto Update

if (keyboard_check_pressed(ord("D"))) {
	show_debug_message("Debug pressed.");
}

if (global.JTT_AUTO_UPDATE) update();
