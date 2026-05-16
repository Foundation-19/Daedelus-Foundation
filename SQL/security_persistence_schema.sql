-- Security Persistence Database Schema
-- This file contains the SQL schema for security persistence system

-- Security records table
CREATE TABLE IF NOT EXISTS `security_records` (
    `ckey` VARCHAR(32) NOT NULL,
    `real_name` VARCHAR(64) DEFAULT 'Unknown',
    `security_clearance` INT DEFAULT 1,
    `security_rating` INT DEFAULT 100,
    `security_status` VARCHAR(16) DEFAULT 'ACTIVE',
    `clearance_history` JSON,
    `disciplinary_actions` JSON,
    `last_updated` VARCHAR(32) DEFAULT '',
    PRIMARY KEY (`ckey`)
);

-- Security incidents table
CREATE TABLE IF NOT EXISTS `security_incidents` (
    `incident_id` VARCHAR(32) NOT NULL,
    `incident_type` VARCHAR(32) DEFAULT 'GENERAL',
    `incident_description` TEXT,
    `severity` INT DEFAULT 1,
    `location` VARCHAR(128) DEFAULT '',
    `involved_personnel` JSON,
    `witnesses` JSON,
    `timestamp` VARCHAR(32) DEFAULT '',
    `resolved` BOOLEAN DEFAULT FALSE,
    `resolution_notes` TEXT,
    `security_rating_impact` INT DEFAULT 0,
    PRIMARY KEY (`incident_id`),
    INDEX `idx_incident_type` (`incident_type`),
    INDEX `idx_resolved` (`resolved`)
);

-- Security clearance requests table
CREATE TABLE IF NOT EXISTS `security_clearance_requests` (
    `request_id` VARCHAR(32) NOT NULL,
    `applicant_ckey` VARCHAR(32) NOT NULL,
    `requested_clearance` INT DEFAULT 1,
    `reason` TEXT,
    `approver_ckey` VARCHAR(32) DEFAULT '',
    `status` VARCHAR(16) DEFAULT 'PENDING',
    `timestamp` VARCHAR(32) DEFAULT '',
    `approval_notes` TEXT,
    PRIMARY KEY (`request_id`),
    INDEX `idx_applicant_ckey` (`applicant_ckey`),
    INDEX `idx_status` (`status`)
);

-- Security protocols table
CREATE TABLE IF NOT EXISTS `security_protocols` (
    `protocol_id` VARCHAR(32) NOT NULL,
    `protocol_name` VARCHAR(128) NOT NULL,
    `protocol_description` TEXT,
    `clearance_required` INT DEFAULT 1,
    `activation_conditions` JSON,
    `protocol_steps` JSON,
    `status` VARCHAR(16) DEFAULT 'ACTIVE',
    `effectiveness_rating` INT DEFAULT 100,
    `last_updated` VARCHAR(32) DEFAULT '',
    PRIMARY KEY (`protocol_id`),
    UNIQUE KEY `uk_protocol_name` (`protocol_name`)
);

-- Security access logs table
CREATE TABLE IF NOT EXISTS `security_access_logs` (
    `log_id` VARCHAR(32) NOT NULL,
    `ckey` VARCHAR(32) NOT NULL,
    `access_point` VARCHAR(128) DEFAULT '',
    `access_granted` BOOLEAN DEFAULT FALSE,
    `timestamp` VARCHAR(32) DEFAULT '',
    `clearance_level` INT DEFAULT 1,
    `reason` TEXT,
    PRIMARY KEY (`log_id`),
    INDEX `idx_ckey` (`ckey`),
    INDEX `idx_access_point` (`access_point`),
    INDEX `idx_timestamp` (`timestamp`)
);

-- Security statistics table
CREATE TABLE IF NOT EXISTS `security_statistics` (
    `stat_id` VARCHAR(32) NOT NULL,
    `stat_name` VARCHAR(64) NOT NULL,
    `stat_value` FLOAT DEFAULT 0.0,
    `stat_date` VARCHAR(32) DEFAULT '',
    `notes` TEXT,
    PRIMARY KEY (`stat_id`),
    INDEX `idx_stat_name` (`stat_name`)
);

-- Insert default security protocols
INSERT IGNORE INTO `security_protocols` (`protocol_id`, `protocol_name`, `protocol_description`, `clearance_required`, `activation_conditions`, `protocol_steps`, `status`, `effectiveness_rating`, `last_updated`) VALUES
('PROTOCOL_BREACH_CONTAINMENT', 'Containment Breach Protocol', 'Standard procedures for containing SCP breaches', 3, '["breach_detected", "scp_escaped"]', '["activate_alarms", "seal_sectors", "deploy_containment_teams"]', 'ACTIVE', 95, ''),
('PROTOCOL_LOCKDOWN', 'Site Lockdown Protocol', 'Emergency lockdown procedures for site security', 2, '["security_threat", "unauthorized_access"]', '["seal_entrances", "restrict_movement", "activate_defenses"]', 'ACTIVE', 90, ''),
('PROTOCOL_QUARANTINE', 'Quarantine Protocol', 'Medical quarantine procedures for biological threats', 2, '["biological_threat", "disease_outbreak"]', '["isolate_affected", "decontaminate_areas", "medical_response"]', 'ACTIVE', 85, ''),
('PROTOCOL_EMERGENCY_EVACUATION', 'Emergency Evacuation Protocol', 'Site evacuation procedures for major incidents', 1, '["major_incident", "site_compromise"]', '["sound_alarms", "direct_evacuation", "secure_exits"]', 'ACTIVE', 88, ''),
('PROTOCOL_INFORMATION_SECURITY', 'Information Security Protocol', 'Procedures for protecting classified information', 4, '["information_breach", "unauthorized_access"]', '["restrict_access", "audit_systems", "contain_information"]', 'ACTIVE', 92, '');
