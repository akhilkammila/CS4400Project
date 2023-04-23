-- select airportID, person.locationID, airport_name, city, state, count(taxID), count(miles),  count(*), GROUP_CONCAT(person.personID separator ',') as joint_passengers_pilots from person
-- join airport on person.locationID = airport.locationID
-- left join pilot on pilot.personID = person.personID
-- left join passenger on passenger.personID = person.personID
-- group by airportID;

-- persons have locationIDs
-- those correspond to locations
-- which correspond to airports and airplanes
-- and then airplanes are on a flight

-- we need to know what LEG the person is departing and arriving from
-- we need to know the 

select locationID from flight as f join airplane as a on f.support_airline = a.airlineID and f.support_tail = a.tail_num;