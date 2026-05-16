-- D-Class Persistence Database Schema
-- This file contains the SQL schema for D-class personnel persistence

-- Main D-Class players table
CREATE TABLE IF NOT EXISTS `dclass_players` (
    `ckey` VARCHAR(32) NOT NULL,
    `name` VARCHAR(64) DEFAULT 'Unknown',
    `round_count` INT DEFAULT 0,
    `total_playtime` INT DEFAULT 0,
    `total_escape_attempts` INT DEFAULT 0,
    `total_successful_escapes` INT DEFAULT 0,
    `total_contraband_found` INT DEFAULT 0,
    `total_work_completed` INT DEFAULT 0,
    `total_alliances_formed` INT DEFAULT 0,
    `total_players_betrayed` INT DEFAULT 0,
    `highest_level_achieved` INT DEFAULT 1,
    `longest_survival_time` INT DEFAULT 0,
    `most_valuable_contraband` VARCHAR(128) DEFAULT '',
    `favorite_escape_route` VARCHAR(128) DEFAULT '',
    `achievements` JSON,
    `statistics` JSON,
    `last_round_data` JSON,
    `persistence_version` INT DEFAULT 1,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ckey`),
    INDEX `idx_escapes` (`total_successful_escapes`),
    INDEX `idx_level` (`highest_level_achieved`),
    INDEX `idx_contraband` (`total_contraband_found`),
    INDEX `idx_last_updated` (`last_updated`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- D-Class achievements table
CREATE TABLE IF NOT EXISTS `dclass_achievements` (
    `id` INT AUTO_INCREMENT,
    `ckey` VARCHAR(32) NOT NULL,
    `achievement_id` VARCHAR(64) NOT NULL,
    `achievement_name` VARCHAR(128) NOT NULL,
    `achievement_description` TEXT,
    `unlock_time` INT DEFAULT 0,
    `unlocked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_achievement` (`ckey`, `achievement_id`),
    INDEX `idx_ckey` (`ckey`),
    INDEX `idx_achievement_id` (`achievement_id`),
    INDEX `idx_unlocked_at` (`unlocked_at`),
    FOREIGN KEY (`ckey`) REFERENCES `dclass_players`(`ckey`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- D-Class round statistics table
CREATE TABLE IF NOT EXISTS `dclass_round_stats` (
    `id` INT AUTO_INCREMENT,
    `ckey` VARCHAR(32) NOT NULL,
    `round_id` INT NOT NULL,
    `round_start_time` INT DEFAULT 0,
    `escape_attempts` INT DEFAULT 0,
    `successful_escapes` INT DEFAULT 0,
    `contraband_found` INT DEFAULT 0,
    `work_assignments` VARCHAR(128) DEFAULT '',
    `alliances_formed` INT DEFAULT 0,
    `players_betrayed` INT DEFAULT 0,
    `final_level` INT DEFAULT 1,
    `final_experience` INT DEFAULT 0,
    `survival_time` INT DEFAULT 0,
    `stealth_round` BOOLEAN DEFAULT FALSE,
    `escape_during_scp_event` BOOLEAN DEFAULT FALSE,
    `round_end_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_round` (`ckey`, `round_id`),
    INDEX `idx_ckey` (`ckey`),
    INDEX `idx_round_id` (`round_id`),
    INDEX `idx_round_end_time` (`round_end_time`),
    FOREIGN KEY (`ckey`) REFERENCES `dclass_players`(`ckey`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- D-Class contraband tracking table
CREATE TABLE IF NOT EXISTS `dclass_contraband_log` (
    `id` INT AUTO_INCREMENT,
    `ckey` VARCHAR(32) NOT NULL,
    `round_id` INT NOT NULL,
    `contraband_name` VARCHAR(128) NOT NULL,
    `contraband_type` VARCHAR(64) DEFAULT 'general',
    `found_time` INT DEFAULT 0,
    `used_time` INT DEFAULT 0,
    `disposed_time` INT DEFAULT 0,
    `value` INT DEFAULT 0,
    `location_found` VARCHAR(128) DEFAULT '',
    `recorded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_ckey` (`ckey`),
    INDEX `idx_round_id` (`round_id`),
    INDEX `idx_contraband_type` (`contraband_type`),
    INDEX `idx_found_time` (`found_time`),
    FOREIGN KEY (`ckey`) REFERENCES `dclass_players`(`ckey`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- D-Class social interactions table
CREATE TABLE IF NOT EXISTS `dclass_social_log` (
    `id` INT AUTO_INCREMENT,
    `ckey` VARCHAR(32) NOT NULL,
    `round_id` INT NOT NULL,
    `interaction_type` ENUM('alliance_formed', 'alliance_broken', 'trade_made', 'player_betrayed', 'player_reported') NOT NULL,
    `target_ckey` VARCHAR(32) DEFAULT NULL,
    `target_name` VARCHAR(64) DEFAULT '',
    `interaction_details` JSON,
    `interaction_time` INT DEFAULT 0,
    `recorded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_ckey` (`ckey`),
    INDEX `idx_round_id` (`round_id`),
    INDEX `idx_interaction_type` (`interaction_type`),
    INDEX `idx_target_ckey` (`target_ckey`),
    INDEX `idx_interaction_time` (`interaction_time`),
    FOREIGN KEY (`ckey`) REFERENCES `dclass_players`(`ckey`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- D-Class escape attempts table
CREATE TABLE IF NOT EXISTS `dclass_escape_log` (
    `id` INT AUTO_INCREMENT,
    `ckey` VARCHAR(32) NOT NULL,
    `round_id` INT NOT NULL,
    `escape_route` VARCHAR(128) NOT NULL,
    `attempt_time` INT DEFAULT 0,
    `success` BOOLEAN DEFAULT FALSE,
    `time_taken` INT DEFAULT 0,
    `contraband_used` JSON,
    `allies_involved` JSON,
    `guard_detections` INT DEFAULT 0,
    `escape_details` JSON,
    `recorded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_ckey` (`ckey`),
    INDEX `idx_round_id` (`round_id`),
    INDEX `idx_escape_route` (`escape_route`),
    INDEX `idx_success` (`success`),
    INDEX `idx_attempt_time` (`attempt_time`),
    FOREIGN KEY (`ckey`) REFERENCES `dclass_players`(`ckey`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- D-Class work assignments table
CREATE TABLE IF NOT EXISTS `dclass_work_log` (
    `id` INT AUTO_INCREMENT,
    `ckey` VARCHAR(32) NOT NULL,
    `round_id` INT NOT NULL,
    `work_assignment` VARCHAR(128) NOT NULL,
    `assignment_start_time` INT DEFAULT 0,
    `assignment_end_time` INT DEFAULT 0,
    `work_completed` BOOLEAN DEFAULT FALSE,
    `risk_level` INT DEFAULT 1,
    `reward_xp` INT DEFAULT 0,
    `tools_accessed` JSON,
    `areas_accessed` JSON,
    `work_details` JSON,
    `recorded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_ckey` (`ckey`),
    INDEX `idx_round_id` (`round_id`),
    INDEX `idx_work_assignment` (`work_assignment`),
    INDEX `idx_work_completed` (`work_completed`),
    INDEX `idx_risk_level` (`risk_level`),
    FOREIGN KEY (`ckey`) REFERENCES `dclass_players`(`ckey`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- D-Class SCP integration table
CREATE TABLE IF NOT EXISTS `dclass_scp_log` (
    `id` INT AUTO_INCREMENT,
    `ckey` VARCHAR(32) NOT NULL,
    `round_id` INT NOT NULL,
    `scp_interaction_type` ENUM('study_scp', 'use_distraction', 'steal_materials', 'escape_during_breach') NOT NULL,
    `scp_name` VARCHAR(128) NOT NULL,
    `interaction_time` INT DEFAULT 0,
    `success` BOOLEAN DEFAULT FALSE,
    `materials_obtained` JSON,
    `experience_gained` INT DEFAULT 0,
    `interaction_details` JSON,
    `recorded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_ckey` (`ckey`),
    INDEX `idx_round_id` (`round_id`),
    INDEX `idx_scp_interaction_type` (`scp_interaction_type`),
    INDEX `idx_scp_name` (`scp_name`),
    INDEX `idx_success` (`success`),
    FOREIGN KEY (`ckey`) REFERENCES `dclass_players`(`ckey`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data for testing (optional)
-- INSERT INTO `dclass_players` (`ckey`, `name`, `round_count`) VALUES ('testplayer', 'Test Player', 1);

-- Create views for common queries
CREATE OR REPLACE VIEW `dclass_leaderboard` AS
SELECT 
    p.ckey,
    p.name,
    p.total_successful_escapes,
    p.highest_level_achieved,
    p.total_contraband_found,
    COUNT(a.achievement_id) as achievements_count,
    p.last_updated
FROM `dclass_players` p
LEFT JOIN `dclass_achievements` a ON p.ckey = a.ckey
GROUP BY p.ckey, p.name, p.total_successful_escapes, p.highest_level_achieved, p.total_contraband_found, p.last_updated
ORDER BY p.total_successful_escapes DESC, p.highest_level_achieved DESC;

CREATE OR REPLACE VIEW `dclass_recent_activity` AS
SELECT 
    p.ckey,
    p.name,
    rs.round_id,
    rs.survival_time,
    rs.successful_escapes,
    rs.contraband_found,
    rs.final_level,
    rs.round_end_time
FROM `dclass_players` p
JOIN `dclass_round_stats` rs ON p.ckey = rs.ckey
ORDER BY rs.round_end_time DESC
LIMIT 100;
