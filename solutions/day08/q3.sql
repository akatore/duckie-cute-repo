SELECT codec, COUNT(*) AS streams, MAX(height) AS max_height
FROM stream
WHERE kind = 'video'
GROUP BY codec
ORDER BY codec;
