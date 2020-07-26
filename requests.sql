/*������������� - ������� ��������� �� ������� ��������*/
CREATE OR REPLACE VIEW v_group AS
SELECT u.firstname, u.lastname, u.email, u.phone, g.group_name, f.name, g.id 
FROM users u 
JOIN `groups` g ON u.group_id = g.id 
JOIN faculties f ON g.faculty = f.id 
WHERE g.id = 1;

/*������� ������ �� �������������*/
SELECT CONCAT(firstname, ' ', lastname) AS full_name
FROM v_group; 


/*������� �� �������� ���� ��������*/
DROP TRIGGER IF EXISTS check_birthday;
CREATE TRIGGER check_birthday BEFORE INSERT ON profiles
FOR EACH ROW
BEGIN
	IF NEW.birthday >= CURRENT_DATE() THEN 
	SIGNAL SQLSTATE '45000' SET message_text = '���� �������� �� ������ ��������� ������� ����!';
	END IF;
END;


/*��������� ��� �������� ��������*/
DROP PROCEDURE IF EXISTS dialogs;
CREATE PROCEDURE dialogs(who BIGINT, with_who BIGINT) -- ����������� BIGINT, ��� ��� ������ � ������� users ����� ���� ���
BEGIN
	SELECT CONCAT(u.firstname, ' ', u.lastname) AS intiator_name, CONCAT(u2.firstname, ' ', u2.lastname) AS target_name, body 
	FROM messages m 
	JOIN users u ON m.from_user_id = u.id 
	JOIN users u2 ON m.to_user_id = u2.id 
	WHERE (m.from_user_id = who OR m.to_user_id = who) AND (m.from_user_id = with_who OR m.to_user_id = with_who)
	ORDER BY m.created_at DESC;
END;

/*����� ������� ����� ������������� � ��������������� 1 � ������������ 11*/
CALL dialogs(1, 11);



/*������������� �������� �������*/
CREATE OR REPLACE VIEW v_user_data AS
	SELECT CONCAT(u.firstname, ' ', u.lastname) AS full_name, p.hometown, u.email, 
		CASE p.gender 
		WHEN 'm' THEN 'male'
		WHEN 'f' THEN 'female'
		END AS gen,
		u.phone, p.photo_id, g.group_name, c.name AS course_name 
	FROM profiles p
	JOIN users u ON u.id = p.user_id 
	JOIN `groups` g ON g.id = u.group_id
	JOIN courses c ON c.fac_id = g.faculty 
	JOIN faculties f ON f.id = c.fac_id
	WHERE u.id = 1;


/*��� �������� �������� ������� ���������� ��� ���������� � ���*/
SELECT full_name, hometown, email, gen, phone, photo_id, group_name 
FROM v_user_data
GROUP BY full_name;


/*��� �������� �������� ������ �������� � ������� ���������� ��������� �� �����*/
SELECT course_name
FROM v_user_data;

/*�������������, ����� ��������� ����� � ������*/
CREATE OR REPLACE VIEW v_media_course AS
	SELECT c.id, c.name, m.filename
	FROM courses_media cm
	JOIN courses c ON c.id = cm.course_id 
	JOIN media m ON m.id = cm.media_id; 

SELECT name, filename FROM v_media_course;


/*������� ������ �� ������ ��������*/
DROP PROCEDURE IF EXISTS group_course; 
CREATE PROCEDURE group_course(group_id BIGINT)
BEGIN
	SELECT f.name AS faculty, g.group_name, c.name AS course_name,
		CASE c.is_done 
		WHEN 0 THEN 'in_progress' 
		WHEN 1 THEN 'finished' 
		END AS status
	FROM courses c 
	JOIN courses_media cm ON cm.course_id = c.id 
	JOIN faculties f ON f.id = c.fac_id 
	JOIN `groups` g ON g.faculty = f.id
	WHERE g.id = group_id;
END;

CALL group_course(5);


/*������� �������� �����*/
DROP PROCEDURE IF EXISTS comments_lesson;
CREATE PROCEDURE comments_lesson(lesson_id BIGINT)
BEGIN
	SELECT cm.course_id, m.id AS media_id, m.filename AS video_les, c.body AS comments_to_les, COUNT(l.comment_id) AS usefull_comment
		FROM courses_media cm
		JOIN media m ON m.id = cm.media_id 
		JOIN comments c ON m.id = c.media_id 
		LEFT JOIN likes l ON l.comment_id = c.id 		-- left join ��� ����, ����� � ������� ����������� �����������, ������� �� ���������� ��������� �� ������ ������������� �������
	GROUP BY c.id 
	HAVING cm.course_id = lesson_id
	ORDER BY m.filename;
END;


CALL comments_lesson(1);










