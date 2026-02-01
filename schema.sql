PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS maintenance_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    summary TEXT NOT NULL,
    aircraft_reg TEXT NOT NULL,
    maintenance_type TEXT NOT NULL,
    priority TEXT NOT NULL,
    technician_name TEXT,
    notes TEXT,
    user_id INTEGER,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS maintenance_log_media (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    maintenance_log_id INTEGER NOT NULL,
    media_type TEXT NOT NULL,
    file_name TEXT,
    file_path TEXT,
    media_blob BLOB,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (maintenance_log_id) REFERENCES maintenance_logs(id) ON DELETE CASCADE,
    CHECK (media_type IN ('image', 'video')),
    CHECK (
        (file_path IS NOT NULL AND media_blob IS NULL)
        OR (file_path IS NULL AND media_blob IS NOT NULL)
    )
);


