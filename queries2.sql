-- Вывести всех пассажиров (их фио) и присвоенные им места 
-- на рейсе 'PG0405', который вылетел 16 июля 2017 года.
SELECT
	bp.seat_no,
	tc.passenger_name
FROM
	boarding_passes bp JOIN tickets tc USING (ticket_no)
	JOIN  flights f ON bp.flight_id = f.flight_id
	
WHERE 
	f.flight_no = 'PG0405' 
	AND actual_departure::date = '2017-07-16'::date
ORDER BY
	LENGTH(bp.seat_no),
	bp.seat_no;
	
	
-- Вывести список пассажиров (их фио) и список рейсов, билеты на которые 
-- были куплены в бронировании 3B54BB. 
-- Пример: "DARYA TIKHONOVA,DMITRIY KUZMIN,TATYANA SOROKINA","PG0013,PG0224,PG0703,PG0704”
SELECT
	string_agg(DISTINCT tc.passenger_name, ',') passenger_list, 
	string_agg(DISTINCT fl.flight_no, ',') flight_list
FROM
	tickets tc 
		join ticket_flights tf using(ticket_no)
		join flights fl using(flight_id)
WHERE
	book_ref = '3B54BB';
	
	
-- Вывести все возможные пути перелетов из Внуково(VKO) в Чульман(CNN), чтобы общая продолжительность 
-- времени перелета (время от отправления до прибытия, паузы не считаем) было не более 10 часов.
-- Пример: "{VKO,BZK,SVO,KVX,KZN,MQF,SVX,PEE,CNN}",0 years 0 mons 0 days 9 hours 30 mins 0.0 secs
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
