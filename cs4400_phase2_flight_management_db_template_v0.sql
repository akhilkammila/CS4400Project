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
  last_name char(100) DEFAULT NULL,
  locationID char(50) NOT NULL,
  taxID char(100) DEFAULT NULL,
  experience decimal(3, 0) DEFAULT NULL,
  flying_airline char(50) DEFAULT NULL,
  flying_tail char(50) DEFAULT NULL,
  miles decimal(6, 0) DEFAULT NULL,
  isPilot boolean NOT NULL,
  isPassenger boolean NOT NULL,
  
  PRIMARY KEY (personID),
  UNIQUE KEY (taxID),
  CONSTRAINT person_ibfk_1 FOREIGN KEY (locationID) REFERENCES location (locationID),
  CONSTRAINT person_ibfk_2 FOREIGN KEY (flying_airline, flying_tail) REFERENCES airplane (airlineID, tail_num)
  -- CONSTRAINT person_ibfk_3 FOREIGN KEY (flying_tail) REFERENCES airplane (tail_num)

) ENGINE=InnoDB;

DROP TABLE IF EXISTS license;
CREATE TABLE licence (
	personID char(50) NOT NULL,
    licence char(100) NOT NULL,
    PRIMARY KEY (personID, licence),
    CONSTRAINT license_ibfk_1 FOREIGN KEY (personID) REFERENCES person (personID)
);

DROP TABLE IF EXISTS route;
CREATE TABLE route (
	routeID varchar(50) NOT NULL,
    PRIMARY KEY (routeID)
);

DROP TABLE IF EXISTS leg;
CREATE TABLE leg (
	legID varchar(50) NOT NULL,
    distance int NOT NULL,
    departure varchar(50),
    arrival varchar(50),
    PRIMARY KEY (legID),
    CONSTRAINT legs_ibfk_1 FOREIGN KEY (departure) REFERENCES airport (airportID),
    CONSTRAINT legs_ibfk_2 FOREIGN KEY (arrival) REFERENCES airport (airportID)
);

DROP TABLE IF EXISTS route_leg;
CREATE TABLE route_leg (
	routeID varchar(50) NOT NULL,
    legID varchar(50) NOT NULL,
    sequence int NOT NULL,
    PRIMARY KEY(routeID, legID, sequence),
    CONSTRAINT route_legs_ibfk_1 FOREIGN KEY (routeID) REFERENCES route (routeID),
    CONSTRAINT route_legs_ibfk_2 FOREIGN KEY (legID) REFERENCES leg (legID)
);

DROP TABLE IF EXISTS flight;
CREATE TABLE flight(
	flightID varchar(50) NOT NULL,
    routeID varchar(50) NOT NULL,
    support_airline varchar(50),
    support_tail varchar(50),
    progress int,
    airplane_status varchar(100),
    next_time time,
    PRIMARY KEY(flightID),
    CONSTRAINT flights_ibfk_1 FOREIGN KEY (routeID) REFERENCES route (routeID),
    CONSTRAINT flights_ibfk_2 FOREIGN KEY (support_airline, support_tail) REFERENCES airplane (airlineID, tail_num)
);
DROP TABLE IF EXISTS ticket;
CREATE TABLE ticket (
	ticketID varchar(50) NOT NULL,
    cost int NOT NULL,
    carrier varchar(50) NOT NULL,
    customer varchar(50) NOT NULL,
    deplane_at varchar(50) NOT NULL,
    PRIMARY KEY (ticketID),
    CONSTRAINT tickets_ibfk_1 FOREIGN KEY (carrier) REFERENCES flight (flightID),
    CONSTRAINT tickets_ibfk_2 FOREIGN KEY (customer) REFERENCES person (personID),
    CONSTRAINT tickets_ibfk_3 FOREIGN KEY (deplane_at) REFERENCES airport(airportID)
);

DROP TABLE IF EXISTS seat;
CREATE TABLE seat (
	ticketID varchar(50) NOT NULL,
    seat varchar(100) NOT NULL,
    PRIMARY KEY (ticketID, seat),
    CONSTRAINT seats_ibfk_1 FOREIGN KEY (ticketID) REFERENCES ticket (ticketID)
);
INSERT INTO airline (airlineID, revenue) VALUES 
('Air_France', 25), 
('American', 45), 
('Delta', 46), 
('JetBlue', 8), 
('Lufthansa', 31), 
('Southwest', 22), 
('Spirit', 4), 
('United', 40);

