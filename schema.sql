-- Core CSV tables
CREATE TABLE csv_train (
    SeriesInstanceUID TEXT,
    PatientAge TEXT,
    PatientSex TEXT,
    Modality TEXT,
    Left_Infraclinoid_Internal_Carotid_Artery TEXT,
    Right_Infraclinoid_Internal_Carotid_Artery TEXT,
    Left_Supraclinoid_Internal_Carotid_Artery TEXT,
    Right_Supraclinoid_Internal_Carotid_Artery TEXT,
    Left_Middle_Cerebral_Artery TEXT,
    Right_Middle_Cerebral_Artery TEXT,
    Anterior_Communicating_Artery TEXT,
    Left_Anterior_Cerebral_Artery TEXT,
    Right_Anterior_Cerebral_Artery TEXT,
    Left_Posterior_Communicating_Artery TEXT,
    Right_Posterior_Communicating_Artery TEXT,
    Basilar_Tip TEXT,
    Other_Posterior_Circulation TEXT,
    Aneurysm_Present TEXT
);

CREATE TABLE csv_train_localizers (
    SeriesInstanceUID TEXT,
    SOPInstanceUID TEXT,
    coordinates TEXT,
    location TEXT
);

CREATE TABLE csv_test (
    SeriesInstanceUID TEXT PRIMARY KEY
);

-- Series tracking tables
CREATE TABLE series (
    SeriesInstanceUID TEXT PRIMARY KEY,
    path TEXT,
    dcm_count INTEGER DEFAULT 0
);

CREATE TABLE series_files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    SeriesInstanceUID TEXT,
    SOPInstanceUID TEXT,
    path TEXT UNIQUE,
    size INTEGER
);

CREATE TABLE series_localizers (
    SOPInstanceUID TEXT PRIMARY KEY,
    SeriesInstanceUID TEXT,
    x REAL,
    y REAL,
    location TEXT
);

-- Segmentation files
CREATE TABLE segmentations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT UNIQUE NOT NULL,
    name TEXT,
    ext TEXT,
    size INTEGER,
    SeriesInstanceUID TEXT
);

-- Master tracking table
CREATE TABLE series_master (
    SeriesInstanceUID TEXT PRIMARY KEY,
    in_series_disk INTEGER DEFAULT 0,
    in_segmentations INTEGER DEFAULT 0,
    in_zip INTEGER DEFAULT 0,
    in_csv_train INTEGER DEFAULT 0,
    in_csv_test INTEGER DEFAULT 0,
    in_csv_localizers INTEGER DEFAULT 0
);

-- ZIP archive tracking
CREATE TABLE zip_dirs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT UNIQUE NOT NULL,
    parent_id INTEGER,
    depth INTEGER
);

CREATE TABLE zip_files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT UNIQUE NOT NULL,
    dir_id INTEGER,
    name TEXT,
    size INTEGER,
    packed_size INTEGER,
    modified TEXT,
    crc TEXT,
    attributes TEXT
);

-- Disk files tracking
CREATE TABLE disk_files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT UNIQUE NOT NULL,
    dir_path TEXT,
    name TEXT,
    ext TEXT,
    size INTEGER,
    modified TEXT
);

-- Views for comparing disk vs ZIP
CREATE VIEW disk_vs_zip_missing_on_disk AS
SELECT z.path, z.size, z.packed_size, z.modified, z.crc
FROM zip_files z
LEFT JOIN disk_files d ON d.path = z.path
WHERE d.path IS NULL;

CREATE VIEW disk_vs_zip_extra_on_disk AS
SELECT d.path, d.size, d.modified, d.ext
FROM disk_files d
LEFT JOIN zip_files z ON z.path = d.path
WHERE z.path IS NULL;
