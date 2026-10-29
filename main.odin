package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 720

load_font :: proc() -> rl.Font {
	font := rl.LoadFontEx("static/Lato-Regular.ttf", 100, nil, 0)
	// rl.SetTextureFilter(font.texture, .BILINEAR)
	return font
}

main :: proc() {

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Crack IMSI with ODIN!")
	rl.SetTargetFPS(60)
	defer rl.CloseWindow()

	files: [dynamic]string
	defer {
		for f in files do delete(f)
		delete(files)
	}

	global_font := load_font()
	defer rl.UnloadFont(global_font)

	country_scroll_index, country_active, country_focus: i32 = 0, 0, 0
	hash_scr_id, hash_active, hash_focus: i32 = 0, 0, 0
	encoding_scr_id, encoding_active: i32 = 0, 0
	prev_country: i32 = -1
	drop_active: i32 = 0
	dd_open: bool = false
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)
		rl.DrawTextEx(global_font, "Country:", {60, 80}, 32, 0, rl.GRAY)
		rl.DrawTextEx(global_font, "Operator:", {220, 80}, 32, 0, rl.GRAY)
		rl.DrawTextEx(global_font, "Prefix:", {220, 180}, 32, 0, rl.GRAY)
		rl.DrawTextEx(global_font, "Hashing:", {500, 80}, 32, 0, rl.GRAY)
		rl.DrawTextEx(global_font, "Encoding:", {660, 80}, 32, 0, rl.GRAY)

		countries := []cstring{"Turkey", "USA", "Ukraine"}
		rl.GuiSetFont(global_font)
		rl.GuiSetStyle(.DEFAULT, i32(rl.GuiDefaultProperty.TEXT_SIZE), 24)
		rl.GuiSetStyle(.LISTVIEW, i32(rl.GuiListViewProperty.SCROLLBAR_WIDTH), 5)

		cur_county := rl.GuiListViewEx(
			{60, 120, 120, 140},
			raw_data(countries),
			i32(len(countries)),
			&country_scroll_index,
			&country_active,
			&country_focus,
		)

		if prev_country != country_active {
			drop_active = 0
			prev_country = country_active
		}

		countries_arr := COUNTRIES
		selected_country := countries_arr[country_active]

		operators := operators_for_country_id(selected_country.id)


		operator := get_operator(selected_country, int(drop_active))
		imsi_prefix := fmt.caprint(operator.imsi_prefix_code)
		defer delete_cstring(imsi_prefix)
		rl.GuiTextBox({220, 220, 200, 40}, imsi_prefix, 16, false)

		drop_optins := operators_text_by_country_id(selected_country.id)
		if rl.GuiDropdownBox(
			{220, 120, 200, 40},
			strings.clone_to_cstring(drop_optins),
			&drop_active,
			dd_open,
		) {
			dd_open = !dd_open
		}

		hash_algorithms := []cstring{"SHA-256", "MD5"}
		rl.GuiListViewEx(
			{500, 120, 120, 60},
			raw_data(hash_algorithms),
			i32(2),
			&hash_scr_id,
			&hash_active,
			&hash_focus,
		)

		encodings := []cstring{"BASE64"}
		rl.GuiListViewEx(
			{660, 120, 100, 60},
			raw_data(encodings),
			i32(len(encodings)),
			&encoding_scr_id,
			&encoding_active,
			nil,
		)

		crack_pressed := rl.GuiButton({550, 200, 200, 60}, "Crack")

		if crack_pressed {
			selected_hash := Hash(hash_active)
			selected_encoding := EncodingType(encoding_active)
			start_imsi_processing(
				selected_country,
				operator,
				selected_hash,
				selected_encoding,
				"lookup.txt",
			)
		}
		rl.EndDrawing()
	}
}
