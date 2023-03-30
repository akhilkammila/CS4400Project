-- CS4400: Introduction to Database Systems: Monday, January 30, 2023
-- Flight Management Course Project Database TEMPLATE (v1.0)

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_management';

drop database if exists flight_management;
create database if not exists flight_management;
use flight_management;

-- Define the database structures and enter the denormalized data

DROP TABLE IF EXISTS airline;
CREATE TABLE airline (
  airlineID char(50) NOT NULL,
  revenue decimal(9, 0) NOT NULL,
  
  PRIMARY KEY (airlineID)
  
) ENGINE=InnoDB;


DROP TABLE IF EXISTS location;
CREATE TABLE location (

  locationID char(50) NOT NULL,
  PRIMARY KEY (locationID)
  
) ENGINE=InnoDB;

DROP TABLE IF EXISTS airplane;
CREATE TABLE airplane (
  airlineID char(50) NOT NULL,
  tail_num char(50) NOT NULL,
  seat_capacity decimal(1, 0) NOT NULL,
  speed decimal(4, 0) NOT NULL,
  locationID char(100) DEFAULT NULL,
  plane_type char(50) DEFAULT NULL,
  skids decimal(1, 0) DEFAULT NULL,
  props_or_jets decimal(1, 0) DEFAULT NULL,
  
  
  PRIMARY KEY (airlineID, tail_num),
  CONSTRAINT airplane_ibfk_1 FOREIGN KEY (airlineID) REFERENCES airline (airlineID),
  CONSTRAINT airplane_ibfk_2 FOREIGN KEY (locationID) REFERENCES location (locationID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
  airportID char(50) NOT NULL,
  airport_name char(100) NOT NULL,
  city char(100) NOT NULL,
  state char(100) NOT NULL,
  locationID char(50) DEFAULT NULL,
  
  PRIMARY KEY (airportID),
  UNIQUE KEY (airport_name),
  CONSTRAINT airport_ibfk_1 FOREIGN KEY (locationID) REFERENCES location (locationID)
  
) ENGINE=InnoDB;

DROP TABLE IF EXISTS person;
CREATE TABLE person (
  personID char(50) NOT NULL,
  first_name char(100) NOT NULL,
  last_name char(100) NOT NULL,
  locationID char(50) NOT NULL,
  taxID char(100) DEFAULT NULL,
  experience decimal(3, 0) DEFAULT NULL,
  flying_airline char(50) DEFAULT NULL,
  flying_tail char(50) DEFAULT NULL,
  miles decimal(6, 0) DEFAULT NULL,
  
  license_1 char(100) DEFAULT NULL,
  license_2 char(100) DEFAULT NULL,
  license_3 char(100) DEFAULT NULL,
  
  PRIMARY KEY (personID),
  CONSTRAINT person_ibfk_1 FOREIGN KEY (locationID) REFERENCES location (locationID),
  CONSTRAINT person_ibfk_2 FOREIGN KEY (flying_airline) REFERENCES airplane (airlineID),
  CONSTRAINT person_ibfk_3 FOREIGN KEY (flying_tail) REFERENCES airplane (tail_num)

) ENGINE=InnoDB;