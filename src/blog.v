module blog

import static_data
import net.http { CommonHeader, Request, Response, Server }
import database as dbase
import time
import helpers as hlp

const (
	blog_title = "jeffvos.dev"
)

pub struct BlogHandler {}

fn (h BlogHandler) handle(req Request) Response {
	is_post := hlp.check_if_post(req.url)
	mut fetch_url := if is_post { '/post' } else { req.url }
	post_id := if is_post { hlp.get_post_id(req.url) } else { 0 }
	if is_post {
		fetch_url = if check_if_in_db(post_id) { fetch_url } else { '/404' }
	}

	hlp.log_request(req)
	file_data := static_data.get_file(fetch_url)
	response := match file_data.page_type {
		.homepage {
			generate_home_page(file_data)
		}
		.allposts {
			generate_all_posts_page(file_data)
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

fn check_if_in_db(id int) bool {
	posts_db := dbase.connect() or { panic(err) }
	exists := posts_db.exec('select exists(select 1 from posts where id = ${id})') or { panic(err) }
	return if exists[0].vals[0] == '1' { true } else { false }
}

pub fn generate_home_page(file_data static_data.FileData) string {
	mut content := file_data.content
	content = content.replace('@BLOGTITLE', blog_title).replace('@PAGETITLE', file_data.title)

	posts_db := dbase.connect() or { panic(err) }
	mut posts := posts_db.exec("select title, time_date, desc, author, id from posts order by id desc limit 10;") or { panic(err) }
	mut posts_body := ''
	for article in posts {
		article_time := time.parse(article.vals[1]) or { panic(err) }
		formatted_time := article_time.custom_format('h:mm A // MMM D YYYY')
		article_title := article.vals[0]
		article_author := article.vals[3]
		article_content := hlp.shorten_post(article.vals[2])
		post_id := article.vals[4]

		posts_body += ' '.repeat(8)
		posts_body += '<article>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<h2><a class="title" href="/post${post_id}">${article_title}</a></h2>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<p class="date">${formatted_time} <span class="author">posted by ${article_author}</span></p>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<p>${article_content}</p>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<img src="avatar.bmp" alt="Author Avatar" class="avatar">\n'
		posts_body += ' '.repeat(8)
		posts_body += '</article>\n'
	}

	content = content.replace('@POSTS', posts_body)

	return content
}

pub fn generate_all_posts_page(file_data static_data.FileData) string {
	mut content := file_data.content
	content = content.replace('@BLOGTITLE', blog_title).replace('@PAGETITLE', file_data.title)

	posts_db := dbase.connect() or { panic(err) }
	mut posts := posts_db.exec("select title, time_date, desc, author, id from articles order by id desc;") or { panic(err) }
	mut posts_body := ''
	for article in posts {
		article_time := time.parse(article.vals[1]) or { panic(err) }
		formatted_time := article_time.custom_format('h:mm A // MMM D YYYY')
		article_title := article.vals[0]
		article_author := article.vals[3]
		article_content := article.vals[2]
		post_id := article.vals[4]

		posts_body += ' '.repeat(8)
		posts_body += '<article>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<h2><a class="title" href="/post${post_id}">${article_title}</a></h2>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<p class="date">${formatted_time} <span class="author">posted by ${article_author}</span></p>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<p>${article_content}</p>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<img src="avatar.bmp" alt="Author Avatar" class="avatar">\n'
		posts_body += ' '.repeat(8)
		posts_body += '</article>\n'
	}

	content = content.replace('@POSTS', posts_body)

	return content
}

pub fn generate_post_page(file_data static_data.FileData, post_id int, base_url string) string {
	mut content := file_data.content
	content = content.replace('@BLOGTITLE', blog_title)
	content = content.replace('@BASEURL', base_url)
	content = content.replace('@POSTNUMBER', post_id.str())

	posts_db := dbase.connect() or { panic(err) }
	mut posts := posts_db.exec("select title, time_date, content, author from articles where id = ${post_id};") or { panic(err) }
	mut posts_body := ''
	for article in posts {
		article_time := time.parse(article.vals[1]) or { panic(err) }
		formatted_time := article_time.custom_format('h:mm A // MMM D YYYY')
		article_title := article.vals[0]
		article_author := article.vals[3]
		article_content := article.vals[2]

		posts_body += ' '.repeat(8)
		posts_body += '<article>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<h2>${article_title}</h2>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<p class="date">${formatted_time} <span class="author">posted by ${article_author}</span></p>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<p>${article_content}</p>\n'
		posts_body += ' '.repeat(12)
		posts_body += '<img src="avatar.bmp" alt="Author Avatar" class="avatar">\n'
		posts_body += ' '.repeat(8)
		posts_body += '</article>\n'
		fmt_title, fmt_content := article_title.replace('"', '&quot;'), hlp.shorten_post(article_content.replace('"', '&quot;'))
		content = content.replace('@POSTNAME', fmt_title)
		content = content.replace('@BAREPOSTCONTENT', fmt_content)
	}

	content = content.replace('@POSTCONTENT', posts_body)

	return content
}

pub fn add_article(title string, desc string, author string, content string) ! {
	posts_db := dbase.connect() or {
		eprintln('Unable to open or create SQLITE database.')
		return err
	}
	current_time := time.now().format_ss()
	escaped_title := title.replace("'", "''")
	escaped_content := content.replace("'", "''")
	escaped_author := author.replace("'", "''")
	escaped_desc := desc.replace("'", "''")

	posts_db.exec("insert into articles (title, desc, author, time_date, content) values (\'${escaped_title}\', \'${escaped_desc}\', \'${escaped_author}\', \'${current_time}\', \'${escaped_content}\');") or {
		eprintln('Unable to insert article into SQLITE database:')
		eprint('Article: ${title}\nContent: ${content}\n')
		return err
	}
}

