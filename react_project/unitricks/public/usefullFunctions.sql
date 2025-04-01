-- add an admin user
INSERT INTO users (username, display_name, is_goofy, following, password) VALUES ('admin', 'admin', FALSE, '{}', 'admin');

-- get all followers of a user
CREATE OR REPLACE FUNCTION get_followers(INT) RETURNS INT[] AS $$
BEGIN
    RETURN ARRAY(SELECT u_id FROM users WHERE $1 = ANY(users.following));
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_followers(1);

CREATE OR REPLACE FUNCTION get_tricklist(
    p_user_id INT,
    p_search TEXT,
    p_categories INT[],
    p_modifiers INT[]
)
RETURNS TABLE (
    t_id INT,
    name TEXT,
    is_combo BOOLEAN,
    liked BOOLEAN,
    landed BOOLEAN,
    landed_on TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.name,
        t.is_combo,
        COALESCE(uta.liked, FALSE) AS liked,
        COALESCE(uta.landed, FALSE) AS landed,
        uta.landed_on
    FROM tricks t
    LEFT JOIN user_trick_actions uta 
        ON t.id = uta.trick_id AND uta.user_id = p_user_id
    WHERE t.is_public = TRUE
      AND (p_search IS NULL OR t.name ILIKE '%' || p_search || '%')
      AND (p_categories IS NULL OR t.category_id = ANY(p_categories))
      AND (p_modifiers IS NULL OR t.modifier_id = ANY(p_modifiers));
END;
$$ LANGUAGE plpgsql;


