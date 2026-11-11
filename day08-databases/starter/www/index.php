<?php
declare(strict_types=1);

$dbPath = getenv('CATALOG_DB') ?: __DIR__ . '/../catalog.db';

function h(string $s): string
{
    return htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
}

// TODO: inside try { }: open PDO (ERRMODE_EXCEPTION), run one query that returns
//       path, container, duration_s and GROUP_CONCAT(codec) per file, ordered by path.
// TODO: catch (Throwable $e): http_response_code(500), print a short message, exit(1).
$rows = [];
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Media catalog</title>
</head>
<body>
  <h1>Media catalog</h1>
  <!-- TODO: a table with one row per file. Escape every value with h(). -->
</body>
</html>
