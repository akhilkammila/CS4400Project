SELECT MAX(rp.sequence)
FROM flight as f
JOIN route_path as rp
ON f.routeID = rp.routeID
WHERE f.flightID = 'AM_1523'
GROUP BY(f.routeID);