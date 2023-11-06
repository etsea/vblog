module database

import db.sqlite
import db.mysql

pub fn connect(db_file string) !sqlite.DB {
	db := sqlite.connect(db_file) or {
		eprintln('Could not connect to or create the database: ${db_file}')
		return err
	}
	db.exec("create table if not exists articles (id integer primary key autoincrement, time_date datetime, title text not null, content text not null, author text not null, description text not null);") or { panic(err) }
	return db
}

pub fn connect_db(dbname string) !mysql.DB {
	db_config := mysql.Config{
		username: 'vblog'
		password: 'vblog'
		dbname: dbname
	}
	db := mysql.connect(db_config) or {
		eprintln('Could not connect to the database: ${db_config}')
		return err
	}
	db.exec("CREATE TABLE IF NOT EXISTS articles (id INTEGER NOT NULL AUTO_INCREMENT, time_date DATETIME, title TEXT NOT NULL, content TEXT NOT NULL, author TEXT NOT NULL, description TEXT NOT NULL, PRIMARY KEY (id));") or { panic(err) }
	return db
}

pub fn validate_post(db_file string, id int) bool {
	db := connect(db_file) or { panic(err) }
	post_ref := db.exec('select exists(select 1 from articles where id = ${id})') or { panic(err) }
	return if post_ref[0].vals[0] == '1' { true } else { false }
}

