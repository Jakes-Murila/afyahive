<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$isLocalDevelopmentOrigin = preg_match(
    '#^https?://(localhost|127\.0\.0\.1)(:\d{1,5})?$#',
    $origin,
) === 1;
if ($origin !== '' && ($isLocalDevelopmentOrigin || in_array($origin, ALLOWED_ORIGINS, true))) {
    header("Access-Control-Allow-Origin: {$origin}");
    header('Vary: Origin');
}
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header('Content-Type: application/json; charset=utf-8');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function respond(bool $success, string $message, mixed $data = null, int $status = 200): never {
    http_response_code($status);
    echo json_encode(['success' => $success, 'message' => $message, 'data' => $data], JSON_UNESCAPED_SLASHES);
    exit;
}

function body(): array {
    $raw = file_get_contents('php://input');
    if ($raw === false || $raw === '') {
        return $_POST;
    }
    try {
        $value = json_decode($raw, true, 512, JSON_THROW_ON_ERROR);
    } catch (JsonException) {
        respond(false, 'Request body must be valid JSON.', null, 400);
    }
    if (!is_array($value)) {
        respond(false, 'Request body must be a JSON object.', null, 400);
    }
    return $value;
}

function required_string(array $input, string $key, int $max = 500): string {
    $value = trim((string)($input[$key] ?? ''));
    if ($value === '' || mb_strlen($value) > $max) {
        respond(false, "{$key} is required and must be at most {$max} characters.", null, 422);
    }
    return $value;
}

function optional_string(array $input, string $key, int $max = 500): ?string {
    if (!isset($input[$key]) || $input[$key] === null || $input[$key] === '') {
        return null;
    }
    return required_string($input, $key, $max);
}

function current_user_id(): int {
    $header = authorization_header();
    if (!preg_match('/^Bearer\s+([A-Za-z0-9_-]{40,})$/', $header, $matches)) {
        respond(false, 'Authentication is required.', null, 401);
    }
    $statement = db()->prepare(
        'SELECT user_id FROM auth_tokens WHERE token_hash = :token_hash AND expires_at > UTC_TIMESTAMP() LIMIT 1'
    );
    $statement->execute(['token_hash' => hash('sha256', $matches[1])]);
    $userId = $statement->fetchColumn();
    if ($userId === false) {
        respond(false, 'Your session is invalid or expired.', null, 401);
    }
    return (int)$userId;
}

function authorization_header(): string {
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if ($header !== '') {
        return $header;
    }
    if (function_exists('getallheaders')) {
        foreach (getallheaders() as $name => $value) {
            if (strcasecmp($name, 'Authorization') === 0) {
                return (string)$value;
            }
        }
    }
    return '';
}

function id_from_route(array $parts, int $index = 2): ?int {
    $value = $parts[$index] ?? null;
    return is_string($value) && ctype_digit($value) && (int)$value > 0 ? (int)$value : null;
}

function ownership(string $table, int $id, int $userId): void {
    $statement = db()->prepare("SELECT id FROM {$table} WHERE id = :id AND user_id = :user_id LIMIT 1");
    $statement->execute(['id' => $id, 'user_id' => $userId]);
    if ($statement->fetchColumn() === false) {
        respond(false, 'Resource not found.', null, 404);
    }
}
