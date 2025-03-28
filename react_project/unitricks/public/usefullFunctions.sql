-- add an admin user
INSERT INTO users (username, display_name, is_goofy, following, password) VALUES ('admin', 'admin', FALSE, '{}', 'admin');

-- get all followers of a user
CREATE OR REPLACE FUNCTION get_followers(INT) RETURNS INT[] AS $$
BEGIN
    RETURN ARRAY(SELECT u_id FROM users WHERE $1 = ANY(users.following));
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_followers(1);