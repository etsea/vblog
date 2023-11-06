module helpers

import regex
import strings

pub fn offset_header_tags(s string) string {
	mut conversion := strings.new_builder(s.len)
	parts := s.split_any('<>')
	mut is_tag := false

	for part in parts {
		if is_tag {
			htag_open := regex.regex_opt('^[Hh][1-6]') or { panic(err) }
			htag_close := regex.regex_opt('^/[Hh][1-6]') or { panic(err) }
			if htag_open.matches_string(part) || htag_close.matches_string(part) {
				char_level := if htag_open.matches_string(part) { 0 } else { 1 }
				prefix := [part[char_level]].bytestr()
				check_int := [part[char_level + 1]].bytestr().int()
				mut new_header_level := ''
				if check_int >= 1 && check_int <= 6 {
					new_header_level = if check_int >= 5 { 'p' } else { '${prefix}${check_int + 2}' }
				}
				new_header_level = if char_level == 1 { '/${new_header_level}' } else { new_header_level }
				new_header_level = '<${new_header_level}>'
				write_buffer := new_header_level.bytes()
				conversion.write(write_buffer) or { panic(err) }
			} else {
				write_buffer := '<${part}>'.bytes()
				conversion.write(write_buffer) or { panic(err) }
			}
			is_tag = false
		} else {
			write_buffer := part.bytes()
			conversion.write(write_buffer) or { panic(err) }
			is_tag = true
		}
	}

	return conversion.str()
}

pub fn shorten_post(s string, max_length int) string {
	if s.runes().len <= max_length {
		return s
	}

	mut last_space_index := -1
	for i, current_rune in s.runes() {
		if i >= max_length {
			break
		}
		if current_rune in [` `, `\t`, `\n`, `\r`] {
			last_space_index = i
		}
	}

	if last_space_index != -1 {
		rune_array := s.runes()[..last_space_index]
		mut output_string := ''
		for current_rune in rune_array {
			output_string += current_rune.str()
		}
		output_string = output_string.trim_right(' \t\n\r') + '...'
		return output_string
	} else {
		rune_array := s.runes()[..max_length]
		mut output_string := ''
		for current_rune in rune_array {
			output_string += current_rune.str()
		}
		output_string = output_string + '...'
		return output_string
	}
}

pub fn check_if_post(url string) bool {
	url_query := '^/post\\d+$'
	re := regex.regex_opt(url_query) or { panic(err) }
	return if re.matches_string(url) { true } else { false }
}

pub fn get_post_id(url string) int {
	id_string := url[5..]
	id := id_string.int()
	return id
}


