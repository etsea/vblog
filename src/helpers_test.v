module tests

import helpers

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
