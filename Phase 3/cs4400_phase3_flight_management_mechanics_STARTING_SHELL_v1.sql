-- CS4400: Introduction to Database Systems: Wednesday, March 8, 2023
-- Flight Management Course Project Mechanics (v1.0) STARTING SHELL
-- Views, Functions & Stored Procedures

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
	-- Check if the inputs are valid.
	if (ip_airlineID is null or ip_tail_num is null or ip_seat_capacity is null or
		ip_speed is null) 
        then leave sp_main;
	end if;

	if (ip_seat_capacity <= 0 or ip_speed <= 0) 
    then leave sp_main;
	end if;

	if (ip_airlineID not in (select airlineID from airline))
    then leave sp_main;
    end if;
	-- Check if the airplane's tail number is unique for the given airline.
	if exists (select * from airplane where airlineID = ip_airlineID and tail_num = ip_tail_num) 
    then leave sp_main;
	end if;

	-- Check if the airplane's location is unique across the entire database.
	if (ip_locationID is not null)
    then
    if (ip_locationID not in (select * from location))
    then leave sp_main;
    end if;
	end if;

	-- Insert the new airplane into the database.
	insert into airplane values (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);
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
-- check if primary key is null
	if ip_airportID is null
		then leave sp_main;
	end if;
-- check to see if airportID works
	if ip_airportID in (select airportID from airport)
		then leave sp_main;
	end if;
-- check if city or state is null
	if ip_state is NULL or ip_city is NUll
		then leave sp_main;
	end if;
-- possible checks to see if name is longer than 
    insert into airport values(ip_airportID, ip_airport_name, ip_city, ip_state, ip_locationID);
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

-- [6] purchase_ticket_and_seat() - Dongjae
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
	if ip_ticketID is NULL or ip_seat_number is NULL
		then leave sp_main;
	end if;
    if ip_ticketID in (select ticketID from ticket)
		then leave sp_main;
	end if;
    if ip_customer not in (select personID from person)
		then leave sp_main;
	end if;
    if ip_carrier not in (select flightID from flight)
		then leave sp_main;
	end if;
    -- check to see if deplane before final or final airport on route 
    if ip_deplane_at is NULL
		then leave sp_main;
	end if;
    if ip_seat_number in (select seat_number from ticket_seats)
		then leave sp_main;
	end if;
    insert into ticket values (ip_ticketID, ip_cost, ip_carrier, ip_customer, ip_deplane_at);
    insert into ticket_seats values (ip_ticketID, ip_seat_number);
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

end //
delimiter ;

-- [10] flight_landing() - Dongjae
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
        -- get routeID
    set @ip_routeID = (select routeID from flight where flightID = ip_flightID);
	if ip_flightID is NULL
		then leave sp_main;
	end if;
        -- check if flight exists
    if ip_flightID not in (select flightID from flight) then
        leave sp_main;
    end if;

    -- check if flight is in flight
    if (select airplane_status from flight where flightID = ip_flightID) = 'on_ground' then
        leave sp_main;
    end if;

    -- check if flight is at last leg
    -- if (select progress from flight where flightID = ip_flightID) = (select max(sequence) from route_path where routeID = @ip_routeID) then
        -- leave sp_main;
    -- end if;
    -- updating flight
    update flight
    set next_time = addtime(next_time, '1:00:00'), airplane_status = 'on_ground'
    where ip_flightID = flight.flightID;
    -- updating pilot
    update pilot
    set experience = experience + 1
    where flying_tail in (select support_tail from flight where flightID = ip_flightID);
    -- updating passenger
    set @distance = (
    select distance from flight
    join route_path on route_path.routeID = flight.routeID
    join leg on leg.legID = route_path.legID
    where flightID = ip_flightID and progress = sequence);
    update passenger
    set passenger.miles = passenger.miles + @distance
    where personID in (select customer from ticket where ticket.carrier = ip_flightID);
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

-- [14] assign_pilot() - dongjae
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
	if (ip_flightID is NULL or ip_personID is NULL) 
		then leave sp_main;
	end if;
    if ((select flying_airline from pilot where ip_personID = personID) is not NULL) and
    ((select flying_tail from pilot where ip_personID = personID) is not NULL)
		then leave sp_main;
	end if;
    if (ip_flightID in (select flightID from flight where flight.progress = 'in_flight'))
		then leave sp_main;
	end if;
	if ((select plane_type from airplane join flight 
    on (airplane.airlineID = flight.support_airline and airplane.tail_num = flight.support_tail)
    where ip_flightID = flight.flightID) not in (select license from pilot_licenses where personID = ip_personID))
		then leave sp_main;
	end if;
	
    -- update person values
    update person
    set locationID = (select airplane.locationID from airplane join flight 
    on (airplane.airlineID = flight.support_airline and airplane.tail_num = flight.support_tail)
    where flight.flightID = ip_flightID)
    where personID = ip_personID;
    
    -- update flying_airline
    update pilot
    set flying_airline = (select support_airline from flight where ip_flightID = flight.flightID)
    where personID = ip_personID;
	-- update flying_tail
    update pilot
    set flying_tail = (select support_tail from flight where ip_flightID = flight.flightID)
    where personID = ip_personID;
    
    
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

-- [18] remove_pilot_role() - dongjae
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
	if ip_personID is NULL 
		then leave sp_main;
	end if;
    if ip_personID not in (select personId from pilot)
		then leave sp_main;
	end if;
    
    
    set @progress = (select progress
    from pilot
    join flight on pilot.flying_airline = flight.support_airline and pilot.flying_tail = flight.support_tail
    where pilot.personID = ip_personID);
    
    set @num_legs = (select count(*)
    from pilot
    join flight on pilot.flying_airline = flight.support_airline and pilot.flying_tail = flight.support_tail
    join route_path on flight.routeID = route_path.routeID
    where personID = ip_personID
    group by personID);
    
    if ((select flying_airline from pilot where ip_personID = personId) is not NULL and 
    (select flying_tail from pilot where ip_personID = personId) is not NULL) and  (@progress > 0 and @progress < @num_legs)
		then leave sp_main;
	end if;
    
    if (ip_personID not in (select personID from passenger))
    -- delete both person and pilot sections
		then delete from pilot_licenses
        where personID = ip_personID;
        delete from pilot
		where personID = ip_personID;
        delete from person
		where personID = ip_personID;
        leave sp_main;
	end if;
    delete from pilot_licenses
	where personID = ip_personID;
	delete from pilot
	where personID = ip_personID;
		
end //
delimiter ;

-- [19] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
select null, null, 0, null, null, null, null;

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
select null, null, 0, null, null, null, null, 0, 0, null, null;

-- [22] people_on_the_ground() - dongjae
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, num_pilots, num_passengers, joint_pilots_passengers, person_list) as

    select airportID, person.locationID, airport_name, city, state, count(taxID), count(miles),  count(*), GROUP_CONCAT(person.personID separator ',') as joint_passengers_pilots from person
    join airport on person.locationID = airport.locationID
    left join pilot on pilot.personID = person.personID
    left join passenger on passenger.personID = person.personID
	group by airportID;

-- [23] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
select null, 0, null, 0, 0, null, null;

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