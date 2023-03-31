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
  locationID char(50) DEFAULT NULL,
  plane_type char(100) DEFAULT NULL,
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
  CONSTRAINT person_ibfk_2 FOREIGN KEY (flying_airline, flying_tail) REFERENCES airplane (airlineID, tail_num)
  -- CONSTRAINT person_ibfk_3 FOREIGN KEY (flying_tail) REFERENCES airplane (tail_num)

) ENGINE=InnoDB;
DROP TABLE IF EXISTS tickets;
CREATE TABLE tickets (
	ticektID varchar(50) NOT NULL,
    cost int NOT NULL,
    carrier varchar(50) NOT NULL,
    customer varchar(50) NOT NULL,
    deplane_at varchar(50) NOT NULL,
    PRIMARY KEY (ticketID),
    CONSTRAINT tickets_ibfk_1 FOREIGN KEY (carrier) REFERENCES flights (flightID),
    CONSTRAINT tickets_ibfk_2 FOREIGN KEY (customer) REFERENCES persons (personID),
    CONSTRAINT tickets_ibfk_3 FOREIGN KEY (deplane_at) REFERENCES airports(airportID)
);

DROP TABLE IF EXISTS flights;
CREATE TABLE flights(
	flightID varchar(50) NOT NULL,
    routeID varchar(50) NOT NULL,
    support_airline varchar(50),
    support_tail varchar(50),
    progress int,
    airplane_status varchar(100),
    next_time time,
    PRIMARY KEY(flightID),
    CONSTRAINT flights_ibfk_1 FOREIGN KEY (routeID) REFERENCES routes (routeID),
    CONSTRAINT flights_ibfk_2 FOREIGN KEY (support_airline, support_tail) REFERENCES airplanes (airlineID, tail_num)
);
DROP TABLE IF EXISTS seats;
CREATE TABLE seats (
	ticektID varchar(50) NOT NULL,
    seat varchar(100) NOT NULL,
    PRIMARY KEY (ticketID, seat),
    CONSTRAINT seats_ibfk_1 FOREIGN KEY (ticketID) REFERENCES tickets (ticketID)
);
DROP TABLE IF EXISTS legs;
CREATE TABLE legs (
	legID varchar(50) NOT NULL,
    distance int NOT NULL,
    departure varchar(50),
    arrival varchar(50),
    PRIMARY KEY (legID),
    CONSTRAINT legs_ibfk_1 FOREIGN KEY (departure) REFERENCES airports (airportID),
    CONSTRAINT legs_ibfk_2 FOREIGN KEY (arrival) REFERENCES airports (airportID)
);
DROP TABLE IF EXISTS routes;
CREATE TABLE routes (
	routeID varchar(50) NOT NULL,
    PRIMARY KEY (route_id)
);
DROP TABLE IF EXISTS route_legs;
CREATE TABLE route_legs (
	routeID varchar(50) NOT NULL,
    legID varchar(50) NOT NULL,
    sequence varchar(50) NOT NULL,
    PRIMARY KEY(routeID, legID),
    CONSTRAINT route_legs_ibfk_1 FOREIGN KEY (routeID) REFERENCES routes (routeID),
    CONSTRAINT route_legs_ibfk_2 FOREIGN KEY (legID) REFERENCES legs (legID)
);