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
	book_ref = '3B54BB';
	
	
-- Перелеты из VKO в CNN

with recursive ways(dep, arr, dur) as (
    
	select 
        departure_airport, 
        arrival_airport, 
        duration, 
        array[departure_airport::text, arrival_airport::text] path
    from
		routes
    where 
		departure_airport = 'VKO'
	
    union
	
    select 
        r.departure_airport, 
        r.arrival_airport, 
        w.dur + r.duration,
        w.path || r.arrival_airport::text
    from routes r
		inner join ways w on w.arr = r.departure_airport
    where
        not r.arrival_airport = any(w.path)
		and w.dur + r.duration <= interval '10 hours'
        and w.dep <> 'CNN'
)

select
	dur,
    array_to_string(path, '->') path,
	format('%s years %s monts %s days %s hours %s mins %s secs',  
		  extract(year from dur), 
		  extract(month from dur),
		  extract(day from dur),
		  extract(hour from dur),
		  extract(minute from dur),
		  extract(second from dur)) duration
from ways
where arr = 'CNN'
ORDER BY dur; 
