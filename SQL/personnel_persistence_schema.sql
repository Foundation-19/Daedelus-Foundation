-- Personnel Persistence Database Schema
-- This file contains the SQL schema for personnel persistence system

-- Main personnel records table
CREATE TABLE IF NOT EXISTS `personnel_records` (
    `ckey` VARCHAR(32) NOT NULL,
    `real_name` VARCHAR(64) DEFAULT 'Unknown',
    `employee_id` VARCHAR(16) DEFAULT '',
    `department` VARCHAR(32) DEFAULT 'General',
    `position` VARCHAR(64) DEFAULT 'Staff',
    `hire_date` VARCHAR(32) DEFAULT '',
    `clearance_level` INT DEFAULT 1,
    `performance_rating` INT DEFAULT 75,
    `salary` INT DEFAULT 50000,
    `status` VARCHAR(16) DEFAULT 'ACTIVE',
    `skills` JSON,
    `certifications` JSON,
    `emergency_contact` VARCHAR(128) DEFAULT '',
    `last_updated` VARCHAR(32) DEFAULT '',
    PRIMARY KEY (`ckey`)
);

-- Personnel assignments table
CREATE TABLE IF NOT EXISTS `personnel_assignments` (
    `assignment_id` VARCHAR(32) NOT NULL,
    `employee_ckey` VARCHAR(32) NOT NULL,
    `assignment_type` VARCHAR(32) DEFAULT 'GENERAL',
    `assignment_description` TEXT,
    `start_date` VARCHAR(32) DEFAULT '',
    `end_date` VARCHAR(32) DEFAULT '',
    `status` VARCHAR(16) DEFAULT 'ACTIVE',
    `priority` INT DEFAULT 1,
    `completion_rating` INT DEFAULT 0,
    `supervisor_ckey` VARCHAR(32) DEFAULT '',
    `notes` TEXT,
    PRIMARY KEY (`assignment_id`),
    INDEX `idx_employee_ckey` (`employee_ckey`),
    INDEX `idx_status` (`status`)
);

-- Personnel performance reviews table
CREATE TABLE IF NOT EXISTS `personnel_performance_reviews` (
    `review_id` VARCHAR(32) NOT NULL,
    `employee_ckey` VARCHAR(32) NOT NULL,
    `reviewer_ckey` VARCHAR(32) NOT NULL,
    `review_date` VARCHAR(32) DEFAULT '',
    `performance_rating` INT DEFAULT 75,
    `strengths` TEXT,
    `weaknesses` TEXT,
    `goals` TEXT,
    `overall_assessment` TEXT,
    `next_review_date` VARCHAR(32) DEFAULT '',
    PRIMARY KEY (`review_id`),
    INDEX `idx_employee_ckey` (`employee_ckey`),
    INDEX `idx_reviewer_ckey` (`reviewer_ckey`)
);

-- Personnel training records table
CREATE TABLE IF NOT EXISTS `personnel_training_records` (
    `training_id` VARCHAR(32) NOT NULL,
    `employee_ckey` VARCHAR(32) NOT NULL,
    `training_type` VARCHAR(32) DEFAULT 'GENERAL',
    `training_name` VARCHAR(128) DEFAULT '',
    `training_date` VARCHAR(32) DEFAULT '',
    `completion_date` VARCHAR(32) DEFAULT '',
    `status` VARCHAR(16) DEFAULT 'PENDING',
    `score` INT DEFAULT 0,
    `certification_expiry` VARCHAR(32) DEFAULT '',
    `trainer_ckey` VARCHAR(32) DEFAULT '',
    `notes` TEXT,
    PRIMARY KEY (`training_id`),
    INDEX `idx_employee_ckey` (`employee_ckey`),
    INDEX `idx_status` (`status`)
);

