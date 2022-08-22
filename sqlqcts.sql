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
	circle '<(37.617222, 55.755833), 1>' @> coordinates
