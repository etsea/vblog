module helpers

import regex
import net.http

pub fn offset_header_tags(s string) string {
	mut conv := s
	conv = conv.replace('h6>', 'p>')
	conv = conv.replace('h5>', 'p>')
	conv = conv.replace('h4>', 'h6>')
	conv = conv.replace('h3>', 'h5>')
	conv = conv.replace('h2>', 'h4>')
	conv = conv.replace('h1>', 'h3>')

	return conv
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


