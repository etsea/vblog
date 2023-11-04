module blog

import static_data
import net.http { CommonHeader, Request, Response, Server }
import db.sqlite
import time
import os

const (
	blog_title = "Blog in V"
)

pub struct BlogHandler {}

fn (h BlogHandler) handle(req Request) Response {
	mut status_code := 200
	mut content_type := 'text/html'
	response := match req.url {
		'/' {
			blog.generate_front_page()
		}
		'/all' {
			blog.generate_main_page()
		}
		'/style.css' {
			content_type = 'text/css'
			static_data.return_stylesheet()
		}
		'/avatar.bmp' {
			content_type = 'image/bmp'
			static_data.return_blog_avatar()
		}
		'/cabin.ttf' {
			content_type = 'font/ttf'
			static_data.return_base_font()
		}
		'/cabin_italic.ttf' {
			content_type = 'font/ttf'
			static_data.return_italic_font()
		}
		else {
			status_code = 404
			static_data.return_error_page()
		}
	}
	mut res := Response{
		status_code: status_code
		header: http.new_header_from_map({
			CommonHeader.content_type: content_type
		})
		body: response
	}
	return res
}

fn create_or_open_db() !sqlite.DB {
	db_file := 'articles.db'
	db := sqlite.connect(db_file) or {
		eprintln('Could not connect to or create the database: ${db_file}')
		return err
	}
	db.exec("create table if not exists articles (id integer primary key autoincrement, time_date datetime, title text not null, content text not null, author text not null);") or { panic(err) }
	return db
}

pub fn generate_front_page() string {
	page_title := 'Recent Posts'
	html_template_head := static_data.return_main_page_head().replace('BLOGTITLE', blog_title).replace('PAGETITLE', page_title)
	article_db := create_or_open_db() or { panic(err) }
	mut articles := article_db.exec("select title, time_date, content, author from articles order by id desc;") or { panic(err) }
	mut html_body := ''
	truncate_page := if articles.len > 10 { true } else { false }
	if truncate_page { articles.trim(10) }
	for article in articles {
		article_time := time.parse(article.vals[1]) or { panic(err) }
		formatted_time := article_time.custom_format('h:mm A // MMM D YYYY')
		html_body += '        <article><h1>${article.vals[0]}</h1><p class="date">${formatted_time} <span class="author">posted by ${article.vals[3]}</span></p><p>${article.vals[2]}</p><img src="avatar.bmp" alt="Avatar" class="avatar"></article>\n'
	}
	html_template_tail := if ! truncate_page { static_data.return_main_page_tail() } else { static_data.return_truncated_tail() }

	return html_template_head + html_body + html_template_tail
}

pub fn generate_main_page() string {
	page_title := 'All Posts'
	html_template_head := static_data.return_main_page_head().replace('BLOGTITLE', blog_title).replace('PAGETITLE', page_title)
	article_db := create_or_open_db() or { panic(err) }
	articles := article_db.exec("select title, time_date, content, author from articles order by id desc;") or { panic(err) }
	mut html_body := ''
	for article in articles {
		article_time := time.parse(article.vals[1]) or { panic(err) }
		formatted_time := article_time.custom_format('h:mm A // MMM D YYYY')
		html_body += '        <article><h1>${article.vals[0]}</h1><p class="date">${formatted_time} <span class="author">posted by ${article.vals[3]}</span></p><p>${article.vals[2]}</p><img src="avatar.bmp" alt="Avatar" class="avatar"></article>\n'
	}
	html_template_tail := static_data.return_main_page_tail()

	return html_template_head + html_body + html_template_tail
}

pub fn add_article(title string, content string, author string) ! {
	article_db := create_or_open_db() or {
		eprintln('Unable to open or create SQLITE database.')
		return err
	}
	current_time := time.now().format_ss()
	escaped_title := title.replace("'", "''")
	escaped_content := content.replace("'", "''")
	escaped_author := author.replace("'", "''")

	article_db.exec("insert into articles (title, time_date, content, author) values (\'${escaped_title}\', \'${current_time}\', \'${escaped_content}\', \'${escaped_author}\');") or {
		eprintln('Unable to insert article into SQLITE database:')
		eprint('Article: ${title}\nContent: ${content}\n')
		return err
	}
}

pub fn parse_articles(file_path string) ! {
	lines := os.read_lines(file_path) or {
		eprintln('Unable to open or parse file: ${file_path}')
		return err
	}

	for line in lines {
		data := line.split('::')
		if data.len != 3 {
			eprintln('Invalid entry; skipping: ${data}')
			continue
		} else {
			add_article(data[0], data[1], data[2]) or {
				eprintln('Unable to add article: ${data[0]} by ${data[2]}: ${data[1]}')
				continue
			}
		}
	}
}
