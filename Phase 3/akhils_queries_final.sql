-- CS4400: Introduction to Database Systems: Wednesday, March 8, 2023
-- Flight Management Course Project Mechanics (v1.0) STARTING SHELL
-- Views, Functions & Stored Procedures

-- Akhil's Queries: 7,9,15,19,21,23
-- done so far: 7,9,19,23
-- need to do: 15, 21
-- swapped 3 for 9 and 11 for 21 with david

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_management';

use flight_management;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a database-wide unique location if
it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin

end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a database-wide unique location if it will be used to support
airplane takeoffs and landings.  An airport may have a longer, more descriptive
name.  An airport must also have a city and state designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state char(2), in ip_locationID varchar(50))
sp_main: begin

end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person may have a first and last name as well.

Also, a person can hold a pilot role, a passenger role, or both roles.  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  Also,
a pilot might be assigned to a specific airplane as part of the flight crew.  As a
passenger, a person will have some amount of frequent flyer miles. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_flying_airline varchar(50), in ip_flying_tail varchar(50),
    in ip_miles integer)
sp_main: begin

end //
delimiter ;

-- [4] grant_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new pilot license.  The license must reference
a valid pilot, and must be a new/unique type of license for that pilot. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_pilot_license;
delimiter //
create procedure grant_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin

end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  Once
an airplane has been assigned, we must also track where the airplane is along
the route, whether it is in flight or on the ground, and when the next action -
takeoff or landing - will occur. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_airplane_status varchar(100), in ip_next_time time)
sp_main: begin

end //
delimiter ;

-- [6] purchase_ticket_and_seat()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ticket.  The cost of the flight is optional
since it might have been a gift, purchased with frequent flyer miles, etc.  Each
flight must be tied to a valid person for a valid flight.  Also, we will make the
(hopefully simplifying) assumption that the departure airport for the ticket will
be the airport at which the traveler is currently located.  The ticket must also
explicitly list the destination airport, which can be an airport before the final
airport on the route.  Finally, the seat must be unoccupied. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ticket_and_seat;
delimiter //
create procedure purchase_ticket_and_seat (in ip_ticketID varchar(50), in ip_cost integer,
	in ip_carrier varchar(50), in ip_customer varchar(50), in ip_deplane_at char(3),
    in ip_seat_number varchar(50))
sp_main: begin

end //
delimiter ;

-- [7] add_update_leg()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new leg as specified.  However, if a leg from
the departure airport to the arrival airport already exists, then don't create a
new leg - instead, update the existence of the current leg while keeping the existing
identifier.  Also, all legs must be symmetric.  If a leg in the opposite direction
exists, then update the distance to ensure that it is equivalent.   */
-- -----------------------------------------------------------------------------
drop procedure if exists add_update_leg;
delimiter //
create procedure add_update_leg (in ip_legID varchar(50), in ip_distance integer,
    in ip_departure char(3), in ip_arrival char(3))
sp_main: begin

	declare opposite_legID varchar(50);
    declare replace_legID varchar(50);

	-- Check if leg from dept airport to arrival airport alr exists
    -- if so, update existance of current leg
	if EXISTS (SELECT legID FROM leg WHERE departure = ip_departure and arrival = ip_arrival)
		then
		SELECT legID FROM leg WHERE departure = ip_departure and arrival = ip_arrival into replace_legID;
        UPDATE leg SET distance = ip_distance WHERE legID = replace_legID;
	-- otherwise, we create a new leg
    -- but, we have to make sure that legIDs are not conflicting
	else
		if not exists(select legID from leg where legID = ip_legID)
			then
            INSERT into leg values(ip_legID, ip_distance, ip_departure, ip_arrival);
		end if;
	end if;

	-- Check for symmetric leg in opposite direction
	if exists(select legID FROM leg WHERE departure = ip_arrival and arrival = ip_departure)
		then
		select legID FROM leg WHERE departure = ip_arrival and arrival = ip_departure into opposite_legID;
		update leg set distance = opposite_distance where legID = opposite_legID;
	end if;

end //
delimiter ;

