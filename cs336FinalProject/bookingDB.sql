DROP DATABASE IF EXISTS railwaybooking;
CREATE DATABASE railwaybooking;
USE railwaybooking;

CREATE TABLE customers(
user_id int AUTO_INCREMENT NOT NULL primary key,
username varchar(50) NOT NULL,
password varchar(50) NOT NULL,
firstname varchar(100),
lastname varchar(100),
email varchar(100)
);

CREATE TABLE employees_reps(
ssn varchar(11) primary key,
username varchar(50),
password varchar(50),
firstname varchar(50),
lastname varchar(50)
);

CREATE TABLE employees_admins(
ssn varchar(11) primary key,
username varchar(50),
password varchar(50),
firstname varchar(50),
lastname varchar(50)
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
foreign key (user_id) references customers(user_id),
foreign key (line_name) references transitlines(line_name),
foreign key (dest_stop_id) references stops(stop_id),
foreign key (origin_stop_id) references stops(stop_id)
);

CREATE TABLE questions(
question_id int AUTO_INCREMENT NOT NULL primary key,
question_text TEXT,
response_text TEXT,
user_id int,
rep_ssn varchar(11),
foreign key (user_id) references users(user_id),
foreign key (rep_ssn) references employees_reps(ssn)
);

INSERT INTO customers(username, password, firstname, lastname, email)
VALUES ("testuser", "testpass", "John", "Doe", "JohnDoe@example.com");


