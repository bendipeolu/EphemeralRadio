CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

CREATE TABLE track_plays (
    id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    track_id TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lon DOUBLE PRECISION NOT NULL,
    played_at TIMESTAMP NOT NULL
);

-- Optional: Automatically purge records after 1 day (requires job or cron)