-- [8] start_route()
-- -----------------------------------------------------------------------------
/* This stored procedure creates the first leg of a new route.  Routes in our
system must be created in the sequential order of the legs.  The first leg of
the route can be any valid leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_route;
delimiter //
create procedure start_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin

end //
delimiter ;

-- [9] extend_route()
-- -----------------------------------------------------------------------------
/* This stored procedure adds another leg to the end of an existing route.  Routes
in our system must be created in the sequential order of the legs, and the route
must be contiguous: the departure airport of this leg must be the same as the
arrival airport of the previous leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists extend_route;
delimiter //
create procedure extend_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin

-- Few extra checks:
-- routeID and legID are primary keys and are going to be inserted, so they cant be null
if ip_routeID is null or ip_legID is null
	then leave sp_main;
end if;
-- legID must exist, and route must already exist
if ip_legID not in (select legID from leg) or ip_routeID not in (select routeID from route)
	then leave sp_main;
end if;

-- Check if this leg is the same as the arrival airport of the last leg
if
	-- Get this leg's departure
	(SELECT departure
	FROM leg
	WHERE legID = ip_legID)

	!=

	-- Get the previous leg's arrival
	(SELECT arrival
	FROM leg
	WHERE legID in
		-- Find id of last leg (before this one that we are adding)
		(SELECT legID
		FROM route_path
		WHERE routeID = ip_routeID and sequence in
			-- Find the sequence number of last leg in that route
			(SELECT MAX(sequence)
			FROM route_path as p
			GROUP BY routeID
			HAVING routeID = ip_routeID)))

	then leave sp_main;
end if;

-- Passed checks, now we insert
INSERT into route_path values (
ip_routeID,
ip_legID,

-- Find the sequence number of last leg in that route
((SELECT MAX(sequence)
FROM route_path as p
GROUP BY routeID
HAVING routeID = ip_routeID)+1));

end //
delimiter ;

-- [10] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin

end //
delimiter ;

-- [11] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin

end //
delimiter ;

-- [12] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the airport and hold a valid ticket
for the flight. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin

end //
delimiter ;

-- [13] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin

end //
delimiter ;

-- [14] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
airplane.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin

end //
delimiter ;

-- [15] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin

declare ending_plane_locationID varchar(50);
declare max_sequence_num integer;

declare curr_routeID varchar(50);
declare last_legID varchar(50);
declare arrival_airport char(3);
declare ending_airport_locationID varchar(50);

-- check if flight has ended
-- 1. get max sequence number
SELECT MAX(rp.sequence)
FROM flight as f
JOIN route_path as rp
ON f.routeID = rp.routeID
WHERE f.flightID = ip_flightID
GROUP BY(f.routeID)
into max_sequence_num;
-- 2. check if flight's progrss equals max sequence number
if (SELECT progress FROM flight WHERE flightID = ip_flightID) != max_sequence_num
	then
    leave sp_main;
end if;

-- check if all passengers have disembarked
-- for this we have to join flight with airplane, and get the plane's locationID
-- then check if any people are on that airplane (if they are at that locationID)

-- get plane locationID
select locationID
from flight as f
join airplane as a
on f.support_airline = a.airlineID and f.support_tail = a.tail_num
where f.flightID = ip_flightID
into ending_plane_locationID;

-- check that no passenger is on the pain
if exists
	(select * from person as p join passenger as pa
	where p.locationID = ending_plane_locationID
    and p.personID = pa.personID)
    
	then leave sp_main;
end if;

-- get the pilots to release and put them in a table
DROP TABLE if EXISTS pilotsToRelease;
CREATE TABLE pilotsToRelease(
	pilot_id varchar(50) PRIMARY KEY
);

INSERT INTO pilotsToRelease(pilot_id)
SELECT personID
FROM flight as f
JOIN pilot as p
ON f.support_airline = p.flying_airline and f.supporT_tail = p.flying_tail
WHERE f.flightID = ip_flightID;

-- Update the pilots in the pilot table, clear their flying airline and tail
UPDATE pilot
SET flying_airline = NULL, flying_tail = NULL
WHERE personID in (SELECT * FROM pilotsToRelease);

-- Update the pilots in the person table
-- to do this, we first need to get the port that the plane is now at
select routeID from flight where flightID = ip_flightID into curr_routeID;
select legID from route_path where routeID = curr_routeID and sequence = max_sequence_num into last_legID;
select arrival from leg where legID = last_legID into arrival_airport;
select locationID from airport where airportID = arrival_airport into ending_airport_locationID;

UPDATE person
SET locationID = ending_airport_locationID
WHERE personID in (SELECT * FROM pilotsToRelease);

DROP TABLE if EXISTS pilotsToRelease;

end //
delimiter ;

-- [16] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin

end //
delimiter ;

-- [17] remove_passenger_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the passenger role from person.  The passenger
must be on the ground at the time; and, if they are on a flight, then they must
disembark the flight at the current airport.  If the person had both a pilot role
and a passenger role, then the person and pilot role data should not be affected.
If the person only had a passenger role, then all associated person data must be
removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_passenger_role;
delimiter //
create procedure remove_passenger_role (in ip_personID varchar(50))
sp_main: begin

end //
delimiter ;

-- [18] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the pilot role from person.  The pilot must not
be assigned to a flight; or, if they are assigned to a flight, then that flight
must either be at the start or end of its route.  If the person had both a pilot
role and a passenger role, then the person and passenger role data should not be
affected.  If the person only had a pilot role, then all associated person data
must be removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_personID varchar(50))
sp_main: begin

end //
delimiter ;

-- [19] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
select departure as departing_from,
arrival as arriving_at,
COUNT(*) as num_flights,
GROUP_CONCAT(flightID SEPARATOR ',') as flight_list,
MIN(next_time) as earliest_arrival,
MAX(next_time) as latest_arrival,
GROUP_CONCAT(locationID SEPARATOR ',') as airplane_list
from
	-- get flights in the air
	(select *
	from flight
	where airplane_status = 'in_flight') as f
join route_path as p
on f.routeID = p.routeID and f.progress = p.sequence
join leg as l
on p.legID = l.legID
join airplane as a
on f.support_airline = a.airlineID and f.support_tail = a.tail_num
GROUP BY departure, arrival;

-- [20] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
select null, 0, null, null, null, null;

-- [21] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
SELECT
    l.departure AS departing_from,
    l.arrival AS arriving_at,
    COUNT(DISTINCT a.tail_num) AS num_airplanes,
    GROUP_CONCAT(DISTINCT a.locationID) AS airplane_list,
    GROUP_CONCAT(DISTINCT f.flightID) AS flight_list,
    MIN(f.next_time) AS earliest_arrival,
    MAX(f.next_time) AS latest_arrival,
    COUNT(DISTINCT pi.personID) AS num_pilots,
    COUNT(DISTINCT pa.personID) AS num_passengers,
    COUNT(DISTINCT p.personID) AS joint_pilots_passengers,
    GROUP_CONCAT(DISTINCT p.personID) AS person_list
FROM flight as f
JOIN airplane as a
ON f.support_airline = a.airlineID AND f.support_tail = a.tail_num
JOIN person as p
ON a.locationID = p.locationID
JOIN route_path as rp
ON f.routeID = rp.routeID and progress = sequence
JOIN leg as l
ON rp.legID = l.legID
left JOIN pilot as pi
ON p.personID = pi.personID
left JOIN passenger as pa
ON p.personID = pa.personID
WHERE airplane_status = 'in_flight'
GROUP BY l.departure, l.arrival;

-- [22] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select null, null, null, null, null, 0, 0, null, null;

-- [23] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
select route, num_legs, leg_sequence, route_length, COUNT(f.flightID) as num_flights,
GROUP_CONCAT(f.flightID SEPARATOR ',') as flight_list, airport_sequence
from
	-- Combines route path, and leg
	-- route path's legID matches leg's legID (we find all the legs in a route)
	(select p.routeID as route,
	COUNT(DISTINCT l.legID) as num_legs,
	GROUP_CONCAT(DISTINCT l.legID  ORDER BY sequence) as leg_sequence,
	SUM(l.distance) as route_length,
	GROUP_CONCAT(CONCAT(l.departure, '->', l.arrival) order by sequence) as airport_sequence
	from route_path as p
	join leg as l
	on l.legID = p.legID
	group by routeID) as pl
left join flight as f
on f.routeID = pl.route
group by pl.route;

-- [24] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, num_airports,
	airport_code_list, airport_name_list) as
select null, null, 0, null, null;

-- [25] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin

end //
delimiter ;