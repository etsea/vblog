module static_data

enum ContentType {
	text_html
	text_plain
	text_css
	image_bmp
	image_vnd
	font_ttf
}

pub enum PageType {
	homepage
	allposts
	other
}

pub struct FileData {
pub:
	page_type PageType
	title string
	content_type ContentType
	status int
	content string
}

pub fn (ct ContentType) str() string {
	return match ct {
		.text_html { 'text/html' }
		.text_css { 'text/css' }
		.image_bmp { 'image/bmp' }
		.image_vnd { 'image/vnd' }
		.font_ttf { 'font/ttf' }
		else { 'text/plain' }
	}
}

fn new_file_data(page_type PageType, title string, content_type ContentType, status int, content string) FileData {
	return FileData{
		page_type: page_type
		title: title
		content_type: content_type
		status: status
		content: content
	}
}

const (
	files = {
		'/': new_file_data(.homepage, 'Home Page', .text_html, 200, $embed_file('files/homepage.html').to_string())
		'/favicon.ico': new_file_data(.other, 'Favicon', .image_vnd, 200, $embed_file('files/favicon.ico').to_string())
		'/404': new_file_data(.other, '404 Not Found', .text_html, 404, $embed_file('files/404_error.html').to_string())
		'/style.css': new_file_data(.other, 'CSS Stylesheet', .text_css, 200, $embed_file('files/style.css').to_string())
		'/all': new_file_data(.allposts, 'All Posts', .text_html, 200, $embed_file('files/allposts.html').to_string())
		'/avatar.bmp': new_file_data(.other, 'Author Avatar', .image_bmp, 200, $embed_file('files/blog_avatar.bmp').to_string())
		'/cabin.ttf': new_file_data(.other, 'Cabin TTF Font', .font_ttf, 200, $embed_file('files/cabin.ttf').to_string())
		'/cabin_italic.ttf': new_file_data(.other, 'Cabin Italic TTF Font', .font_ttf, 200, $embed_file('files/cabin_italic.ttf').to_string())
	}
)

pub fn get_file(url string) FileData {
	return files[url] or { return files['/404'] }
}
