-- 1. Вывести все коды самолетов Аэробус, номер модели которых начинается на А32
SELECT
	aircraft_code
FROM
	aircrafts_data
WHERE
	model->>'ru' LIKE 'Аэробус_A32%';


-- 2. Вывести все аэропорты Москвы с заданием координат Москвы.
SELECT
	airport_code,
	airport_name->>lang() as airport_name,
	coordinates, 
	timezone
FROM
	airports_data
WHERE
	coordinates <@ circle '<(37.61, 55.75), 1>';
	
	
-- 3. Вывести все маршруты, которые длятся 8 и больше часов. 
--    Вывод должен быть как в примере: PG0168, DME -> UUS, "8 hours, 50 mins"
SELECT
	flight_no,
	concat(departure_airport, '->', arrival_airport) as route,
	format('%s hours, %s mins', 
		(EXTRACT(epoch from duration)/3600)::int, 
		EXTRACT(minute from duration)) as duration
FROM
	routes
WHERE
	 duration >= interval '8 hours'
ORDER BY duration;


-- 4. Вывести всех клиентов без дубликатов, у которых есть номер телефона в БД. 
--    Пример:  Valeriy Tikhonov, +70127117011
SELECT
	initcap(passenger_name) passenger_name,
	array_agg(contact_data->>'phone') phones_arr
FROM
	tickets
WHERE
	contact_data->>'phone' IS not NULL
GROUP BY initcap(passenger_name);


-- 5. Посчитать сколько всего пассажиров когда-то покупало билеты.
SELECT
	COUNT(DISTINCT passenger_name) num_passengers
FROM
	tickets;
	

-- 6.Посчитать количество мест для каждой модели самолета, 
-- Пример: Аэробус А319-100, 20
SELECT
	a.model,
	COALESCE(s.num_seats, 0) num_seats 
FROM Aircrafts a
	LEFT JOIN (SELECT
			aircraft_code,
			COUNT( DISTINCT seat_no) num_seats
		FROM
			seats
		GROUP BY aircraft_code) s USING(aircraft_code);
		
		
-- 7.7. Посчитать количество мест для каждой модели самолета, с разделением по классу, а 
-- также отсортированному сначала по модели, а потом по классу. 
-- Пример: Аэробус A319-100,Business,20
SELECT
	a.model,
	COALESCE(s.fare_conditions, 'unknown') fare_conditions,
	COALESCE(s.num_seats, 0) num_seats 
FROM Aircrafts a
	LEFT JOIN (SELECT
			aircraft_code,
			fare_conditions,
			COUNT( DISTINCT seat_no) num_seats
		FROM
			seats
		GROUP BY aircraft_code, fare_conditions) s USING(aircraft_code)
ORDER BY
	a.model, COALESCE(s.fare_conditions, 'unknown')

