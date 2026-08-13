<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$route = trim((string)($_GET['route'] ?? ''), '/');
$parts = $route === '' ? [] : explode('/', $route);

try {
    if ($route === 'health' && $method === 'GET') {
        db()->query('SELECT 1');
        respond(true, 'AfyaHive API is healthy.', ['database' => 'connected']);
    }

    if (($parts[0] ?? '') !== 'v1') {
        respond(false, 'Route not found.', null, 404);
    }

    $resource = $parts[1] ?? '';
    if ($resource === 'auth') {
        auth_route($parts, $method);
    }

    $userId = current_user_id();
    if ($resource === 'profile') {
        profile_route($userId, $method);
    }
    if ($resource === 'dashboard' && $method === 'GET') {
        dashboard_route($userId);
    }
    if ($resource === 'vitals') {
        vitals_route($userId, $parts, $method);
    }
    if ($resource === 'ai' && ($parts[2] ?? '') === 'conversations') {
        conversations_route($userId, $parts, $method);
    }

    $resources = resource_config();
    if (isset($resources[$resource])) {
        generic_resource_route($resources[$resource], $userId, $parts, $method);
    }
    respond(false, 'Route not found.', null, 404);
} catch (PDOException $exception) {
    error_log('AfyaHive database error: ' . $exception->getMessage());
    respond(false, 'A database error occurred.', null, 500);
} catch (Throwable $exception) {
    error_log('AfyaHive API error: ' . $exception->getMessage());
    respond(false, 'An unexpected server error occurred.', null, 500);
}

function auth_route(array $parts, string $method): never {
    $action = $parts[2] ?? '';
    $input = body();
    if ($action === 'register' && $method === 'POST') {
        $firstname = required_string($input, 'firstname', 80);
        $lastname = required_string($input, 'lastname', 80);
        $email = filter_var(trim((string)($input['email'] ?? '')), FILTER_VALIDATE_EMAIL);
        $password = (string)($input['password'] ?? '');
        if ($email === false) respond(false, 'A valid email is required.', null, 422);
        if (strlen($password) < 8 || strlen($password) > 128) respond(false, 'Password must contain 8 to 128 characters.', null, 422);
        $statement = db()->prepare('INSERT INTO users (firstname, lastname, email, password) VALUES (:firstname, :lastname, :email, :password)');
        try {
            $statement->execute(['firstname' => $firstname, 'lastname' => $lastname, 'email' => strtolower($email), 'password' => password_hash($password, PASSWORD_DEFAULT)]);
        } catch (PDOException $exception) {
            if ($exception->getCode() === '23000') respond(false, 'An account with that email already exists.', null, 409);
            throw $exception;
        }
        $userId = (int)db()->lastInsertId();
        respond(true, 'Account created.', issue_session($userId));
    }
    if ($action === 'login' && $method === 'POST') {
        $email = filter_var(trim((string)($input['email'] ?? '')), FILTER_VALIDATE_EMAIL);
        $password = (string)($input['password'] ?? '');
        if ($email === false || $password === '') respond(false, 'Email and password are required.', null, 422);
        $statement = db()->prepare('SELECT id, firstname, lastname, email, password FROM users WHERE email = :email LIMIT 1');
        $statement->execute(['email' => strtolower($email)]);
        $user = $statement->fetch();
        if (!$user || !password_verify($password, $user['password'])) respond(false, 'Invalid email or password.', null, 401);
        respond(true, 'Signed in.', issue_session((int)$user['id'], $user));
    }
    if ($action === 'logout' && $method === 'POST') {
        $userId = current_user_id();
        $header = authorization_header();
        preg_match('/^Bearer\s+(.+)$/', $header, $matches);
        db()->prepare('DELETE FROM auth_tokens WHERE user_id = :user_id AND token_hash = :token_hash')->execute(['user_id' => $userId, 'token_hash' => hash('sha256', $matches[1])]);
        respond(true, 'Signed out.');
    }
    respond(false, 'Route not found.', null, 404);
}

function issue_session(int $userId, ?array $user = null): array {
    if ($user === null) {
        $statement = db()->prepare('SELECT id, firstname, lastname, email FROM users WHERE id = :id');
        $statement->execute(['id' => $userId]);
        $user = $statement->fetch();
    }
    db()->prepare('DELETE FROM auth_tokens WHERE expires_at <= UTC_TIMESTAMP()')->execute();
    $token = rtrim(strtr(base64_encode(random_bytes(48)), '+/', '-_'), '=');
    db()->prepare('INSERT INTO auth_tokens (user_id, token_hash, expires_at) VALUES (:user_id, :token_hash, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 DAY))')->execute(['user_id' => $userId, 'token_hash' => hash('sha256', $token)]);
    unset($user['password']);
    return ['accessToken' => $token, 'expiresIn' => TOKEN_TTL_SECONDS, 'user' => $user];
}

