DROP DATABASE IF EXISTS railwaybooking;
CREATE DATABASE railwaybooking;
USE railwaybooking;

CREATE TABLE users(
user_id int AUTO_INCREMENT NOT NULL primary key,
username varchar(50) NOT NULL,
password varchar(50) NOT NULL,
firstname varchar(100) NOT NULL,
lastname varchar(100) NOT NULL,
email varchar(100)
);

CREATE TABLE employees(
user_id int primary key,
ssn varchar(11) NOT NULL,
acc_type ENUM('rep', 'admin') NOT NULL,
foreign key (user_id) references users(user_id)
);

CREATE TABLE customers(
  user_id int PRIMARY KEY,
  phone varchar(20),
  address varchar(255),
  city varchar(100),
  state varchar(50),
  zip varchar(15),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE stations(
station_id int AUTO_INCREMENT not null primary key,
name varchar(100),
city varchar(100),
state varchar(50)
);

CREATE TABLE stops(
stop_id int AUTO_INCREMENT not null primary key,
station_id int,
nextstop_id int,
arrival_time time,
departure_time time,
foreign key (station_id) references stations(station_id),
foreign key (nextstop_id) references stops(stop_id)
);

CREATE TABLE transitlines(
line_name varchar(100) not null primary key,
dest_stop_id int,
origin_stop_id int,
fare double,
fareChild double,
fareSenior double,
fareDisabled double,
foreign key (dest_stop_id) references stops(stop_id),
foreign key (origin_stop_id) references stops(stop_id)
);

CREATE TABLE trains(
train_id int not null primary key,
-- train_id must be a unique 4 digit number
line_name varchar(100),
foreign key (line_name) references transitlines(line_name)
);

CREATE TABLE TransitLines_Contains_Stops(
line_name varchar(100) not null,
stop_id int,
primary key(line_name, stop_id),
foreign key (line_name) references transitlines(line_name),
foreign key (stop_id) references stops(stop_id)
);

CREATE TABLE reservations(
res_id int AUTO_INCREMENT not null primary key,
creationDate date,
user_id int,
res_date date,
res_time time,
dest_arrival_time time,
line_name varchar(100),
origin_station_name varchar(50),
origin_stop_id int,
dest_station_name varchar(50),
dest_stop_id int,
total_fare float,
isActive bool,
foreign key (user_id) references users(user_id),
foreign key (line_name) references transitlines(line_name),
foreign key (dest_stop_id) references stops(stop_id),
foreign key (origin_stop_id) references stops(stop_id)
);

CREATE TABLE customer_questions( 
question_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT, 
question_text TEXT NOT NULL,
answer_text TEXT, 
status ENUM('pending', 'answered') DEFAULT 'pending', 
 rep_username VARCHAR(50), 
created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
 answered_date TIMESTAMP NULL,
FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users(user_id, username, password, firstname, lastname, email) VALUES
(2, 'alice', 'alicepass', 'Alice', 'Smith', 'alice@example.com'),
(3, 'bob', 'bobpass', 'Bob', 'Brown', 'bob@example.com'),
(4, 'charlie', 'charliepass', 'Charlie', 'Johnson', 'charlie@example.com'),
(5, 'diana', 'dianapass', 'Diana', 'Prince', 'diana@example.com'),
(6, 'edward', 'edwardpass', 'Edward', 'Norton', 'edward@example.com'),
(7, 'fiona', 'fionapass', 'Fiona', 'Apple', 'fiona@example.com'),
(8, 'george', 'georgepass', 'George', 'Clooney', 'george@example.com'),
(9, 'hannah', 'hannahpass', 'Hannah', 'Montana', 'hannah@example.com'),
(10, 'ian', 'ianpass', 'Ian', 'McKellen', 'ian@example.com'),
(11, 'cust_jane', 'janePass', 'Jane', 'Doe', 'jane.doe@example.com'),
(12, 'cust_mike', 'mikePass', 'Mike', 'Brown', 'mike.brown@example.com'),
(13, 'cust_sara', 'saraPass', 'Sara', 'Smith', 'sara.smith@example.com');


INSERT INTO employees(user_id, ssn, acc_type) VALUES
(2, '123-45-6789', 'admin'),
(3, '234-56-7890', 'rep'),
(4, '345-67-8901', 'rep'),
(5, '456-12-3456', 'rep'),
(6, '567-23-4567', 'admin'),
(7, '678-34-5678', 'rep'),
(8, '789-45-6789', 'rep'),
(9, '890-56-7890', 'admin'),
(10, '901-67-8901', 'rep');

INSERT INTO customers (user_id, phone, address, city, state, zip) VALUES
(11, '555-1010', '100 Main St', 'Springfield', 'IL', '62701'),
(12, '555-2020', '200 Oak Ave', 'Madison', 'WI', '53703'),
(13, '555-3030', '300 Pine Rd', 'Austin', 'TX', '78701');

INSERT INTO stations (name, city, state) VALUES
('Central Station', 'New York', 'NY'),
('Union Station', 'Chicago', 'IL'),
('Grand Station', 'Los Angeles', 'CA'),
('Maple Station', 'Denver', 'CO'),
('Pine Station', 'Seattle', 'WA');

INSERT INTO stops (station_id, nextstop_id, arrival_time, departure_time) VALUES
(1, NULL, '08:00:00', '08:15:00'),
(2, NULL, '10:30:00', '10:45:00'),
(3, NULL, '13:00:00', '13:15:00'),
(4, NULL, '16:30:00', '16:45:00'),
(5, NULL, '19:00:00', '19:15:00'),
(2, NULL, '15:00:00', '15:15:00'),
(3, 6, '14:30:00', '14:45:00');

UPDATE stops SET nextstop_id = 2 WHERE stop_id = 1;
UPDATE stops SET nextstop_id = 3 WHERE stop_id = 2;
UPDATE stops SET nextstop_id = 4 WHERE stop_id = 3;
UPDATE stops SET nextstop_id = 5 WHERE stop_id = 4;

INSERT INTO transitlines (line_name, dest_stop_id, origin_stop_id, fare, fareChild, fareSenior, fareDisabled) VALUES
('NY-CA Express', 5, 1, 120.00, 60.00, 90.00, 90.00),
('Midwest Connector', 3, 2, 80.00, 40.00, 60.00, 60.00);

INSERT INTO trains (train_id, line_name) VALUES
(1001, 'NY-CA Express'),
(1002, 'Midwest Connector');

INSERT INTO TransitLines_Contains_Stops (line_name, stop_id) VALUES
('NY-CA Express', 1),
('NY-CA Express', 2),
('NY-CA Express', 3),
('NY-CA Express', 4),
('NY-CA Express', 5),
('Midwest Connector', 2),
('Midwest Connector', 3),
('Midwest Connector', 6),
('Midwest Connector', 7);