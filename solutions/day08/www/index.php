<?php
declare(strict_types=1);

$dbPath = getenv('CATALOG_DB') ?: __DIR__ . '/../catalog.db';

function h(string $s): string
{
    return htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
}

try {
    if (!is_file($dbPath)) {
        throw new RuntimeException("database not found");
    }
    $pdo = new PDO('sqlite:' . $dbPath, null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $rows = $pdo->query(
        "SELECT f.path, f.container, f.duration_s,
                COALESCE(GROUP_CONCAT(s.codec, ', '), '') AS codecs
         FROM media_file f
         LEFT JOIN stream s ON s.file_id = f.id
         GROUP BY f.id
         ORDER BY f.path"
    )->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {
    http_response_code(500);
    echo "Catalog unavailable: " . h($e->getMessage()) . "\n";
    exit(1);
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Media catalog</title>
  <style>
    body { font-family: sans-serif; margin: 2rem; }
    table { border-collapse: collapse; }
    th, td { border: 1px solid #aaa; padding: 4px 10px; text-align: left; }
  </style>
</head>
<body>
  <h1>Media catalog (<?= count($rows) ?> files)</h1>
  <table>
    <thead>
      <tr><th>Path</th><th>Container</th><th>Duration (s)</th><th>Codecs</th></tr>
    </thead>
    <tbody>
<?php foreach ($rows as $row): ?>
      <tr>
        <td><?= h((string)$row['path']) ?></td>
        <td><?= h((string)$row['container']) ?></td>
        <td><?= h(number_format((float)$row['duration_s'], 1, '.', '')) ?></td>
        <td><?= h((string)$row['codecs']) ?></td>
      </tr>
<?php endforeach; ?>
    </tbody>
  </table>
</body>
</html>
