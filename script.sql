CREATE TYPE statuses AS ENUM ('expected', 'prepared', 'arrived');
CREATE TABLE airports(airport_code varchar(4) PRIMARY KEY, airport_name varchar(20) NOT NULL, sity varchar(20) NOT NULL, coordinates integer NOT NULL, timezone timestamp NOT NULL);
CREATE TABLE aircrafts(aircraft_code varchar(4) PRIMARY KEY, model varchar(6) NOT NULL, range smallint NOT NULL);
CREATE TABLE bookings(book_ref SERIAL PRIMARY KEY, book_date TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP, total_amount numeric(10, 2) DEFAULT 0);
CREATE TABLE tickets(tickets_no SERIAL PRIMARY KEY, book_ref integer REFERENCES bookings, passenger_id integer NOT NULL, passenger_name varchar(100) NOT NULL, contact_data varchar(100));
CREATE TABLE flights(flight_id SERIAL PRIMARY KEY, fligh_no integer, scheduled_departure TIMESTAMP(0), scheduled_arrival TIMESTAMP(0), departure_airport varchar(4) REFERENCES airports, arrival_airport varchar(4) REFERENCES airports, status statuses NOT NULL, aircraft_code varchar(4) REFERENCES aircrafts, actual_departure varchar(20), actual_arrival varchar(20));
CREATE TABLE ticket_flights(tickets_no integer REFERENCES tickets, flight_id integer REFERENCES flights, fare_conditions varchar(10) NOT NULL, amount numeric(10, 2) DEFAULT 0, PRIMARY KEY (tickets_no, flight_id));
CREATE TABLE boarding_passes(tickets_no integer, flight_id integer, boarding_no smallint, seat_no smallint CHECK (seat_no < 1000), PRIMARY KEY(tickets_no, flight_id), FOREIGN KEY (tickets_no, flight_id) REFERENCES ticket_flights (tickets_no, flight_id));
CREATE TABLE seats(aircraft_code varchar(4) REFERENCES aircrafts, seat_no smallint CHECK(seat_no < 1000), fare_conditions varchar(10) NOT NULL, PRIMARY KEY(aircraft_code, seat_no));
