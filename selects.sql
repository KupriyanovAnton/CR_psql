SELECT
	aircraft_code
FROM
	aircrafts_data
WHERE
	model->>lang() LIKE 'Аэробус_A32%';

SELECT
	airport_code,
	airport_name->>lang() as airport_name,
	coordinates, 
	timezone
FROM
	airports_data
WHERE
	circle '<(37.617222, 55.755833), 1>' @> coordinates;
	
SELECT
	flight_no,
	concat(departure_airport, '->', arrival_airport) as route,
	format('%s hours, %s mins', 
		(EXTRACT(epoch from scheduled_arrival-scheduled_departure)/3600)::int, 
		EXTRACT(minute from scheduled_arrival-scheduled_departure)) as duration
FROM
	flights
WHERE
	 (scheduled_arrival-scheduled_departure) > interval '8 hours';

SELECT
	passenger_name,
	array_agg(contact_data->>'phone') phones_arr
FROM
	tickets
WHERE
	contact_data->>'phone' IS not NULL
GROUP BY passenger_name;

SELECT
	COUNT(DISTINCT passenger_name) num_passengers
FROM
	tickets

