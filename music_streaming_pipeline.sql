

-- Creating Core Tables

-- Table: artists
CREATE TABLE artists (
    artist_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    nationality VARCHAR(100),
    debut_year INT CHECK (debut_year > 1900)
);

-- Table: albums
CREATE TABLE albums (
    album_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_date DATE NOT NULL,
    artist_id INT REFERENCES artists(artist_id) ON DELETE CASCADE
);

-- Table: songs
CREATE TABLE songs (
    song_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    duration INTERVAL NOT NULL,
    release_year INT CHECK (release_year > 1900),
    album_id INT REFERENCES albums(album_id) ON DELETE CASCADE
);

-- Table: user_listening_history
CREATE TABLE user_listening_history (
    history_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    song_id INT REFERENCES songs(song_id) ON DELETE CASCADE,
    listened_at TIMESTAMP DEFAULT NOW()
);

-- Queries

-- Retrieve the Top 10 Most Played Songs
SELECT s.title, COUNT(ulh.song_id) AS play_count
FROM user_listening_history ulh
JOIN songs s ON ulh.song_id = s.song_id
GROUP BY s.title
ORDER BY play_count DESC
LIMIT 10;

-- Calculate the Average Duration of Songs in Each Album
SELECT a.title AS album_title, AVG(s.duration) AS avg_song_duration
FROM albums a
JOIN songs s ON a.album_id = s.album_id
GROUP BY a.title;

-- Find the Year Each Artist Released Their First Song
SELECT ar.name AS artist_name, MIN(s.release_year) AS first_release_year
FROM artists ar
JOIN albums al ON ar.artist_id = al.artist_id
JOIN songs s ON al.album_id = s.album_id
GROUP BY ar.name;

-- Identify Users Who Have Listened to At Least One Song from All Albums Released in a Specific Year
WITH album_counts AS (
    SELECT COUNT(DISTINCT album_id) AS total_albums
    FROM albums
    WHERE EXTRACT(YEAR FROM release_date) = 2023
),
user_album_counts AS (
    SELECT ulh.user_id, COUNT(DISTINCT a.album_id) AS albums_listened
    FROM user_listening_history ulh
    JOIN songs s ON ulh.song_id = s.song_id
    JOIN albums a ON s.album_id = a.album_id
    WHERE EXTRACT(YEAR FROM a.release_date) = 2023
    GROUP BY ulh.user_id
)
SELECT uac.user_id
FROM user_album_counts uac, album_counts ac
WHERE uac.albums_listened = ac.total_albums;

-- Modify the songs Table to Store the Genre & Populate Existing Records
ALTER TABLE songs ADD COLUMN genre VARCHAR(100);

UPDATE songs 
SET genre = 'Pop' 
WHERE title IN ('Song A', 'Song B');  -- Modify as needed

-- Create a separate genre table
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

ALTER TABLE songs ADD COLUMN genre_id INT REFERENCES genres(genre_id);

-- Insert unique genres
INSERT INTO genres (name) 
SELECT DISTINCT genre FROM songs WHERE genre IS NOT NULL;

-- Link songs to genre table
UPDATE songs 
SET genre_id = (SELECT genre_id FROM genres WHERE genres.name = songs.genre);

