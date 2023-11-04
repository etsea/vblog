module static_data

pub fn return_error_page() string {
	content := $embed_file('404_error.html')
	return content.to_string()
}

pub fn return_stylesheet() string {
	content := $embed_file('style.css')
	return content.to_string()
}

pub fn return_main_page_head() string {
	content := $embed_file('main_head.html')
	return content.to_string()
}

pub fn return_main_page_tail() string {
	content := $embed_file('main_tail.html')
	return content.to_string()
}

pub fn return_truncated_tail() string {
	content := $embed_file('truncated_tail.html')
	return content.to_string()
}

pub fn return_blog_avatar() string {
	content := $embed_file('blog_avatar.bmp')
	return content.to_string()
}