INSERT INTO location (locationID) VALUES
('plane_1'), ('plane_11'), ('plane_15'), ('plane_2'), ('plane_4'), ('plane_7'), ('plane_8'), ('plane_9'), ('port_1'), ('port_10'), ('port_11'), ('port_13'), ('port_14'), ('port_15'), ('port_17'), ('port_18'), ('port_2'), ('port_3'), ('port_4'), ('port_5'), ('port_7'), ('port_9');

INSERT INTO airplane VALUES
('American', 'n330ss', 4, 200, 'plane_4', 'jet', NULL, 2),
('American', 'n380sd', 5, 400, NULL, 'jet', NULL, 2),
('Delta', 'n106js', 4, 200, 'plane_1', 'jet', NULL, 2),
('Delta', 'n110jn', 5, 600, 'plane_2', 'jet', 4, 2),
('Delta', 'n127js', 4, 800, NULL, NULL, NULL, NULL),
('Delta', 'n156sq', 8, 100, NULL, NULL, NULL, NULL),
('JetBlue', 'n161fk', 4, 200, NULL, 'jet', NULL, 2),
('JetBlue', 'n337as', 5, 400, NULL, 'jet', NULL, 2),
('Southwest', 'n118fm', 4, 100, 'plane_11', 'prop', 1, 1),
('Southwest', 'n401fj', 4, 200, 'plane_9', 'jet', NULL, 2),
('Southwest', 'n653fk', 6, 400, NULL, 'jet', NULL, 2),
('Southwest', 'n815pw', 3, 200, NULL, 'prop', 0, 2),
('Spirit', 'n256ap', 4, 400, 'plane_15', 'jet', NULL, 2),
('United', 'n451fi', 5, 400, NULL, 'jet', NULL, 4),
('United', 'n517ly', 4, 400, 'plane_7', 'jet', NULL, 2),
('United', 'n616lt', 7, 400, NULL, 'jet', NULL, 4),
('United', 'n620la', 4, 200, 'plane_8', 'prop', 0, 2);

