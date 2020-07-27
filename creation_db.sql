DROP DATABASE IF EXISTS geekbrains;
CREATE DATABASE geekbrains;
USE geekbrains;


DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    firstname VARCHAR(50),
    lastname VARCHAR(50), 
    email VARCHAR(120) UNIQUE,
 	password_hash VARCHAR(100), 
	phone BIGINT UNSIGNED UNIQUE, 
    group_id BIGINT UNSIGNED DEFAULT null,
	
    INDEX users_firstname_lastname_idx(firstname, lastname)
) COMMENT 'пользователи';


DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100),
	
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) COMMENT 'профили';


DROP TABLE IF EXISTS faculties;
CREATE TABLE faculties (
	id SERIAL,
	name ENUM('Python', 'Java', 'Swift', 'C#', 'C++', 'Web development', 'Golang', 'Kotlin', 'Game development'),
	description TEXT
) COMMENT 'факультеты';


DROP TABLE IF EXISTS courses;
CREATE TABLE courses (
	id SERIAL,
	teacher_id BIGINT UNSIGNED,
	fac_id BIGINT UNSIGNED,
	group_id bigint unsigned,
	name varchar(255),
	description TEXT,
	start_date date,
	is_done BIT DEFAULT 0,
	`quarter` ENUM('1','2','3','4'),
	
	FOREIGN KEY (teacher_id) REFERENCES users(id),
	FOREIGN KEY (fac_id) REFERENCES faculties(id)
) COMMENT 'курсы';


DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED,
    body TEXT,
    created_at DATETIME DEFAULT NOW(),

    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
) COMMENT 'сообщения';


DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
	id SERIAL,
	name ENUM('фото', 'видео', 'аудио'),
	created_at DATETIME DEFAULT NOW()
) COMMENT 'тип медиафайла';


DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
	id SERIAL,
	name ENUM('фото', 'видео', 'документ'),
	created_at DATETIME DEFAULT NOW()
) COMMENT 'тип медиафайла';


DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id SERIAL,
	media_type_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	filename VARCHAR(255) COMMENT 'хранение пути к файлу на отдельном диске, чтобы разгрузить базу',
	`size` INT,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE NOW(),
	
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (media_type_id) REFERENCES media_types(id)
) COMMENT 'медиа';


DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
	id SERIAL,
	group_name varchar(100),
	faculty BIGINT UNSIGNED NOT NULL,
	
	INDEX (group_name),
	FOREIGN KEY (faculty) REFERENCES faculties(id)
) COMMENT 'группы учащихся';


ALTER TABLE users 
ADD CONSTRAINT user_group_id
FOREIGN KEY (group_id) REFERENCES `groups`(id);

alter table courses 
add constraint group_course_id
foreign key (group_id) references `groups`(id);


DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
	id SERIAL,
	media_id BIGINT UNSIGNED NOT NULL, -- ссылка на видеоурок, к которому будут оставляться комменты
	user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (media_id) REFERENCES media(id)
);



DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
	id SERIAL,
    user_id BIGINT UNSIGNED NOT NULL,
    comment_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (comment_id) REFERENCES comments(id)
) COMMENT 'спасибо!';


drop table if exists courses_media;
create table courses_media (
	course_id bigint unsigned not null,
	media_id bigint unsigned not null,
	
	primary key (course_id, media_id),
	foreign key (course_id) references courses(id),
	foreign key (media_id) references media(id)
);
