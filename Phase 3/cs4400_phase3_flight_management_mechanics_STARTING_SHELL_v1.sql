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
	if (ip_personID is null or ip_locationID is null)
    then leave sp_main;
    end if;
    if ip_personID in (select personID from person)
    then leave sp_main;
    end if;
    if (ip_locationID not in (select * from location))
    then leave sp_main;
    end if;
    insert into person values(ip_personID, ip_first_name, ip_last_name, ip_locationID);
    if (ip_taxID is not null)
    then
		if(ip_experience is null)
        then
        leave sp_main;
        end if;
		if (ip_flying_airline is null xor ip_flying_tail is null)
		then leave sp_main;
		end if;
		insert into pilot values(ip_personID, ip_taxID, ip_experience, ip_flying_airline, ip_flying_tail);
	end if;
    if (ip_miles is not null)
    then
		insert into passenger values (ip_personID, ip_miles);
    end if;
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
if (ip_personID is null or ip_license is null)
then leave sp_main;
end if;

if (ip_personID not in (select personID from pilot))
then leave sp_main;
end if;

#this assumes that license could be any string and not limited to 'jet', 'prop' or 'testing'
if exists(select * from pilot_licenses where personID = ip_personID and license = ip_license)
then leave sp_main;
end if;

insert into pilot_licenses values (ip_personID, ip_license);
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
	if (ip_flightID is null or ip_routeID is null)
    then leave sp_main;
    end if;
    if (ip_routeID not in (select * from route))
    then leave sp_main;
    end if;
    if (ip_support_airline is null xor ip_support_tail is null)
    then leave sp_main;
    end if;
    if (ip_support_airline is not null and ip_support_tail is not null)
    then
		if (ip_progress is null or ip_airplane_status is null or ip_next_time is null)
        then leave sp_main;
        end if;
        if exists (select * from flight where ip_support_airline = support_airline and ip_support_tail = support_tail)
        then leave sp_main;
        end if;
	end if;
    insert into flight values (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, ip_airplane_status, ip_next_time);
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
--  check if ticket or seat number is not null
	if ip_ticketID is NULL or ip_seat_number is NULL
		then leave sp_main;
	end if;
    -- checking if ticket already exists
    if ip_ticketID in (select ticketID from ticket)
		then leave sp_main;
	end if;
    -- check if customer not in database
    if ip_customer not in (select personID from person)
		then leave sp_main;
	end if;
    -- check to see if carrier is in flight
    if ip_carrier not in (select flightID from flight)
		then leave sp_main;
	end if;
    -- check to see if deplane before final or final airport on route 
    if ip_deplane_at is NULL
		then leave sp_main;
	end if;
    -- check to see if seat is unoccupied
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
	if (ip_routeID is null or ip_legID is null)
	then leave sp_main;
	end if;

	#leave if route already exists
	if (ip_routeID in (select routeID from route))
	then leave sp_main;
	end if;

	#leave if the leg doesn't exist
	if ip_legID not in (select legID from leg)
	then leave sp_main;
	end if;

	insert into route values(ip_routeID);
	insert into route_path values(ip_routeID, ip_legID, 1);
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
	if not exists (select * from flight where flightID = ip_flightID)
    then leave sp_main;
    end if;
    if not exists (select * from (select flightID from (select airlineID, tail_num, plane_type, count(*) from airplane inner join pilot on airlineID = flying_airline and tail_num = flying_tail group by airlineID, tail_num having (plane_type = 'jet' and count(*) >= 2) or (plane_type = 'prop' and count(*) >= 1)) as temp inner join flight on support_airline = airlineID and support_tail = tail_num) as temp2 where flightID = ip_flightID)
	then
		update flight set next_time = addtime(next_time,  '00:30:00') where flightID = ip_flightID;
        leave sp_main;
	end if;
	set @distance = (select distance from (select flightID, flight.routeID, legID, progress from flight inner join route_path on flight.routeID = route_path.routeID and progress = sequence) as temp inner join leg on temp.legID = leg.legID where flightID = 'AM_1523'); 
	set @speed = (select speed from flight, airplane where flightID = ip_flightID and airlineID = support_airline and tail_num = support_tail);
	update flight set next_time = addtime(next_time, TIME_FORMAT(SEC_TO_TIME(@distance/@speed * 60 * 60), '%H:%i:%s')) where flightID = ip_flightID;
    update flight set progress = progress + 1, airplane_status = 'in_flight' where flightID = ip_flightID;
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
declare var_routeID varchar(50);
declare var_flight_airline varchar(50);
declare var_flight_tail varchar(50);
declare var_flight_progress integer;

