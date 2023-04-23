-- [23] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------

select r.routeID,
COUNT(DISTINCT l.legID),
GROUP_CONCAT(DISTINCT l.legID  ORDER BY sequence),
SUM(l.distance),
COUNT(DISTINCT f.flightID),
GROUP_CONCAT(DISTINCT f.flightID order by sequence),
GROUP_CONCAT(l.arrival order by sequence)
from route as r
join route_path as p
on r.routeID = p.routeID
join leg as l
on l.legID = p.legID
left join flight as f
on f.routeID = r.routeID
group by routeID;