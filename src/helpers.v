module helpers

pub fn shift_html_headers(s string) string {
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
