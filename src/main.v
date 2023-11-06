module main

import blog { BlogHandler }
import cli_funcs
import net.http { Server }
import os
import cli { Command, Flag }

fn main() {
	mut app := Command{
		name: 'vblog'
		description: 'blog in V'
		version: '0.1.0'
		disable_man: true
		disable_flags: true
	}
	mut db_file_flag := Flag{
		flag: .string
		global: true
		name: 'db'
		abbrev: 'd'
		default_value: ['/etc/vblog/articles.db']
	}
	app.add_flag(db_file_flag)

	mut add_cmd := Command{
		name: 'add'
		description: 'Add a new article'
		usage: '[title] [desc] [author] [content]'
		required_args: 4
		execute: cli_funcs.post_create
	}

	mut server_cmd := Command{
		name: 'serve'
		description: 'Start the server'
		execute: cli_funcs.start_server
	}
	mut server_host_flag := Flag{
		flag: .string
		name: 'host'
		abbrev: 'h'
		default_value: ['127.0.0.1']
	}
	mut server_port_flag := Flag{
		flag: .int
		name: 'port'
		abbrev: 'p'
		default_value: ['8080']
	}
	server_cmd.add_flags([server_host_flag, server_port_flag])

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

	app.add_commands([add_cmd, server_cmd, parse_cmd, long_cmd])
	app.setup()
	app.parse(os.args)
}