function profile_route(int $userId, string $method): never {
    if ($method === 'GET') {
        $statement = db()->prepare('SELECT u.id, u.firstname, u.lastname, u.email, p.gender, p.date_of_birth, p.height_cm, p.current_weight, p.target_weight FROM users u LEFT JOIN profiles p ON p.user_id = u.id WHERE u.id = :id');
        $statement->execute(['id' => $userId]);
        respond(true, 'Profile retrieved.', $statement->fetch());
    }
    if ($method === 'PUT') {
        $input = body();
        $gender = required_string($input, 'gender', 10);
        if (!in_array($gender, ['Male', 'Female', 'Other'], true)) respond(false, 'gender must be Male, Female, or Other.', null, 422);
        $date = required_string($input, 'date_of_birth', 10);
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) respond(false, 'date_of_birth must be YYYY-MM-DD.', null, 422);
        foreach (['height_cm', 'current_weight', 'target_weight'] as $field) if (!isset($input[$field]) || !is_numeric($input[$field]) || (float)$input[$field] <= 0) respond(false, "{$field} must be a positive number.", null, 422);
        db()->prepare('INSERT INTO profiles (user_id, firstname, lastname, gender, date_of_birth, height_cm, current_weight, target_weight) SELECT id, firstname, lastname, :gender, :date_of_birth, :height_cm, :current_weight, :target_weight FROM users WHERE id = :user_id ON DUPLICATE KEY UPDATE gender = VALUES(gender), date_of_birth = VALUES(date_of_birth), height_cm = VALUES(height_cm), current_weight = VALUES(current_weight), target_weight = VALUES(target_weight)')->execute(['user_id' => $userId, 'gender' => $gender, 'date_of_birth' => $date, 'height_cm' => $input['height_cm'], 'current_weight' => $input['current_weight'], 'target_weight' => $input['target_weight']]);
        respond(true, 'Profile updated.');
    }
    respond(false, 'Method not allowed.', null, 405);
}

function dashboard_route(int $userId): never {
    $pdo = db();
    $out = [];
    $statement = $pdo->prepare('SELECT type, value, secondary_value, unit, recorded_at FROM vital_readings WHERE user_id = :user_id ORDER BY recorded_at DESC');
    $statement->execute(['user_id' => $userId]);
    foreach ($statement as $vital) if (!isset($out['vitals'][$vital['type']])) $out['vitals'][$vital['type']] = $vital;
    $statement = $pdo->prepare("SELECT id, medication_name, dosage, schedule_time FROM medication_reminders WHERE user_id = :user_id AND is_active = 1 ORDER BY schedule_time LIMIT 3");
    $statement->execute(['user_id' => $userId]); $out['reminders'] = $statement->fetchAll();
    $statement = $pdo->prepare("SELECT id, provider_name, specialty, scheduled_at, mode FROM appointments WHERE user_id = :user_id AND status = 'scheduled' AND scheduled_at >= NOW() ORDER BY scheduled_at LIMIT 3");
    $statement->execute(['user_id' => $userId]); $out['appointments'] = $statement->fetchAll();
    $statement = $pdo->prepare('SELECT COALESCE(SUM(duration_minutes), 0) FROM activities WHERE user_id = :user_id AND activity_date = CURDATE()');
    $statement->execute(['user_id' => $userId]); $out['todayActivityMinutes'] = (int)$statement->fetchColumn();
    respond(true, 'Dashboard retrieved.', $out);
}

