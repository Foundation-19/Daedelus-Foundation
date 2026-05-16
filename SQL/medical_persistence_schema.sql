-- Medical Persistence Database Schema
-- This file contains the SQL schema for medical persistence system

-- Medical records table
CREATE TABLE IF NOT EXISTS `medical_records` (
    `ckey` VARCHAR(32) NOT NULL,
    `real_name` VARCHAR(64) DEFAULT 'Unknown',
    `blood_type` VARCHAR(8) DEFAULT 'O+',
    `dna_hash` VARCHAR(64) DEFAULT '',
    `medical_history` JSON,
    `allergies` JSON,
    `current_conditions` JSON,
    `health_rating` INT DEFAULT 100,
    `last_updated` VARCHAR(32) DEFAULT '',
    PRIMARY KEY (`ckey`)
);

-- Medical treatment logs table
CREATE TABLE IF NOT EXISTS `medical_treatment_logs` (
    `treatment_id` VARCHAR(32) NOT NULL,
    `patient_ckey` VARCHAR(32) NOT NULL,
    `treatment_type` VARCHAR(32) DEFAULT 'GENERAL',
    `treatment_description` TEXT,
    `doctor_ckey` VARCHAR(32) DEFAULT '',
    `timestamp` VARCHAR(32) DEFAULT '',
    `success` BOOLEAN DEFAULT TRUE,
    `notes` TEXT,
    PRIMARY KEY (`treatment_id`),
    INDEX `idx_patient_ckey` (`patient_ckey`),
    INDEX `idx_doctor_ckey` (`doctor_ckey`)
);

-- Medical outbreak records table
CREATE TABLE IF NOT EXISTS `medical_outbreak_records` (
    `outbreak_id` VARCHAR(32) NOT NULL,
    `disease_name` VARCHAR(128) DEFAULT '',
    `disease_type` VARCHAR(32) DEFAULT 'VIRAL',
    `severity` INT DEFAULT 1,
    `affected_count` INT DEFAULT 0,
    `contained_count` INT DEFAULT 0,
    `start_time` VARCHAR(32) DEFAULT '',
    `end_time` VARCHAR(32) DEFAULT '',
    `status` VARCHAR(16) DEFAULT 'ACTIVE',
    `affected_patients` JSON,
    `containment_protocols` JSON,
    PRIMARY KEY (`outbreak_id`),
    INDEX `idx_disease_type` (`disease_type`),
    INDEX `idx_status` (`status`)
);

-- Medical research projects table
CREATE TABLE IF NOT EXISTS `medical_research_projects` (
    `project_id` VARCHAR(32) NOT NULL,
    `project_name` VARCHAR(128) NOT NULL,
    `project_description` TEXT,
    `research_field` VARCHAR(64) DEFAULT 'GENERAL',
    `progress` INT DEFAULT 0,
    `budget_allocated` INT DEFAULT 0,
    `budget_used` INT DEFAULT 0,
    `lead_researcher` VARCHAR(32) DEFAULT '',
    `researchers` JSON,
    `start_date` VARCHAR(32) DEFAULT '',
    `estimated_completion` VARCHAR(32) DEFAULT '',
    `status` VARCHAR(16) DEFAULT 'ACTIVE',
    `discoveries` JSON,
    `publications` JSON,
    PRIMARY KEY (`project_id`),
    UNIQUE KEY `uk_project_name` (`project_name`)
);

-- Medical statistics table
CREATE TABLE IF NOT EXISTS `medical_statistics` (
    `stat_id` VARCHAR(32) NOT NULL,
    `stat_name` VARCHAR(64) NOT NULL,
    `stat_value` FLOAT DEFAULT 0.0,
    `stat_date` VARCHAR(32) DEFAULT '',
    `notes` TEXT,
    PRIMARY KEY (`stat_id`),
    INDEX `idx_stat_name` (`stat_name`)
);

-- Insert default medical research fields
INSERT IGNORE INTO `medical_statistics` (`stat_id`, `stat_name`, `stat_value`, `stat_date`, `notes`) VALUES
('MED_STAT_TOTAL_PATIENTS', 'Total Patients Treated', 0.0, '', 'Total number of patients treated'),
('MED_STAT_ACTIVE_OUTBREAKS', 'Active Outbreaks', 0.0, '', 'Number of currently active disease outbreaks'),
('MED_STAT_RESEARCH_PROGRESS', 'Medical Research Progress', 0.0, '', 'Overall progress of medical research projects'),
('MED_STAT_CONTAINMENT_EFFECTIVENESS', 'Containment Effectiveness', 1.0, '', 'Effectiveness of disease containment protocols'),
('MED_STAT_MEDICAL_BUDGET', 'Medical Budget', 1000000.0, '', 'Current medical department budget'),
('MED_STAT_MEDICAL_STAFF', 'Medical Staff Count', 0.0, '', 'Number of active medical staff');
