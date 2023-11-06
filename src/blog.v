module blog

import static_data
import net.http { CommonHeader, Request, Response, Server }
import db.sqlite
import time
import os
import regex
import helpers as hlp

const (
	blog_title = "jeffvos.dev"
)

pub struct BlogHandler {}

fn log_request(req Request) {
	header_host := req.header.get(.host) or { 'UNKNOWN-HOST' }
	header_agent := req.header.get(.user_agent) or { 'UNKNOWN USER-AGENT' }
	println(header_agent)
	println('\t[${header_host}] -> ${req.host}${req.url}')
}

fn check_if_post(url string) bool {
	url_query := '^/post\\d+$'
	re := regex.regex_opt(url_query) or { panic(err) }
	return if re.matches_string(url) { true } else { false }
}

fn get_post_id(url string) int {
	id_string := url[5..]
	id := id_string.int()
	return id
}

fn check_if_in_db(id int) bool {
	article_db := create_or_open_db() or { panic(err) }
	exists := article_db.exec('select exists(select 1 from articles where id = ${id})') or { panic(err) }
	return if exists[0].vals[0] == '1' { true } else { false }
}

fn (h BlogHandler) handle(req Request) Response {
	is_post := check_if_post(req.url)
	mut fetch_url := if is_post { '/post' } else { req.url }
	post_id := if is_post { get_post_id(req.url) } else { 0 }
	if is_post {
		fetch_url = if check_if_in_db(post_id) { fetch_url } else { '/404' }
	}

	log_request(req)
	file_data := static_data.get_file(fetch_url)
	response := match file_data.page_type {
		.homepage {
			generate_home_page(file_data)
		}
		.allposts {
			generate_all_posts(file_data)
		}
		.postpage {
			generate_post_page(file_data, post_id, req.host)
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
	db_file := '/etc/vblog/articles.db'
	db := sqlite.connect(db_file) or {
		eprintln('Could not connect to or create the database: ${db_file}')
		return err
	}
	db.exec("create table if not exists articles (id integer primary key autoincrement, time_date datetime, title text not null, content text not null, author text not null, desc text not null);") or { panic(err) }
	return db
}

pub fn generate_home_page(file_data static_data.FileData) string {
	mut content := file_data.content
	content = content.replace('@BLOGTITLE', blog_title).replace('@PAGETITLE', file_data.title)

	article_db := create_or_open_db() or { panic(err) }
	mut articles := article_db.exec("select title, time_date, desc, author, id from articles order by id desc limit 10;") or { panic(err) }
	mut articles_body := ''
	for article in articles {
		article_time := time.parse(article.vals[1]) or { panic(err) }
		formatted_time := article_time.custom_format('h:mm A // MMM D YYYY')
		article_title := article.vals[0]
		article_author := article.vals[3]
		article_content := hlp.shorten_post(article.vals[2])
		post_id := article.vals[4]

		articles_body += ' '.repeat(8)
		articles_body += '<article>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<h2><a class="title" href="/post${post_id}">${article_title}</a></h2>\n'
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
	mut articles := article_db.exec("select title, time_date, desc, author, id from articles order by id desc;") or { panic(err) }
	mut articles_body := ''
	for article in articles {
		article_time := time.parse(article.vals[1]) or { panic(err) }
		formatted_time := article_time.custom_format('h:mm A // MMM D YYYY')
		article_title := article.vals[0]
		article_author := article.vals[3]
		article_content := article.vals[2]
		post_id := article.vals[4]

		articles_body += ' '.repeat(8)
		articles_body += '<article>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<h2><a class="title" href="/post${post_id}">${article_title}</a></h2>\n'
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

pub fn generate_post_page(file_data static_data.FileData, post_id int, base_url string) string {
	mut content := file_data.content
	content = content.replace('@BLOGTITLE', blog_title)
	content = content.replace('@BASEURL', base_url)
	content = content.replace('@POSTNUMBER', post_id.str())

	article_db := create_or_open_db() or { panic(err) }
	mut articles := article_db.exec("select title, time_date, content, author from articles where id = ${post_id};") or { panic(err) }
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
		articles_body += '<h2>${article_title}</h2>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<p class="date">${formatted_time} <span class="author">posted by ${article_author}</span></p>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<p>${article_content}</p>\n'
		articles_body += ' '.repeat(12)
		articles_body += '<img src="avatar.bmp" alt="Author Avatar" class="avatar">\n'
		articles_body += ' '.repeat(8)
		articles_body += '</article>\n'
		fmt_title, fmt_content := article_title.replace('"', '&quot;'), hlp.shorten_post(article_content.replace('"', '&quot;'))
		content = content.replace('@POSTNAME', fmt_title)
		content = content.replace('@BAREPOSTCONTENT', fmt_content)
	}

	content = content.replace('@POSTCONTENT', articles_body)

	return content
}

pub fn add_article(title string, desc string, author string, content string) ! {
	article_db := create_or_open_db() or {
		eprintln('Unable to open or create SQLITE database.')
		return err
	}
	current_time := time.now().format_ss()
	escaped_title := title.replace("'", "''")
	escaped_content := content.replace("'", "''")
	escaped_author := author.replace("'", "''")
	escaped_desc := desc.replace("'", "''")

	article_db.exec("insert into articles (title, desc, author, time_date, content) values (\'${escaped_title}\', \'${escaped_desc}\', \'${escaped_author}\', \'${current_time}\', \'${escaped_content}\');") or {
		eprintln('Unable to insert article into SQLITE database:')
		eprint('Article: ${title}\nContent: ${content}\n')
		return err
	}
}

pub fn parse_articles(file_path string) ! {
	lines := os.read_lines(file_path) or {
		eprintln('Unable to open or parse file: ${file_path}')
		eprintln('Format:\nTITLE::DESC::AUTHOR::CONTENT')
		return err
	}

	for line in lines {
		data := line.split('::')
		if data.len != 4 {
			eprintln('Invalid entry; skipping:')
			for datum in data {
				println(datum)
			}
			println('\n')
			continue
		} else {
			title, desc, author, content := data[0], data[1], data[2], data[3]
			add_article(title, desc, author, content) or {
				eprintln('Unable to add article: ${title} by ${author}: ${desc}')
				continue
			}
		}
	}
}
