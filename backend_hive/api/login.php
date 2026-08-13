<?php
declare(strict_types=1);

// Backwards-compatible route. Use POST /api.php?route=v1/auth/login for new clients.
$_GET['route'] = 'v1/auth/login';
require __DIR__ . '/api.php';
