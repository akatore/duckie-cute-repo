CREATE TABLE media_file (
    id          INTEGER PRIMARY KEY,
    path        TEXT    NOT NULL UNIQUE,
    container   TEXT    NOT NULL,
    duration_s  REAL    NOT NULL,
    bit_rate    INTEGER
);

CREATE TABLE stream (
    id            INTEGER PRIMARY KEY,
    file_id       INTEGER NOT NULL REFERENCES media_file(id) ON DELETE CASCADE,
    stream_index  INTEGER NOT NULL,
    kind          TEXT    NOT NULL CHECK (kind IN ('video', 'audio')),
    codec         TEXT    NOT NULL,
    width         INTEGER,
    height        INTEGER,
    sample_rate   INTEGER,
    channels      INTEGER,
    UNIQUE (file_id, stream_index)
);

CREATE INDEX idx_stream_codec ON stream(codec);
