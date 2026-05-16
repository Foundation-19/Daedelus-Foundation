-- Research Persistence Database Schema
-- This file contains the SQL schema for research persistence system

-- Research projects table
CREATE TABLE IF NOT EXISTS `research_projects` (
    `project_id` VARCHAR(32) NOT NULL,
    `project_name` VARCHAR(128) NOT NULL,
    `project_description` TEXT,
    `research_field` VARCHAR(64) DEFAULT 'GENERAL',
    `lead_researcher` VARCHAR(32) DEFAULT '',
    `researchers` JSON,
    `progress` INT DEFAULT 0,
    `budget_allocated` INT DEFAULT 0,
    `budget_used` INT DEFAULT 0,
    `start_date` VARCHAR(32) DEFAULT '',
    `estimated_completion` VARCHAR(32) DEFAULT '',
    `actual_completion` VARCHAR(32) DEFAULT '',
    `status` VARCHAR(16) DEFAULT 'ACTIVE',
    `priority` INT DEFAULT 1,
    `discoveries` JSON,
    `publications` JSON,
    `research_notes` JSON,
    PRIMARY KEY (`project_id`),
    UNIQUE KEY `uk_project_name` (`project_name`)
);

-- Research scientific discoveries table
CREATE TABLE IF NOT EXISTS `research_scientific_discoveries` (
    `discovery_id` VARCHAR(32) NOT NULL,
    `discovery_name` VARCHAR(128) NOT NULL,
    `discovery_description` TEXT,
    `discovery_type` VARCHAR(32) DEFAULT 'GENERAL',
    `research_field` VARCHAR(64) DEFAULT 'GENERAL',
    `discoverer_ckey` VARCHAR(32) DEFAULT '',
    `discovery_date` VARCHAR(32) DEFAULT '',
    `significance_level` INT DEFAULT 1,
    `related_projects` JSON,
    `applications` JSON,
    `patent_status` VARCHAR(16) DEFAULT 'PENDING',
    `commercial_value` INT DEFAULT 0,
    PRIMARY KEY (`discovery_id`),
    UNIQUE KEY `uk_discovery_name` (`discovery_name`)
);

-- Research publications table
CREATE TABLE IF NOT EXISTS `research_publications` (
    `publication_id` VARCHAR(32) NOT NULL,
    `publication_title` VARCHAR(256) NOT NULL,
    `publication_abstract` TEXT,
    `authors` JSON,
    `journal_name` VARCHAR(128) DEFAULT '',
    `publication_date` VARCHAR(32) DEFAULT '',
    `impact_factor` FLOAT DEFAULT 0.0,
    `citation_count` INT DEFAULT 0,
    `peer_review_status` VARCHAR(16) DEFAULT 'PENDING',
    `doi_number` VARCHAR(64) DEFAULT '',
    PRIMARY KEY (`publication_id`),
    UNIQUE KEY `uk_publication_title` (`publication_title`)
);

-- Research facilities table
CREATE TABLE IF NOT EXISTS `research_facilities` (
    `facility_id` VARCHAR(32) NOT NULL,
    `facility_name` VARCHAR(128) NOT NULL,
    `facility_type` VARCHAR(32) DEFAULT 'GENERAL',
    `location` VARCHAR(128) DEFAULT '',
    `capacity` INT DEFAULT 0,
    `current_occupancy` INT DEFAULT 0,
    `equipment_quality` INT DEFAULT 50,
    `maintenance_level` INT DEFAULT 100,
    `active_projects` JSON,
    `equipment` JSON,
    `security_level` INT DEFAULT 1,
    PRIMARY KEY (`facility_id`),
    UNIQUE KEY `uk_facility_name` (`facility_name`)
);

-- Research grants table
CREATE TABLE IF NOT EXISTS `research_grants` (
    `grant_id` VARCHAR(32) NOT NULL,
    `grant_name` VARCHAR(128) NOT NULL,
    `granting_organization` VARCHAR(128) DEFAULT '',
    `amount` INT DEFAULT 0,
    `research_field` VARCHAR(64) DEFAULT 'GENERAL',
    `recipient_ckey` VARCHAR(32) DEFAULT '',
    `grant_date` VARCHAR(32) DEFAULT '',
    `expiration_date` VARCHAR(32) DEFAULT '',
    `status` VARCHAR(16) DEFAULT 'ACTIVE',
    `requirements` JSON,
    `progress_reports` JSON,
    PRIMARY KEY (`grant_id`),
    UNIQUE KEY `uk_grant_name` (`grant_name`)
);

-- Research statistics table
CREATE TABLE IF NOT EXISTS `research_statistics` (
    `stat_id` VARCHAR(32) NOT NULL,
    `stat_name` VARCHAR(64) NOT NULL,
    `stat_value` FLOAT DEFAULT 0.0,
    `stat_date` VARCHAR(32) DEFAULT '',
    `notes` TEXT,
    PRIMARY KEY (`stat_id`),
    INDEX `idx_stat_name` (`stat_name`)
);

-- Insert default research statistics
INSERT IGNORE INTO `research_statistics` (`stat_id`, `stat_name`, `stat_value`, `stat_date`, `notes`) VALUES
('RES_STAT_TOTAL_PROJECTS', 'Total Research Projects', 0.0, '', 'Total number of research projects'),
('RES_STAT_COMPLETED_PROJECTS', 'Completed Research Projects', 0.0, '', 'Number of completed research projects'),
('RES_STAT_RESEARCH_BUDGET', 'Research Budget', 2000000.0, '', 'Current research department budget'),
('RES_STAT_RESEARCH_EFFICIENCY', 'Research Efficiency', 1.0, '', 'Overall research efficiency rating'),
('RES_STAT_SCIENTIFIC_BREAKTHROUGHS', 'Scientific Breakthroughs', 0.0, '', 'Number of scientific breakthroughs'),
('RES_STAT_PUBLICATION_COUNT', 'Publication Count', 0.0, '', 'Total number of publications'),
('RES_STAT_RESEARCH_STAFF', 'Research Staff Count', 0.0, '', 'Number of active research staff');
