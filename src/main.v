module main

import blog { BlogHandler }
import net.http { Server }
import os
import cli { Command }

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
	app.add_commands([add_cmd, serve_cmd, parse_cmd])
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
		addr: ':80'
		handler: BlogHandler{}
	}
	server.listen_and_serve()
}

fn parse_func(cmd Command) ! {
	blog.parse_articles(cmd.args[0]) or { panic(err) }
}
