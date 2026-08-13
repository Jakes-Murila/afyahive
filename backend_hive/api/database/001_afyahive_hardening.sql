-- One-time, data-preserving migration for the existing afyahive database.
USE afyahive;

ALTER TABLE users
  MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  MODIFY firstname VARCHAR(80) NOT NULL,
  MODIFY lastname VARCHAR(80) NOT NULL,
  MODIFY email VARCHAR(191) NOT NULL,
  MODIFY password VARCHAR(255) NOT NULL,
  ADD COLUMN created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE profiles
  CHANGE id user_id INT UNSIGNED NOT NULL,
  MODIFY firstname VARCHAR(80) NOT NULL,
  MODIFY lastname VARCHAR(80) NOT NULL,
  MODIFY height_cm DECIMAL(5,2) NOT NULL,
  MODIFY current_weight DECIMAL(5,2) NOT NULL,
  MODIFY target_weight DECIMAL(5,2) NOT NULL,
  ADD PRIMARY KEY (user_id),
  ADD CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE activities
  MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  MODIFY user_id INT UNSIGNED NOT NULL,
  MODIFY duration_minutes SMALLINT UNSIGNED NOT NULL,
  MODIFY calories_burned DECIMAL(8,2) NOT NULL,
  MODIFY distance_km DECIMAL(8,2) NULL,
  MODIFY created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD PRIMARY KEY (id),
  ADD INDEX idx_activities_user_date (user_id, activity_date),
  ADD CONSTRAINT fk_activities_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

RENAME TABLE `fitness goals` TO fitness_goals;
ALTER TABLE fitness_goals
  MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  MODIFY user_id INT UNSIGNED NOT NULL,
  MODIFY target_weight DECIMAL(5,2) NULL,
  MODIFY created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD INDEX idx_fitness_goals_user_status (user_id, status),
  ADD CONSTRAINT fk_fitness_goals_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE progress_logs
  MODIFY user_id INT UNSIGNED NOT NULL,
  MODIFY weight_kg DECIMAL(5,2) NULL,
  MODIFY bmi DECIMAL(5,2) NULL,
  MODIFY body_fat_percentage DECIMAL(5,2) NULL,
  MODIFY muscle_mass DECIMAL(5,2) NULL,
  MODIFY waist_cm DECIMAL(5,2) NULL,
  MODIFY chest_cm DECIMAL(5,2) NULL,
  MODIFY hips_cm DECIMAL(5,2) NULL,
  MODIFY created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD UNIQUE KEY uq_progress_logs_user_date (user_id, log_date),
  ADD CONSTRAINT fk_progress_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE workouts
  MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  MODIFY user_id INT UNSIGNED NOT NULL,
  MODIFY duration_burned SMALLINT UNSIGNED NOT NULL,
  MODIFY calories_burned DECIMAL(8,2) NULL,
  MODIFY created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD INDEX idx_workouts_user_date (user_id, workout_dates),
  ADD CONSTRAINT fk_workouts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

CREATE TABLE auth_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_auth_tokens_user_expires (user_id, expires_at),
  CONSTRAINT fk_auth_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE vital_readings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  type ENUM('heart_rate','blood_pressure','blood_oxygen','temperature','weight','blood_glucose') NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  secondary_value DECIMAL(10,2) NULL,
  unit VARCHAR(20) NOT NULL,
  recorded_at DATETIME NOT NULL,
  source VARCHAR(40) NOT NULL DEFAULT 'manual',
  notes VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_vitals_user_type_recorded (user_id, type, recorded_at),
  CONSTRAINT fk_vitals_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE appointments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  provider_name VARCHAR(120) NOT NULL,
  specialty VARCHAR(100) NULL,
  scheduled_at DATETIME NOT NULL,
  location VARCHAR(255) NULL,
  mode ENUM('in_person','telemedicine') NOT NULL DEFAULT 'in_person',
  status ENUM('scheduled','completed','cancelled') NOT NULL DEFAULT 'scheduled',
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_appointments_user_scheduled (user_id, scheduled_at),
  CONSTRAINT fk_appointments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE medication_reminders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  medication_name VARCHAR(120) NOT NULL,
  dosage VARCHAR(80) NULL,
  schedule_time TIME NOT NULL,
  frequency ENUM('daily','weekly','as_needed') NOT NULL DEFAULT 'daily',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  notes VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_reminders_user_active (user_id, is_active),
  CONSTRAINT fk_reminders_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE emergency_contacts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  relationship VARCHAR(80) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_emergency_contacts_user (user_id),
  CONSTRAINT fk_emergency_contacts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE medical_records (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  record_type ENUM('lab_result','prescription','diagnosis','document') NOT NULL,
  title VARCHAR(200) NOT NULL,
  details TEXT NULL,
  issued_at DATE NULL,
  file_url VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_medical_records_user_issued (user_id, issued_at),
  CONSTRAINT fk_medical_records_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE telemedicine_sessions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  provider_name VARCHAR(120) NOT NULL,
  scheduled_at DATETIME NOT NULL,
  meeting_url VARCHAR(500) NULL,
  status ENUM('scheduled','completed','cancelled') NOT NULL DEFAULT 'scheduled',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_telemedicine_user_scheduled (user_id, scheduled_at),
  CONSTRAINT fk_telemedicine_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE community_posts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  is_anonymous TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_community_posts_created (created_at),
  CONSTRAINT fk_community_posts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ai_conversations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  title VARCHAR(160) NOT NULL DEFAULT 'Health assistant',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_ai_conversations_user_updated (user_id, updated_at),
  CONSTRAINT fk_ai_conversations_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ai_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  conversation_id BIGINT UNSIGNED NOT NULL,
  role ENUM('user','assistant') NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_ai_messages_conversation_created (conversation_id, created_at),
  CONSTRAINT fk_ai_messages_conversation FOREIGN KEY (conversation_id) REFERENCES ai_conversations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
