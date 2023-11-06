module helpers

import regex
import net.http
import strings

pub fn offset_header_tags(s string) string {
	mut conversion := strings.new_builder(s.len)

	parts := s.split_any('<>')
	mut is_tag := false
	mut write_buffer := []u8{}

	for part in parts {
		if is_tag {
			if part.to_lower().starts_with('h') && part.len == 2 {
				prefix := [part[0]].bytestr()
				check_int := [part[1]].bytestr().int()
				mut new_header_level := ''
				if check_int >= 1 && check_int <= 6 {
					new_header_level = if check_int >= 5 { 'p' } else { '${prefix}${check_int + 2}' }
				} else {
					new_header_level = '${prefix}${check_int}'
				}
				conversion.write(`<`.bytes()) or { panic(err) }
				write_buffer = new_header_level.bytes()
				conversion.write(write_buffer) or { panic(err) }
				conversion.write(`>`.bytes()) or { panic(err) }
			} else if part.to_lower().starts_with('/h') && part.len == 3 {
				prefix := [part[1]].bytestr()
				check_int := [part[2]].bytestr().int()
				mut new_header_level := ''
				if check_int >= 1 && check_int <= 6 {
					new_header_level = if check_int >= 5 { '/p' } else { '/${prefix}${check_int + 2}' }
				} else {
					new_header_level = '/${prefix}${check_int}'
				}
				conversion.write(`<`.bytes()) or { panic(err) }
				write_buffer = new_header_level.bytes()
				conversion.write(write_buffer) or { panic(err) }
				conversion.write(`>`.bytes()) or { panic(err) }
			} else {
				write_buffer = '<${part}>'.bytes()
				conversion.write(write_buffer) or { panic(err) }
			}
			is_tag = false
		} else {
			write_buffer = part.bytes()
			conversion.write(write_buffer) or { panic(err) }
			is_tag = true
		}
	}

	return conversion.str()
}

pub fn shorten_post(s string) string {
	max_length := 255

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

pub fn log_request_to_stdout(req http.Request) {
	header_host := req.header.get(.host) or { 'UNKNOWN-HOST' }
	header_agent := req.header.get(.user_agent) or { 'UNKNOWN USER-AGENT' }
	println(header_agent)
	println('\t[${header_host}] -> ${req.host}${req.url}')
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


