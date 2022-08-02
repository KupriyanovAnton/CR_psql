set session "bookings.lang" = 'eng';

CREATE OR REPLACE FUNCTION lang() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
  RETURN current_setting('bookings.lang');
EXCEPTION
  WHEN undefined_object THEN
    RETURN NULL;
END;
$$;

CREATE TABLE IF NOT EXISTS aircrafts_data(
    	aircraft_code 		char(3) CONSTRAINT aircraft_key PRIMARY KEY,
    	model			jsonb NOT NULL,
	range			integer NOT NULL CONSTRAINT aircraft_range_verifacation CHECK (range > 0)    
);

CREATE OR REPLACE VIEW aircrafts AS
	SELECT 
		ml.aircraft_code,
        	ml.model ->> lang() AS model,
    		ml.range
	FROM 
		aircrafts_data ml;
	
CREATE TABLE IF NOT EXISTS airports_data(
	airport_code		char(3) CONSTRAINT airport_key PRIMARY KEY,
	airport_name		jsonb NOT NULL,
	city			jsonb NOT NULL,
	coordinates		point NOT NULL,
	timezone		text NOT NULL
);

CREATE OR REPLACE VIEW airports AS
	SELECT 
		ml.airport_code,
		ml.airport_name ->> lang() AS airport_name,
		ml.city ->> lang() AS city,
		ml.coordinates,
		ml.timezone
	FROM 
		airports_data ml;

CREATE TABLE IF NOT EXISTS ticket_flights(
	ticket_no		char(13),
	flight_id		integer,
	fare_conditions		varchar(10),
	amount			numeric(10,2),
	CONSTRAINT ticket_flights_key PRIMARY KEY(ticket_no, flight_id),
	CONSTRAINT ticket_flights_amount_verif CHECK(amount >= 0),
	CONSTRAINT ticket_flights_fare_conditional_verif CHECK(fare_conditions IN ('Economy', 'Comfort', 'Business'))
);

CREATE TABLE IF NOT EXISTS boarding_passes(
	ticket_no		char(13),
	flight_id		integer,
	boarding_no		integer,
	seat_no			varchar(4),
	CONSTRAINT passes_identificator PRIMARY KEY (ticket_no, flight_id),
	CONSTRAINT uc_boarding_no_verif UNIQUE(flight_id, boarding_no),
	CONSTRAINT uc_seat_no_verif UNIQUE(flight_id, seat_no),
	FOREIGN KEY (ticket_no, flight_id) REFERENCES ticket_flights(ticket_no, flight_id)
);

CREATE TABLE IF NOT EXISTS bookings(
	book_ref		char(6) CONSTRAINT bookings_key PRIMARY KEY,
	book_date		timestamptz NOT NULL,
	total_amount		numeric(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS flights(
	flight_id		serial CONSTRAINT flights_key PRIMARY KEY,
	flight_no		char(6) NOT NULL,
	scheduled_departure	timestamptz,
	scheduled_arrival	timestamptz NOT NULL,
	departure_airport	char(3) NOT NULL REFERENCES airports_data(airport_code),
	arrival_airport		char(3) NOT NULL REFERENCES airports_data(airport_code),
	status			varchar(20) NOT NULL,
	aircraft_code		char(3) NOT NULL REFERENCES aircrafts_data(aircraft_code),
	actual_departure	timestamptz NOT NULL,
	actual_arrival		timestamptz NOT NULL,
	CONSTRAINT uc_flights_schedule_verif UNIQUE(flight_id, scheduled_departure),
	CONSTRAINT planed_schedule_verif CHECK(scheduled_arrival > scheduled_departure),
	CONSTRAINT actual_schedule_verif CHECK((actual_arrival IS NULL) OR  ((actual_departure IS NOT NULL AND actual_arrival IS NOT NULL) AND (actual_arrival > actual_departure))),
	CONSTRAINT flights_status_verif CHECK(status IN ('On Time', 'Delayed', 'Departed', 'Arrived', 'Scheduled', 'Cancelled'))
);
										   
CREATE TABLE IF NOT EXISTS seats(
	aircraft_code		char(3) REFERENCES aircrafts_data(aircraft_code) ON DELETE CASCADE,
	seat_no			varchar(4),
	fare_conditions		varchar(10),
	CONSTRAINT seats_key PRIMARY KEY(aircraft_code, seat_no),
	CONSTRAINT seats_fare_conditional_verif CHECK(fare_conditions IN ('Economy', 'Comfort', 'Business'))
);

CREATE TABLE IF NOT EXISTS ticket_flights(
	ticket_no		char(13) REFERENCES tickets(ticket_no),
	flight_id		integer REFERENCES flights(flight_id),
	fare_conditions		varchar(10),
	amount			numeric(10,2),
	CONSTRAINT ticket_flights_key PRIMARY KEY(ticket_no, flight_id),
	CONSTRAINT ticket_flights_amount_verif CHECK(amount >= 0),
	CONSTRAINT ticket_flights_fare_conditional_verif CHECK(fare_conditions IN ('Economy', 'Comfort', 'Business'))
);

CREATE TABLE IF NOT EXISTS tickets(
	ticket_no 		char(13) CONSTRAINT tickets_key PRIMARY KEY,
	book_ref		char(6) REFERENCES bookings(book_ref),
	passenger_id		varchar(20),
	passenger_name		text,
	contact_data		jsonb
);
															
CREATE OR REPLACE VIEW flights_v AS
	SELECT
		ml.flight_id,
    		ml.flight_no,
    		ml.scheduled_departure,
		ml.scheduled_departure AT TIME ZONE dep.timezone scheduled_departure_local,
		ml.scheduled_arrival,
		ml.scheduled_arrival AT TIME ZONE arr.timezone scheduled_arrival_local,
		ml.scheduled_arrival - ml.scheduled_departure AS scheduled_duration,
		ml.departure_airport,
		dep.airport_name departure_airport_name,
		dep.city departure_city,
		ml.arrival_airport,
		arr.airport_name arrival_airport_name,
		arr.city arrival_city,
		ml.status,
		ml.aircraft_code,
		ml.actual_departure,
		ml.actual_departure AT TIME ZONE dep.timezone actual_departure_local,
		ml.actual_arrival,
		ml.actual_arrival AT TIME ZONE arr.timezone actual_arrival_local,
		ml.actual_arrival - ml.actual_departure actual_duration
	FROM
		flights ml 
			LEFT JOIN airports_data dep
				ON ml.departure_airport = dep.airport_code
			LEFT JOIN airports_data arr 
				ON ml.arrival_airport = arr.airport_code;
														   
CREATE OR REPLACE VIEW routes AS
	SELECT
		ml.flight_no,
		ml.departure_airport,
		ml.departure_airport_name,
		ml.departure_city,
		ml.arrival_airport,
		ml.arrival_airport_name,
		ml.arrival_city,
		ml.aircraft_code,
		ml.scheduled_duration duration,
		array_agg(array[cast(extract(dow FROM ml.scheduled_departure) as integer)]) days_of_week
	FROM
		flights_v ml
	GROUP BY 
		ml.flight_no,
		ml.departure_airport,
		ml.departure_airport_name,
		ml.departure_city,
		ml.arrival_airport,
		ml.arrival_airport_name,
		ml.arrival_city,
		ml.aircraft_code,
		ml.scheduled_duration;
