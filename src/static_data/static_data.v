module static_data

enum ContentType {
	text_html
	text_plain
	text_css
	image_bmp
	image_vnd
	font_ttf
	text_js
}

pub enum PageType {
	homepage
	allposts
	postpage
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
		.text_js { 'text/javascript' }
		else { 'text/plain' }
	}
}

const (
		files = {
			'/': FileData{
				page_type: .homepage
				title: 'Home Page'
				content_type: .text_html
				status: 200
				content: $embed_file('files/homepage.html').to_string()
			}
			'/all': FileData{
				page_type: .allposts
				title: 'All Posts'
				content_type: .text_html
				status: 200
				content: $embed_file('files/allposts.html').to_string()
			}
			'/favicon.ico': FileData{
				page_type: .other
				title: 'Favicon'
				content_type: .image_vnd
				status: 200
				content: $embed_file('files/favicon.ico').to_string()
			}
			'/404': FileData{
				page_type: .other
				title: '404 Not Found'
				content_type: .text_html
				status: 404
				content: $embed_file('files/404_error.html').to_string()
			}
			'/style.css': FileData{
				page_type: .other
				title: 'CSS Stylesheet'
				content_type: .text_css
				status: 200
				content: $embed_file('files/style.css').to_string()
			}
			'/post.css': FileData{
				page_type: .other
				title: 'CSS Stylesheet'
				content_type: .text_css
				status: 200
				content: $embed_file('files/post.css').to_string()
			}
			'/avatar.bmp': FileData{
				page_type: .other
				title: 'Author Avatar'
				content_type: .image_bmp
				status: 200
				content: $embed_file('files/blog_avatar.bmp').to_string()
			}
			'/cabin.ttf': FileData{
				page_type: .other
				title: 'Cabin Font'
				content_type: .font_ttf
				status: 200
				content: $embed_file('files/cabin.ttf').to_string()
			}
			'/cabin_italic.ttf': FileData{
				page_type: .other
				title: 'Cabin Italic Font'
				content_type: .font_ttf
				status: 200
				content: $embed_file('files/cabin_italic.ttf').to_string()
			}
			'/post': FileData{
				page_type: .postpage
				title: '@POSTPAGE'
				content_type: .text_html
				status: 200
				content: $embed_file('files/postpage.html').to_string()
			}
			'/dark_mode.js': FileData{
				page_type: .other
				title: 'Dark Mode Toggle'
				content_type: .text_js
				status: 200
				content: $embed_file('files/dark_mode.js').to_string()
			}
		}
)

pub fn get_file(url string) FileData {
	return files[url] or { return files['/404'] }
}
