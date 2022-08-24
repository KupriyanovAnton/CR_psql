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
	bp.seat_no;
SELECT
	array_to_string(array_agg(DISTINCT tc.passenger_name), ',', 'unknown') passenger_list, 
	array_to_string(array_agg(DISTINCT fl.flight_no), ',', 'unknown') flight_list
FROM
	tickets tc 
	join ticket_flights tf using(ticket_no)
	join flights fl using(flight_id)
WHERE
	book_ref = '3B54BB'