if (ip_flightID is null)
then leave sp_main;
end if;

if (ip_flightID not in (select flightID from flight))
then leave sp_main;
end if;

if ((select airplane_status from flight where flightID = ip_flightID) != 'on_ground')
then leave sp_main;
end if;

#checking if support_airline and support_tail are not null
if (select support_airline from flight where flightID = ip_flightID) is null
then leave sp_main;
end if;

if (select support_tail from flight where flightID = ip_flightID) is null
then leave sp_main;
end if;

select routeID, support_airline, support_tail, progress into var_routeID, var_flight_airline, var_flight_tail, var_flight_progress from flight where flightID = ip_flightID;

#checking if location is null
if (select locationID from airplane where
airlineID = var_flight_airline and
tail_num = var_flight_tail) is null
then leave sp_main;
end if;

if (ip_flightID not in (select carrier from ticket))
then leave sp_main;
end if;

update person
	set locationID = (
   	 select locationID from airplane
    	where airlineID = var_flight_airline and tail_num = var_flight_tail
    )
	# the boarding passengers must be located in the airport of the upcoming leg's departure airport
	where locationID = (
   	 select locationID from airport
   	 where airportID = (
   		 select departure from leg
   		 where legID = (
   			 select legID from route_path
   			 where routeID = var_routeID and sequence = var_flight_progress + 1
   		 )
   	 )
    # and must own tickets for the flight
    ) and (
   	 select count(*) from ticket
    	where carrier = ip_flightID and customer = personID
    ) > 0;

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
declare var_routeID varchar(50);
declare var_flight_airline varchar(50);
declare var_flight_tail varchar(50);
declare var_flight_progress integer;

if (ip_flightID is null)
then leave sp_main;
end if;

if (ip_flightID not in (select flightID from flight))
then leave sp_main;
end if;

if ((select airplane_status from flight where flightID = ip_flightID) != 'on_ground')
then leave sp_main;
end if;

#checking if support_airline and support_tail are not null
if (select support_airline from flight where flightID = ip_flightID) is null
then leave sp_main;
end if;

if (select support_tail from flight where flightID = ip_flightID) is null
then leave sp_main;
end if;

select routeID, support_airline, support_tail, progress into var_routeID, var_flight_airline, var_flight_tail, var_flight_progress from flight where flightID = ip_flightID;

#checking if airport location is null
if (select locationID from airport where
airportID = (
	select arrival from leg
		where legID = (
			select legID from route_path
				where routeID = var_routeID  and sequence = var_flight_progress ))) is null
then leave sp_main;
end if;

#checking if airplane location is null
if (select locationID from airplane where
airlineID = var_flight_airline and
tail_num = var_flight_tail) is null
then leave sp_main;
end if;

if (ip_flightID not in (select carrier from ticket))
then leave sp_main;
end if;

update person
	set locationID = (
    #getting the airport location
		select locationID from airport where
			airportID = (
				select arrival from leg
					where legID = (
						select legID from route_path
							where routeID = var_routeID and sequence = var_flight_progress ))
    )
	# the disembarking passengers must be located in the airport of the current leg's arrival airport
	where locationID = (
   	 select locationID from airplane where
		airlineID = var_flight_airline and
		tail_num = var_flight_tail
    ) and 
	(select arrival from leg
					where legID = (
						select legID from route_path
							where routeID = var_routeID and sequence = var_flight_progress )) in (
   	 select deplane_at from ticket
    	where carrier = ip_flightID and customer = personID
    ); 
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
	declare ending_plane_locationID varchar(50);

-- check if flight has ended
if (SELECT progress FROM flight WHERE flightID = ip_flightID) != 3
	then
    leave sp_main;
end if;