function vitals_route(int $userId, array $parts, string $method): never {
    if ($method === 'GET') {
        $range = $_GET['range'] ?? 'week';
        $days = ['week' => 7, 'month' => 31, 'year' => 365][$range] ?? null;
        if ($days === null) respond(false, 'range must be week, month, or year.', null, 422);
        $statement = db()->prepare('SELECT id, type, value, secondary_value, unit, recorded_at, source, notes FROM vital_readings WHERE user_id = :user_id AND recorded_at >= DATE_SUB(NOW(), INTERVAL ' . $days . ' DAY) ORDER BY recorded_at DESC');
        $statement->execute(['user_id' => $userId]); respond(true, 'Vitals retrieved.', $statement->fetchAll());
    }
    if ($method === 'POST') {
        $input = body(); $type = required_string($input, 'type', 30);
        $allowed = ['heart_rate', 'blood_pressure', 'blood_oxygen', 'temperature', 'weight', 'blood_glucose'];
        if (!in_array($type, $allowed, true) || !isset($input['value']) || !is_numeric($input['value'])) respond(false, 'A valid vital type and numeric value are required.', null, 422);
        $recordedAt = optional_string($input, 'recorded_at', 19) ?? gmdate('Y-m-d H:i:s');
        db()->prepare('INSERT INTO vital_readings (user_id, type, value, secondary_value, unit, recorded_at, source, notes) VALUES (:user_id, :type, :value, :secondary_value, :unit, :recorded_at, :source, :notes)')->execute(['user_id' => $userId, 'type' => $type, 'value' => $input['value'], 'secondary_value' => isset($input['secondary_value']) && is_numeric($input['secondary_value']) ? $input['secondary_value'] : null, 'unit' => required_string($input, 'unit', 20), 'recorded_at' => $recordedAt, 'source' => optional_string($input, 'source', 40) ?? 'manual', 'notes' => optional_string($input, 'notes', 500)]);
        respond(true, 'Vital reading created.', ['id' => (int)db()->lastInsertId()], 201);
    }
    respond(false, 'Method not allowed.', null, 405);
}

function resource_config(): array {
    return [
        'activities' => ['table' => 'activities', 'fields' => ['activity_type', 'duration_minutes', 'calories_burned', 'distance_km', 'activity_date', 'notes'], 'required' => ['activity_type', 'duration_minutes', 'calories_burned', 'activity_date']],
        'workouts' => ['table' => 'workouts', 'fields' => ['workout_name', 'workout_type', 'duration_burned', 'calories_burned', 'intensity', 'workout_dates', 'notes'], 'required' => ['workout_name', 'workout_type', 'duration_burned', 'intensity', 'workout_dates']],
        'fitness-goals' => ['table' => 'fitness_goals', 'fields' => ['goal_type', 'target_weight', 'target_steps', 'target_calories', 'start_date', 'end_date', 'status'], 'required' => ['goal_type', 'start_date', 'end_date', 'status']],
        'progress-logs' => ['table' => 'progress_logs', 'fields' => ['weight_kg', 'bmi', 'body_fat_percentage', 'muscle_mass', 'waist_cm', 'chest_cm', 'hips_cm', 'log_date'], 'required' => ['log_date']],
        'appointments' => ['table' => 'appointments', 'fields' => ['provider_name', 'specialty', 'scheduled_at', 'location', 'mode', 'status', 'notes'], 'required' => ['provider_name', 'scheduled_at']],
        'reminders' => ['table' => 'medication_reminders', 'fields' => ['medication_name', 'dosage', 'schedule_time', 'frequency', 'is_active', 'notes'], 'required' => ['medication_name', 'schedule_time']],
        'emergency-contacts' => ['table' => 'emergency_contacts', 'fields' => ['name', 'relationship', 'phone', 'is_primary'], 'required' => ['name', 'relationship', 'phone']],
        'medical-records' => ['table' => 'medical_records', 'fields' => ['record_type', 'title', 'details', 'issued_at', 'file_url'], 'required' => ['record_type', 'title']],
        'telemedicine' => ['table' => 'telemedicine_sessions', 'fields' => ['provider_name', 'scheduled_at', 'meeting_url', 'status'], 'required' => ['provider_name', 'scheduled_at']],
        'community-posts' => ['table' => 'community_posts', 'fields' => ['body', 'is_anonymous'], 'required' => ['body']],
    ];
}

function generic_resource_route(array $config, int $userId, array $parts, string $method): never {
    $table = $config['table']; $id = id_from_route($parts);
    if ($method === 'GET' && $id === null) {
        $statement = db()->prepare("SELECT * FROM {$table} WHERE user_id = :user_id ORDER BY created_at DESC, id DESC");
        $statement->execute(['user_id' => $userId]); respond(true, 'Resources retrieved.', $statement->fetchAll());
    }
    if ($method === 'GET' && $id !== null) {
        ownership($table, $id, $userId);
        $statement = db()->prepare("SELECT * FROM {$table} WHERE id = :id"); $statement->execute(['id' => $id]); respond(true, 'Resource retrieved.', $statement->fetch());
    }
    if ($method === 'POST' && $id === null) {
        $input = validate_resource_input($input = body(), $config, false);
        $columns = array_keys($input); $columns[] = 'user_id';
        $statement = db()->prepare("INSERT INTO {$table} (" . implode(', ', $columns) . ') VALUES (' . implode(', ', array_map(fn($column) => ':' . $column, $columns)) . ')');
        $input['user_id'] = $userId; $statement->execute($input); respond(true, 'Resource created.', ['id' => (int)db()->lastInsertId()], 201);
    }
    if (($method === 'PUT' || $method === 'PATCH') && $id !== null) {
        ownership($table, $id, $userId); $input = validate_resource_input(body(), $config, true);
        if ($input === []) respond(false, 'No valid fields were supplied.', null, 422);
        $assignments = implode(', ', array_map(fn($column) => "{$column} = :{$column}", array_keys($input)));
        $input['id'] = $id; $input['user_id'] = $userId;
        db()->prepare("UPDATE {$table} SET {$assignments} WHERE id = :id AND user_id = :user_id")->execute($input);
        respond(true, 'Resource updated.');
    }
    if ($method === 'DELETE' && $id !== null) {
        ownership($table, $id, $userId); db()->prepare("DELETE FROM {$table} WHERE id = :id AND user_id = :user_id")->execute(['id' => $id, 'user_id' => $userId]); respond(true, 'Resource deleted.');
    }
    respond(false, 'Method not allowed.', null, 405);
}

