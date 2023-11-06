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
	if s.len <= max_length {
		return s
	}

	for i := max_length; i >= 0; i-- {
		if s[i] in [' '.u8(), '\t'.u8(), '\n'.u8()] { return s[..i] + '...' }
	}

	return s[..max_length] + '...'
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


