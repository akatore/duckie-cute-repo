SELECT f.path
FROM media_file f
LEFT JOIN stream s ON s.file_id = f.id AND s.kind = 'video'
WHERE s.id IS NULL
ORDER BY f.path;
