module main

import blog { BlogHandler }
import cli_funcs
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
		usage: '[title] [desc] [author] [content]'
		required_args: 4
		execute: cli_funcs.post_create
	}
	mut serve_cmd := Command{
		name: 'serve'
		description: 'Start the server'
		execute: cli_funcs.start_server
	}
	mut parse_cmd := Command{
		name: 'parse'
		description: 'Parse a file for articles to add'
		usage: '[file]'
		required_args: 1
		execute: cli_funcs.parse_posts_file
	}
	mut long_cmd := Command{
		name: 'long'
		description: 'Open a text editor to write a long blog post'
		execute: cli_funcs.long_post_create
	}
	app.add_commands([add_cmd, serve_cmd, parse_cmd, long_cmd])
	app.setup()
	app.parse(os.args)
}
