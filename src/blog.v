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
	file_data := static_data.get_file(req.url)
	response := match file_data.page_type {
		.homepage {
			generate_home_page(file_data)
		}
		.allposts {
			generate_all_posts(file_data)
		}
		else { file_data.content }
	}

	mut res := Response{
		status_code: file_data.status
		header: http.new_header_from_map({
			CommonHeader.content_type: file_data.content_type.str()
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

pub fn generate_home_page(file_data static_data.FileData) string {
	mut content := file_data.content
	content = content.replace('@BLOGTITLE', blog_title).replace('@PAGETITLE', file_data.title)

	article_db := create_or_open_db() or { panic(err) }
	mut articles := article_db.exec("select title, time_date, content, author from articles order by id desc limit 10;") or { panic(err) }
	mut articles_body := ''
	for article in articles {
		article_time := time.parse(article.vals[1]) or { panic(err) }
		formatted_time := article_time.custom_format('h:mm A // MMM D YYYY')
		article_title := article.vals[0]
		article_author := article.vals[3]
		article_content := article.vals[2]

		articles_body += ' '.repeat(8)
		articles_body += '<article>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<h1>${article_title}</h1>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<p class="date">${formatted_time} <span class="author">posted by ${article_author}</span></p>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<p>${article_content}</p>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<img src="avatar.bmp" alt="Author Avatar" class="avatar">\n'
		articles_body += ' '.repeat(8)
		articles_body += '</article>\n'
	}

	content = content.replace('@POSTS', articles_body)

	return content
}

pub fn generate_all_posts(file_data static_data.FileData) string {
	mut content := file_data.content
	content = content.replace('@BLOGTITLE', blog_title).replace('@PAGETITLE', file_data.title)

	article_db := create_or_open_db() or { panic(err) }
	mut articles := article_db.exec("select title, time_date, content, author from articles order by id desc;") or { panic(err) }
	mut articles_body := ''
	for article in articles {
		article_time := time.parse(article.vals[1]) or { panic(err) }
		formatted_time := article_time.custom_format('h:mm A // MMM D YYYY')
		article_title := article.vals[0]
		article_author := article.vals[3]
		article_content := article.vals[2]

		articles_body += ' '.repeat(8)
		articles_body += '<article>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<h1>${article_title}</h1>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<p class="date">${formatted_time} <span class="author">posted by ${article_author}</span></p>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<p>${article_content}</p>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<img src="avatar.bmp" alt="Author Avatar" class="avatar">\n'
		articles_body += ' '.repeat(8)
		articles_body += '</article>\n'
	}

	content = content.replace('@POSTS', articles_body)

	return content
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
