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
line_name varchar(100) not null primary key,
stop_id int,
foreign key (line_name) references transitlines(line_name),
foreign key (stop_id) references stops(stop_id)
);

CREATE TABLE reservations(
res_id int AUTO_INCREMENT not null primary key,
res_date date,
user_id int,
line_name varchar(100),
dest_stop_id int,
origin_stop_id int,
eligible_for_discount bool,
total_fare float,
foreign key (user_id) references users(user_id),
foreign key (line_name) references transitlines(line_name),
foreign key (dest_stop_id) references stops(stop_id),
foreign key (origin_stop_id) references stops(stop_id)
);

INSERT INTO users(username, password, firstname, lastname, email)
VALUES ("testuser", "testpass", "John", "Doe", "JohnDoe@example.com");