function validate_resource_input(array $input, array $config, bool $partial): array {
    foreach ($config['required'] as $field) if (!$partial && !array_key_exists($field, $input)) respond(false, "{$field} is required.", null, 422);
    $clean = [];
    foreach ($config['fields'] as $field) {
        if (!array_key_exists($field, $input)) continue;
        $value = $input[$field];
        if (in_array($field, ['duration_minutes', 'duration_burned', 'target_steps', 'target_calories'], true)) {
            if (!is_numeric($value) || (int)$value < 0) respond(false, "{$field} must be a non-negative number.", null, 422);
            $clean[$field] = (int)$value;
        } elseif (in_array($field, ['calories_burned', 'distance_km', 'target_weight', 'weight_kg', 'bmi', 'body_fat_percentage', 'muscle_mass', 'waist_cm', 'chest_cm', 'hips_cm'], true)) {
            if ($value !== null && (!is_numeric($value) || (float)$value < 0)) respond(false, "{$field} must be a non-negative number.", null, 422);
            $clean[$field] = $value === null ? null : (float)$value;
        } elseif (in_array($field, ['is_active', 'is_primary', 'is_anonymous'], true)) {
            $clean[$field] = filter_var($value, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
            if ($clean[$field] === null) respond(false, "{$field} must be boolean.", null, 422);
        } else {
            $clean[$field] = $value === null ? null : required_string([$field => $value], $field, $field === 'body' || $field === 'details' || $field === 'notes' ? 5000 : 500);
        }
    }
    return $clean;
}

function conversations_route(int $userId, array $parts, string $method): never {
    $conversationId = id_from_route($parts, 3);
    if ($method === 'GET' && $conversationId === null) {
        $statement = db()->prepare('SELECT id, title, created_at, updated_at FROM ai_conversations WHERE user_id = :user_id ORDER BY updated_at DESC'); $statement->execute(['user_id' => $userId]); respond(true, 'Conversations retrieved.', $statement->fetchAll());
    }
    if ($method === 'POST' && $conversationId === null) {
        $title = optional_string(body(), 'title', 160) ?? 'Health assistant';
        db()->prepare('INSERT INTO ai_conversations (user_id, title) VALUES (:user_id, :title)')->execute(['user_id' => $userId, 'title' => $title]); respond(true, 'Conversation created.', ['id' => (int)db()->lastInsertId()], 201);
    }
    if ($conversationId === null) respond(false, 'Route not found.', null, 404);
    $statement = db()->prepare('SELECT id FROM ai_conversations WHERE id = :id AND user_id = :user_id'); $statement->execute(['id' => $conversationId, 'user_id' => $userId]); if ($statement->fetchColumn() === false) respond(false, 'Conversation not found.', null, 404);
    if ($method === 'GET') {
        $statement = db()->prepare('SELECT id, role, content, created_at FROM ai_messages WHERE conversation_id = :conversation_id ORDER BY created_at'); $statement->execute(['conversation_id' => $conversationId]); respond(true, 'Messages retrieved.', $statement->fetchAll());
    }
    if ($method === 'POST') {
        $content = required_string(body(), 'content', 5000);
        db()->prepare("INSERT INTO ai_messages (conversation_id, role, content) VALUES (:conversation_id, 'user', :content)")->execute(['conversation_id' => $conversationId, 'content' => $content]);
        db()->prepare('UPDATE ai_conversations SET updated_at = CURRENT_TIMESTAMP WHERE id = :id')->execute(['id' => $conversationId]);
        respond(true, 'Message saved. The AI reply is generated by your protected AI service.', ['id' => (int)db()->lastInsertId()], 201);
    }
    respond(false, 'Method not allowed.', null, 405);
}