-- check if all passengers have disembarked
-- for this we have to join flight with airplane, and get the plane's locationID
-- then check if any people are on that airplane (if they are at that locationID)
select locationID
from flight as f
join airplane as a
on f.support_airline = a.airlineID and f.support_tail = a.tail_num
where f.flightID = ip_flightID
into ending_plane_locationID;

if exists (select * from person as p where p.locationID = ending_plane_locationID)
	then leave sp_main;
end if;


-- Get the pilots to release and put them in a table
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

-- Update the pilots, clear their flying airline and tail
UPDATE pilot
SET flying_airline = NULL, flying_tail = NULL
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
	if (ip_flightID not in (select flightID from flight))
    then leave sp_main;
    end if;
    if ((select airplane_status from flight where flightID = ip_flightID) = 'on_ground')
    then
		if ((select progress from flight where flightID = ip_flightID) = 0)
        then delete from flight where flightID = ip_flightID;
        end if;
        if
        (select progress from flight where flightID = ip_flightID) = 
        (select max(sequence) from route_path where routeID =
			(select routeID from flight where flightID = ip_flightID)
            group by routeID)
		then delete from flight where flightID = ip_flightID;
		end if;
	end if;
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
	if not (select flightID from 
	(select personID, airlineID, tail_num from person inner join airplane on person.locationID = airplane.locationID) as temp 
	inner join flight on airlineID = support_airline and tail_num = support_tail where personID = ip_personID) = 'on_ground'
    then leave sp_main;
    end if;
	delete from passenger where personID = ip_personID;
    if not exists (select * from pilot where personID = ip_personID)
    then
		delete from person where personID = ip_personID;
	end if;
	if exists (select * from pilot where personID = ip_personID)
    then 
		call passengers_disembark (
		(select flightID from 
		(select personID, airlineID, tail_num from person inner join airplane on person.locationID = airplane.locationID) as temp 
		inner join flight on airlineID = support_airline and tail_num = support_tail where personID = ip_personID));
	end if;
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

    set @airplane_status = (select airplane_status
    from pilot
    join flight on pilot.flying_airline = flight.support_airline and pilot.flying_tail = flight.support_tail
    where pilot.personID = ip_personID);
    
    set @num_legs = (select count(*)
    from pilot
    join flight on pilot.flying_airline = flight.support_airline and pilot.flying_tail = flight.support_tail
    join route_path on flight.routeID = route_path.routeID
    where personID = ip_personID
    group by personID);
    
    if (@airplane_status = 'in_flight')
		then leave sp_main;
	end if;
    
    if ((select flying_airline from pilot where ip_personID = personId) is not NULL and 
    (select flying_tail from pilot where ip_personID = personId) is not NULL) and (@progress > 0 and @progress < @num_legs) and (@airplane_status = 'on_ground')
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
select leg.departure AS departing_from, count(DISTINCT flightID) AS num_flights, GROUP_CONCAT(DISTINCT flightID ORDER BY flightID ASC) AS flight_list, MIN(next_time) AS earliest_arrival, MAX(next_time) AS latest_arrival, GROUP_CONCAT(DISTINCT locationID ORDER BY locationID ASC) AS airplane_list
FROM flight 
join airplane on support_airline = airlineID and support_tail = tail_num
	join route_path on flight.routeID = route_path.routeID
	join leg on route_path.legID = leg.legID
WHERE airplane_status = 'on_ground' AND progress = sequence - 1
GROUP BY departure
ORDER BY flight_list ASC;
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
SELECT city, state, COUNT(*) AS num_airports, GROUP_CONCAT(airportID ORDER BY airportID) AS airport_codes, GROUP_CONCAT(airport_name ORDER BY airportID) AS airport_names
FROM airport
GROUP BY city, state
HAVING COUNT(*) > 1;

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
	set @fl = (select flightID from flight where next_time = (select min(next_time) from flight) order by airplane_status, flightID limit 1);
    set @stat = (select airplane_status from flight where flightID = @f1);
    if  (@stat = 'in_flight')
    then 
		call flight_landing(@f1);
        call passengers_disembark(@f1);
        call recycle_crew(@f1);
        call retire_flight(@f1);
	else
		call passengers_board(@f1);
        call flight_takeoff(@f1);
    end if;
    
end //
delimiter ;