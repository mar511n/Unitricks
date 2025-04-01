-- create the users table, which contains u_id, username, display_name, is_goofy, following, password
CREATE TABLE users (
    u_id SERIAL PRIMARY KEY,
    username VARCHAR(256) UNIQUE NOT NULL,
    display_name TEXT,
    is_goofy BOOLEAN DEFAULT FALSE,
    following INT[],
    password TEXT NOT NULL
);

-- create the tricks table, which contains t_id, name, description, videolinks, is_combo, start_positions, end_positions, trick_ids, categories, modifiers, proposed_by, public
CREATE TABLE tricks (
    t_id SERIAL PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    description TEXT,
    videolinks TEXT[],
    is_combo BOOLEAN DEFAULT FALSE,
    start_positions TEXT[],
    end_positions TEXT[],
    trick_ids INT[],
    categories TEXT[],
    modifiers TEXT[],
    proposed_by INT NOT NULL,
    public BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (proposed_by) REFERENCES users(u_id)
);

-- create usertricks table, which contains owner_id, trick_id, liked, landed, landed_on
CREATE TABLE usertricks (
    owner_id INT NOT NULL,
    trick_id INT NOT NULL,
    liked BOOLEAN DEFAULT FALSE,
    landed INT DEFAULT 0,
    landed_on TIMESTAMP,
    PRIMARY KEY (owner_id, trick_id),
    FOREIGN KEY (owner_id) REFERENCES users(u_id),
    FOREIGN KEY (trick_id) REFERENCES tricks(t_id)
);

-- create playlists table, which contains p_id, owner_id, name, tricks_ids
CREATE TABLE playlists (
    p_id SERIAL PRIMARY KEY,
    owner_id INT NOT NULL,
    name TEXT,
    tricks_ids INT[],
    FOREIGN KEY (owner_id) REFERENCES users(u_id)
);