-- Personnel promotions table
CREATE TABLE IF NOT EXISTS `personnel_promotions` (
    `promotion_id` VARCHAR(32) NOT NULL,
    `employee_ckey` VARCHAR(32) NOT NULL,
    `old_position` VARCHAR(64) DEFAULT '',
    `new_position` VARCHAR(64) DEFAULT '',
    `promotion_date` VARCHAR(32) DEFAULT '',
    `reason` TEXT,
    `approver_ckey` VARCHAR(32) DEFAULT '',
    `salary_increase` INT DEFAULT 0,
    `clearance_increase` INT DEFAULT 0,
    PRIMARY KEY (`promotion_id`),
    INDEX `idx_employee_ckey` (`employee_ckey`)
);

-- Personnel departments table
CREATE TABLE IF NOT EXISTS `personnel_departments` (
    `dept_id` VARCHAR(32) NOT NULL,
    `dept_name` VARCHAR(64) NOT NULL,
    `dept_head` VARCHAR(32) DEFAULT '',
    `budget` INT DEFAULT 1000000,
    `description` TEXT,
    `created_date` VARCHAR(32) DEFAULT '',
    PRIMARY KEY (`dept_id`),
    UNIQUE KEY `uk_dept_name` (`dept_name`)
);

-- Personnel training programs table
CREATE TABLE IF NOT EXISTS `personnel_training_programs` (
    `program_id` VARCHAR(32) NOT NULL,
    `program_name` VARCHAR(128) NOT NULL,
    `instructor` VARCHAR(32) DEFAULT '',
    `duration` INT DEFAULT 2,
    `description` TEXT,
    `requirements` TEXT,
    `created_date` VARCHAR(32) DEFAULT '',
    PRIMARY KEY (`program_id`),
    UNIQUE KEY `uk_program_name` (`program_name`)
);

-- Personnel statistics table (for global stats)
CREATE TABLE IF NOT EXISTS `personnel_statistics` (
    `stat_id` VARCHAR(32) NOT NULL,
    `stat_name` VARCHAR(64) NOT NULL,
    `stat_value` FLOAT DEFAULT 0.0,
    `stat_date` VARCHAR(32) DEFAULT '',
    `notes` TEXT,
    PRIMARY KEY (`stat_id`),
    INDEX `idx_stat_name` (`stat_name`)
);

-- Insert default departments
INSERT IGNORE INTO `personnel_departments` (`dept_id`, `dept_name`, `dept_head`, `budget`, `description`, `created_date`) VALUES
('DEPT_SECURITY', 'Security', '', 1500000, 'Site security and containment procedures', ''),
('DEPT_RESEARCH', 'Research', '', 2000000, 'SCP research and analysis', ''),
('DEPT_MEDICAL', 'Medical', '', 1200000, 'Medical care and health monitoring', ''),
('DEPT_ENGINEERING', 'Engineering', '', 1800000, 'Site maintenance and technical support', ''),
('DEPT_ADMIN', 'Administration', '', 1000000, 'Site administration and management', ''),
('DEPT_DCLASS', 'D-Class', '', 500000, 'D-Class personnel management', '');

-- Insert default training programs
INSERT IGNORE INTO `personnel_training_programs` (`program_id`, `program_name`, `instructor`, `duration`, `description`, `requirements`, `created_date`) VALUES
('TRAIN_BASIC_SECURITY', 'Basic Security Training', '', 1, 'Basic security protocols and procedures', 'None', ''),
('TRAIN_SCP_AWARENESS', 'SCP Awareness Training', '', 2, 'Basic SCP containment and safety procedures', 'None', ''),
('TRAIN_MEDICAL_BASIC', 'Basic Medical Training', '', 3, 'Basic medical procedures and first aid', 'None', ''),
('TRAIN_ENGINEERING_BASIC', 'Basic Engineering Training', '', 2, 'Basic engineering and maintenance procedures', 'None', ''),
('TRAIN_ADVANCED_SECURITY', 'Advanced Security Training', '', 4, 'Advanced security and containment procedures', 'Basic Security Training', ''),
('TRAIN_RESEARCH_METHODS', 'Research Methods Training', '', 3, 'Scientific research methods and documentation', 'None', '');
