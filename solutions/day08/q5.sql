SELECT f.path, COUNT(*) AS audio_streams
FROM media_file f
JOIN stream s ON s.file_id = f.id
WHERE s.kind = 'audio'
GROUP BY f.id
HAVING COUNT(*) > 1
ORDER BY f.path;
