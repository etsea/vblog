module cli_funcs

import cli { Command }
import blog { BlogHandler }
import helpers as hlp
import net.http { Server }
import os
import time
import term
import markdown
import database as dbase

pub fn post_create(cmd Command) ! {
	db_file := cmd.flags.get_string('db') or { panic(err) }
	title := cmd.args[0]
	desc := cmd.args[1]
	author := cmd.args[2]
	content := cmd.args[3]

	blog.add_post(db_file, title, desc, author, content) or {
		eprintln('Failed to add post: ${err}')
		return err
	}
}

pub fn parse_posts_file(cmd Command) ! {
	db_file := cmd.flags.get_string('db') or { panic(err) }
	file_path := cmd.args[0]
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
			blog.add_post(db_file, title, desc, author, content) or {
				eprintln('Unable to add article: ${title} by ${author}: ${desc}')
				continue
			}
		}
	}
}

pub fn long_post_create(cmd Command) ! {
	db_file := cmd.flags.get_string('db') or { panic(err) }
	post_title := os.input('Enter post title: ')
	post_author := os.input('Enter author name: ')
	short_desc := os.input('Enter a short description: ')

	mut editor := os.getenv('EDITOR')
	if editor == '' { editor = 'nvim' }
	temp_dir := os.temp_dir()
	timestamp := time.now().custom_format('MMDDYY-HHmmss')
	temp_file := '${temp_dir}/${timestamp}.txt'

	exec := '${editor} ${temp_file}'
	success := os.system(exec)

	mut content := ''
	mut html_content := ''
	if success == 0 {
		content = os.read_file(temp_file) or {
			eprintln('Failed to open the temp file')
			return
		}
		content = content.trim_space()
		html_content = markdown.to_html(content)
		html_content = hlp.offset_header_tags(html_content)
	}

	width, _ := term.get_terminal_size()
	term_sep := '='.repeat(width)

	println(term_sep)
	println('POST TITLE: ${post_title}')
	println('        BY: ${post_author}')
	println(term_sep)
	println(content)
	println(term_sep + '\n')
	mut verify := os.input_opt('Publish post? [y/N] ') or { 'N' }
	verify = verify[0].ascii_str().to_lower()
	if verify == 'y' {
		blog.add_post(db_file, post_title, short_desc, post_author, html_content) or { panic(err) }
	} else {
		println('Post aborted!')
	}

	os.rm(temp_file) or { eprintln('Failed to remove ${temp_file}') }
}

pub fn start_server(cmd Command) ! {
	db_file := cmd.flags.get_string('db') or { panic(err) }
	host := cmd.flags.get_string('host') or { panic(err) }
	port := cmd.flags.get_int('port') or { panic(err) }
	mut server := Server{
		addr: '${host}:${port}'
		handler: BlogHandler{ db: db_file }
	}
	server.listen_and_serve()
}

pub fn export_posts(cmd Command) ! {
	db_file := cmd.flags.get_string('db') or { panic(err) }
	db := dbase.connect(db_file) or { panic(err) }
	mut destination := os.getwd() + if os.user_os() == 'windows' { '\\' } else { '/' }
	destination += os.input('Destination: ${destination}')
	if destination == os.getwd() { destination += 'exported_posts.txt' }
	mut posts := db.exec('select title, desc, author, content from articles') or { panic(err) }
	mut lines := ''
	for post in posts {
		lines += '${post.vals[0]}::${post.vals[1]}::${post.vals[2]}::${post.vals[3]}\n'
	}
	os.write_file(destination, lines) or { panic(err) }
}
