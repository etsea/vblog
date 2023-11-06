module cli_funcs

import cli { Command }
import blog { BlogHandler }
import helpers as hlp
import net.http { Server }
import os
import time
import term
import markdown

pub fn post_create(cmd Command) ! {
	new_title := cmd.args[0]
	new_desc := cmd.args[1]
	new_author := cmd.args[2]
	new_content := cmd.args[3]
	blog.add_article(new_title, new_desc, new_author, new_content) or { panic(err) }
}

pub fn parse_posts_file(cmd Command) ! {
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
			blog.add_article(title, desc, author, content) or {
				eprintln('Unable to add article: ${title} by ${author}: ${desc}')
				continue
			}
		}
	}
}

pub fn long_post_create(cmd Command) ! {
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
		html_content = hlp.shift_html_headers(html_content)
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
		blog.add_article(post_title, short_desc, post_author, html_content) or { panic(err) }
	} else {
		println('Post aborted!')
	}

	os.rm(temp_file) or { eprintln('Failed to remove ${temp_file}') }
}

pub fn start_server(cmd Command) ! {
	mut server := Server{
		addr: '127.0.0.1:8080'
		handler: BlogHandler{}
	}
	server.listen_and_serve()
}
