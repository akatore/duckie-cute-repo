SELECT container, COUNT(*) AS files
FROM media_file
GROUP BY container
ORDER BY files DESC, container;
