module database

import db.sqlite

pub fn connect() !sqlite.DB {
	db_file := '/etc/vblog/articles.db'
	db := sqlite.connect(db_file) or {
		eprintln('Could not connect to or create the database: ${db_file}')
		return err
	}
	db.exec("create table if not exists articles (id integer primary key autoincrement, time_date datetime, title text not null, content text not null, author text not null, desc text not null);") or { panic(err) }
	return db
}

