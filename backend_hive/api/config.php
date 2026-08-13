<?php
declare(strict_types=1);

const DB_HOST = '127.0.0.1';
const DB_NAME = 'afyahive';
const DB_USER = 'root';
const DB_PASSWORD = '';
const TOKEN_TTL_SECONDS = 604800;
const ALLOWED_ORIGINS = ['http://localhost', 'http://10.0.2.2'];

function db(): PDO {
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }
    $pdo = new PDO(
        'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
        DB_USER,
        DB_PASSWORD,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ],
    );
    return $pdo;
}
