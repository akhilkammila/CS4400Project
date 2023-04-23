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