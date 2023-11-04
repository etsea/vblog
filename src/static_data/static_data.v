module static_data

enum ContentType {
	text_html
	text_plain
	text_css
	image_bmp
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
	content_type ContentType
	status int
	content string
}

pub fn (ct ContentType) str() string {
	return match ct {
		.text_html { 'text/html' }
		.text_css { 'text/css' }
		.image_bmp { 'image/bmp' }
		.font_ttf { 'font/ttf' }
		else { 'text/plain' }
	}
}

fn new_file_data(page_type PageType, content_type ContentType, status int, content string) FileData {
	return FileData{
		page_type: page_type
		content_type: content_type
		status: status
		content: content
	}
}

const (
	files = {
		'/': new_file_data(.homepage, .text_html, 200, $embed_file('files/homepage.html').to_string())
		'/404': new_file_data(.other, .text_html, 404, $embed_file('files/404_error.html').to_string())
		'/style.css': new_file_data(.other, .text_css, 200, $embed_file('files/style.css').to_string())
		'/all': new_file_data(.allposts, .text_html, 200, $embed_file('files/allposts.html').to_string())
		'/avatar.bmp': new_file_data(.other, .image_bmp, 200, $embed_file('files/blog_avatar.bmp').to_string())
		'/cabin.ttf': new_file_data(.other, .font_ttf, 200, $embed_file('files/cabin.ttf').to_string())
		'/cabin_italic.ttf': new_file_data(.other, .font_ttf, 200, $embed_file('files/cabin_italic.ttf').to_string())
	}
)

pub fn get_file(url string) FileData {
	return files[url] or { return files['/404'] }
}
