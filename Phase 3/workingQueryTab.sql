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