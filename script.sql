set session "postgres.lang" = 'eng';

DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS ticket_flights;
DROP TABLE IF EXISTS seats;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS boarding_passes;
DROP TABLE IF EXISTS airports_data CASCADE;
DROP TABLE IF EXISTS aircrafts_data CASCADE;


CREATE TABLE IF NOT EXISTS aircrafts_data(
    aircraft_code 	char(3) CONSTRAINT aircraft_key PRIMARY KEY,
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
	airport_code	char(3) CONSTRAINT airport_key PRIMARY KEY,
	airport_name	jsonb NOT NULL,
	city			jsonb NOT NULL,
	coordinates		point NOT NULL,
	timezone		text NOT NULL
);

CREATE VIEW airports AS
	SELECT 
		ml.airport_code,
		ml.airport_name ->> lang() AS airport_name,
		ml.city ->> lang() AS city,
		ml.coordinates,
		ml.timezone
	FROM 
		airports_data ml;
		
CREATE TABLE IF NOT EXISTS boarding_passes(
	ticket_no		char(13),
	flight_id		integer,
	boarding_no		integer,
	seat_no			varchar(4),
	CONSTRAINT passes_identificator PRIMARY KEY (ticket_no, flight_id),
	CONSTRAINT uc_boarding_no_verif UNIQUE(flight_id, boarding_no),
	CONSTRAINT uc_seat_no_verif UNIQUE(flight_id, seat_no)
);

CREATE TABLE IF NOT EXISTS bookings(
	book_ref		char(6) CONSTRAINT bookings_key PRIMARY KEY,
	book_date		timestamptz NOT NULL,
	total_amount	numeric(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS flights(
	flight_id			serial CONSTRAINT flights_key PRIMARY KEY,
	flight_no			char(6) NOT NULL,
	scheduled_departure	timestamptz,
	scheduled_arrival	timestamptz NOT NULL,
	departure_airport	char(3) NOT NULL,
	arrival_airport		char(3) NOT NULL,
	status				varchar(20) NOT NULL,
	aircraft_code		char(3) NOT NULL,
	actual_departure	timestamptz NOT NULL,
	actual_arrival		timestamptz NOT NULL,
	CONSTRAINT uc_flights_schedule_verif UNIQUE(flight_id, scheduled_departure),
	CONSTRAINT planed_schedule_verif CHECK (scheduled_arrival > scheduled_departure),
	CONSTRAINT actual_schedule_verif CHECK ((actual_arrival IS NULL) OR  ((actual_departure IS NOT NULL AND actual_arrival IS NOT NULL) AND (actual_arrival > actual_departure))),
	CONSTRAINT flights_status_verif CHECK (status IN ('On Time', 'Delayed', 'Departed', 'Arrived', 'Scheduled', 'Cancelled'))
);
										   
CREATE TABLE IF NOT EXISTS seats(
	aircraft_code	char(3),
	seat_no			varchar(4),
	fare_conditions	varchar(10),
	CONSTRAINTS seats_key PRIMARY KEY(aircraft_code, seat_no),
	CONSTRAINTS seats_fare_conditional_verif CHECK (fare_conditions IN ('Economy', 'Comfort', 'Business'))
);

CREATE TABLE IF NOT EXISTS ticket_flights(
	ticket_no		char(13),
	flight_id		integer,
	fare_conditions	varchar(10),
	amount			numeric(10,2),
	CONSTRAINTS ticket_flights_key PRIMARY KEY(ticket_no, flight_id),
	CONSTRAINTS ticket_flights_amount_verif CHECK (amount >= 0),
	CONSTRAINTS ticket_flights_fare_conditional_verifCHECK (fare_conditions IN ('Economy', 'Comfort', 'Business'))
):

CREATE TABLE IF NOT EXISTS tickets(
	ticket_no 		char(13) CONSTRAINTS tickets_key PRIMARY KEY,
	book_ref		char(6),
	passenger_id	varchar(20),
	passenger_name	text,
	contact_data	jsonb
);