INSERT INTO airport (airportID, airport_name, city, state, locationID)
VALUES 
('ABQ', 'Albuquerque International Sunport', 'Albuquerque', 'NM', NULL),
('ANC', 'Ted Stevens Anchorage International Airport', 'Anchorage', 'AK', NULL),
('ATL', 'Hartsfield-Jackson Atlanta International Airport', 'Atlanta', 'GA', 'port_1'),
('BDL', 'Bradley International Airport', 'Hartford', 'CT', NULL),
('BFI', 'King County International Airport', 'Seattle', 'WA', 'port_10'),
('BHM', 'Birmingham-Shuttlesworth International Airport', 'Birmingham', 'AL', NULL),
('BNA', 'Nashville International Airport', 'Nashville', 'TN', NULL),
('BOI', 'Boise Airport', 'Boise', 'ID', NULL),
('BOS', 'General Edward Lawrence Logan International Airport', 'Boston', 'MA', NULL),
('BTV', 'Burlington International Airport', 'Burlington', 'VT', NULL),
('BWI', 'Baltimore_Washington International Airport', 'Baltimore', 'MD', NULL),
('BZN', 'Bozeman Yellowstone International Airport', 'Bozeman', 'MT', NULL),
('CHS', 'Charleston International Airport', 'Charleston', 'SC', NULL),
('CLE', 'Cleveland Hopkins International Airport', 'Cleveland', 'OH', NULL),
('CLT', 'Charlotte Douglas International Airport', 'Charlotte', 'NC', NULL),
('CRW', 'Yeager Airport', 'Charleston', 'WV', NULL),
('DAL', 'Dallas Love Field', 'Dallas', 'TX', 'port_7'),
('DCA', 'Ronald Reagan Washington National Airport', 'Washington', 'DC', 'port_9'),
('DEN', 'Denver International Airport', 'Denver', 'CO', 'port_3'),
('DFW', 'Dallas-Fort Worth International Airport', 'Dallas', 'TX', 'port_2'),
('DSM', 'Des Moines International Airport', 'Des Moines', 'IA', NULL),
('DTW', 'Detroit Metro Wayne County Airport', 'Detroit', 'MI', NULL),
('EWR', 'Newark Liberty International Airport', 'Newark', 'NJ', NULL),
('FAR', 'Hector International Airport', 'Fargo', 'ND', NULL),
('FSD', 'Joe Foss Field', 'Sioux Falls', 'SD', NULL),
('GSN', 'Saipan International Airport', 'Obyan Saipan Island', 'MP', NULL),
('GUM', 'Antonio B_Won Pat International Airport', 'Agana Tamuning', 'GU', NULL),
('HNL', 'Daniel K. Inouye International Airport', 'Honolulu Oahu', 'HI', NULL),
('HOU', 'William P_Hobby Airport', 'Houston', 'TX', 'port_18'),
('IAD', 'Washington Dulles International Airport', 'Washington', 'DC', 'port_11'),
('IAH', 'George Bush Intercontinental Houston Airport', 'Houston', 'TX', 'port_13'),
('ICT', 'Wichita Dwight D_Eisenhower National Airport', 'Wichita', 'KS', NULL),
('ILG', 'Wilmington Airport', 'Wilmington', 'DE', NULL),
('IND', 'Indianapolis International Airport', 'Indianapolis', 'IN', NULL),
('ISP', 'Long Island MacArthur Airport', 'New York Islip', 'NY', 'port_14'),
('JAC', 'Jackson Hole Airport', 'Jackson', 'WY', NULL),
('JAN', 'Jackson_Medgar Wiley Evers International Airport', 'Jackson', 'MS', NULL),
('JFK', 'John F_Kennedy International Airport', 'New York', 'NY', 'port_15'),
('LAS', 'Harry Reid International Airport', 'Las Vegas', 'NV', NULL),
('LAX', 'Los Angeles International Airport', 'Los Angeles', 'CA', 'port_5'),
('LGA', 'LaGuardia Airport', 'New York', 'NY', NULL),
('LIT', 'Bill and Hillary Clinton National Airport', 'Little Rock', 'AR', NULL),
('MCO', 'Orlando International Airport', 'Orlando', 'FL', NULL),
('MDW', 'Chicago Midway International Airport', 'Chicago', 'IL', NULL),
('MHT', 'Manchester_Boston Regional Airport', 'Manchester', 'NH', NULL),
('MKE', 'Milwaukee Mitchell International Airport', 'Milwaukee', 'WI', NULL),
('MRI', 'Merrill Field', 'Anchorage', 'AK', NULL),
('MSP', 'Minneapolis_St_Paul International Wold_Chamberlain Airport', 'Minneapolis Saint Paul', 'MN', NULL),
('MSY', 'Louis Armstrong New Orleans International Airport', 'New Orleans', 'LA', NULL),
('OKC', 'Will Rogers World Airport', 'Oklahoma City', 'OK', NULL),
('OMA', 'Eppley Airfield', 'Omaha', 'NE', NULL),
('ORD', 'O_Hare International Airport', 'Chicago', 'IL', 'port_4'),
('PDX', 'Portland International Airport', 'Portland', 'OR', NULL),
('PHL', 'Philadelphia International Airport', 'Philadelphia', 'PA', NULL),
('PHX', 'Phoenix Sky Harbor International Airport', 'Phoenix', 'AZ', NULL),
('PVD', 'Rhode Island T_F_Green International Airport', 'Providence', 'RI', NULL),
('PWM', 'Portland International Jetport', 'Portland', 'ME', NULL),
('SDF', 'Louisville International Airport', 'Louisville', 'KY', NULL),
('SEA', 'Seattle-Tacoma International Airport', 'Seattle Tacoma', 'WA', 'port_17'),
('SJU', 'Luis Munoz Marin International Airport', 'San Juan Carolina', 'PR', NULL),
('SLC', 'Salt Lake City International Airport', 'Salt Lake City', 'UT', NULL),
('STL', 'St_Louis Lambert International Airport', 'Saint Louis', 'MO', NULL),
('STT', 'Cyril E_King Airport', 'Charlotte Amalie Saint Thomas', 'VI', NULL);

