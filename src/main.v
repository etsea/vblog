module main

import blog { BlogHandler }
import net.http { Server }
import os
import time
import cli { Command }
import term
import markdown

fn main() {
	mut app := Command{
		name: 'vblog'
		description: 'microblog in V'
		version: '0.0.1'
		disable_man: true
		disable_flags: true
	}
	mut add_cmd := Command{
		name: 'add'
		description: 'Add a new article'
		usage: '[title] [content] [author]'
		required_args: 2
		execute: add_func
	}
	mut serve_cmd := Command{
		name: 'serve'
		description: 'Start the server'
		execute: serve_func
	}
	mut parse_cmd := Command{
		name: 'parse'
		description: 'Parse a file for articles to add'
		usage: '[file]'
		required_args: 1
		execute: parse_func
	}
	mut long_cmd := Command{
		name: 'long'
		description: 'Open a text editor to write a long blog post'
		execute: long_func
	}
	app.add_commands([add_cmd, serve_cmd, parse_cmd, long_cmd])
	app.setup()
	app.parse(os.args)
}

fn add_func(cmd Command) ! {
	new_title := cmd.args[0]
	new_content := cmd.args[1]
	new_author := cmd.args[2]
	blog.add_article(new_title, new_content, new_author) or { panic(err) }
}

fn serve_func(cmd Command) ! {
	mut server := Server{
		addr: '127.0.0.1:8080'
		handler: BlogHandler{}
	}
	server.listen_and_serve()
}

fn parse_func(cmd Command) ! {
	blog.parse_articles(cmd.args[0]) or { panic(err) }
}

fn shift_headers(s string) string {
	mut conv := s
	conv = conv.replace('h6>', 'p>')
	conv = conv.replace('h5>', 'p>')
	conv = conv.replace('h4>', 'h6>')
	conv = conv.replace('h3>', 'h5>')
	conv = conv.replace('h2>', 'h4>')
	conv = conv.replace('h1>', 'h3>')

	return conv
}

fn long_func(cmd Command) ! {
	post_title := os.input('Enter post title: ')
	post_author := os.input('Enter author name: ')

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
		html_content = shift_headers(html_content)
	}

	width, _ := term.get_terminal_size()
	term_sep := '='.repeat(width)

	println(term_sep)
	println('POST TITLE: ${post_title}')
	println('        BY: ${post_author}\n')
	println(content)
	println(term_sep + '\n')
	mut verify := os.input_opt('Send post to DB? [y/N] ') or { 'N' }
	verify = verify[0].ascii_str().to_lower()
	if verify == 'y' {
		blog.add_article(post_title, html_content, post_author) or { panic(err) }
	} else {
		println('Post aborted!')
	}



	os.rm(temp_file) or { eprintln('Failed to remove ${temp_file}') }
}
