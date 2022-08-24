DROP TABLE IF EXISTS flights1;
DROP TABLE IF EXISTS ticket_flights1;

CREATE TABLE IF NOT EXISTS ticket_flights1(
	flight_id integer,
	ticket_no character(3)
);

CREATE TABLE IF NOT EXISTS flights1(
	flight_id integer,
	departure_airport character(3),
	arrival_airport character(3)
);

INSERT INTO ticket_flights1 (flight_id, ticket_no) VALUES(1, 'aaa');
INSERT INTO ticket_flights1 (flight_id, ticket_no) VALUES(2, 'aaa');
INSERT INTO ticket_flights1 (flight_id, ticket_no) VALUES(3, 'bbb');
INSERT INTO ticket_flights1 (flight_id, ticket_no) VALUES(4, 'ccc');
INSERT INTO ticket_flights1 (flight_id, ticket_no) VALUES(5, 'ccc');
INSERT INTO ticket_flights1 (flight_id, ticket_no) VALUES(6, 'ddd');

INSERT INTO flights1 (flight_id, departure_airport, arrival_airport) VALUES(1, 'msk', 'uls');
INSERT INTO flights1 (flight_id, departure_airport, arrival_airport) VALUES(2, 'uls', 'sam');
INSERT INTO flights1 (flight_id, departure_airport, arrival_airport) VALUES(3, 'msk', 'sam');
INSERT INTO flights1 (flight_id, departure_airport, arrival_airport) VALUES(4, 'spb', 'msk');
INSERT INTO flights1 (flight_id, departure_airport, arrival_airport) VALUES(5, 'msk', 'sam');
INSERT INTO flights1 (flight_id, departure_airport, arrival_airport) VALUES(6, 'msk', 'nsk');


SELECT
	depart_ticket.ticket_no
FROM (SELECT
			tf.ticket_no,
			tf.flight_id
		FROM
			ticket_flights1 tf 
		WHERE tf.ticket_no IN (SELECT
									tf.ticket_no
								FROM
									ticket_flights1 tf
								WHERE tf.flight_id IN (SELECT
														f.flight_id
													  FROM
														flights1 f
													  WHERE f.departure_airport = 'msk'))) depart_ticket
WHERE depart_ticket.flight_id IN (SELECT
									f2.flight_id
								  FROM
									flights1 f2
								  WHERE f2.arrival_airport = 'sam')
