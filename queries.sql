SELECT
	bp.seat_no,
	tc.passenger_name
FROM
	boarding_passes bp JOIN tickets tc USING (ticket_no)
WHERE flight_id IN	
 				(SELECT
					f.flight_id
				FROM
					flights f
				WHERE
					flight_no = 'PG0405' 
					AND date_trunc('day', scheduled_departure) = timestamptz '2017-07-16')
ORDER BY
	LENGTH(bp.seat_no),
	bp.seat_no
