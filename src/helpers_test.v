module tests

import helpers

// Testing helpers.offset_header_tags()

// Basic substitution test
fn test_offset_header_basic() {
    input := '<h1>Title</h1><h2>Subtitle</h2><h3>Section</h3><h4>Subsection</h4><h5>Part</h5><h6>Paragraph</h6>'
    expected := '<h3>Title</h3><h4>Subtitle</h4><h5>Section</h5><h6>Subsection</h6><p>Part</p><p>Paragraph</p>'
    assert helpers.offset_header_tags(input) == expected
}

// Test without any tags
fn test_offset_header_no_headers() {
    input := 'This is a paragraph without headers.'
    assert helpers.offset_header_tags(input) == input
}

// Test mixed tag input
fn test_offset_header_mixed_content() {
    input := '<h1>Title</h1><p>Paragraph</p><h2>Subtitle</h2>'
    expected := '<h3>Title</h3><p>Paragraph</p><h4>Subtitle</h4>'
    assert helpers.offset_header_tags(input) == expected
}

// Test empty input
fn test_offset_header_empty_string() {
    assert helpers.offset_header_tags('') == ''
}

// Test case sensitive substitution
fn test_offset_header_case_sensitivity() {
    input := '<H1>Title</H1><h2>Subtitle</h2>'
    expected := '<H3>Title</H3><h4>Subtitle</h4>' // Assuming function should handle case sensitivity
    assert helpers.offset_header_tags(input) == expected
}

// Add any additional test cases as needed


// Testing helpers.shorten_post()

// Test that a string less than 255 chars long
// will be returned unchanged
fn test_shorten_post_short_string() {
	input := 'This is a short string'
	assert helpers.shorten_post(input) == input
}

// Test that a string exactly 255 chars long
// will be returned unchanged
fn test_shorten_post_exactly_255_chars() {
	input := 'a'.repeat(255)
	assert helpers.shorten_post(input) == input
}

// Test that a string with no space but longer
// than 255 chars will return the first 255 chars
// appended with '...'
fn test_shorten_post_long_no_space() {
	input := 'a'.repeat(256)
	expected := 'a'.repeat(255) + '...'
	assert helpers.shorten_post(input) == expected
}

// Test that a string with spaces and longer
// than 255 chars will return the string up
// to the last whitespace before hitting 255
// chars appended with '...'
fn test_shorten_post_long_with_space() {
	input := 'word '.repeat(52)
	expected := 'word '.repeat(50) + 'word...'
	assert helpers.shorten_post(input) == expected
}

// Same as last test, but using \t instead of space
fn test_shorten_post_long_with_tab() {
	input := 'word\t'.repeat(52)
	expected := 'word\t'.repeat(50) + 'word...'
	assert helpers.shorten_post(input) == expected
}

// Same as last test, but using \n instead of \t
fn test_shorten_post_long_with_newline() {
	input := 'word\n'.repeat(52)
	expected := 'word\n'.repeat(50) + 'word...'
	assert helpers.shorten_post(input) == expected
}

// Same as last test, but using \r instead of \n
fn test_shorten_post_long_with_carriage_return() {
	input := 'word\r'.repeat(52)
	expected := 'word\r'.repeat(50) + 'word...'
	assert helpers.shorten_post(input) == expected
}

// Test that a string with utf8 multibyte chars
// will be split correctly without spaces
fn test_shorten_post_utf8_no_spaces() {
	input := 'ä'.repeat(300)
	expected := 'ä'.repeat(255) + '...'
	assert helpers.shorten_post(input) == expected
}

// Test that a string containing utf8 multibyte chars
// and whitespace will still be split correctly
fn test_shorten_post_utf8_spaces() {
	input := 'äé\täé '.repeat(26)
	expected := 'äé\täé '.repeat(25) + 'äé...'
	assert helpers.shorten_post(input) == expected
}
