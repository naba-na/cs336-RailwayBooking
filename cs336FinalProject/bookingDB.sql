DROP DATABASE IF EXISTS railwaybooking;
CREATE DATABASE railwaybooking;
USE railwaybooking;

CREATE TABLE users(
user_id int AUTO_INCREMENT NOT NULL primary key,
username varchar(50) NOT NULL,
password varchar(50) NOT NULL,
isAdmin bool,
isRep bool
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
arrival_datetime datetime,
departure_datetime datetime,
foreign key (station_id) references stations(station_id),
foreign key (nextstop_id) references stops(stop_id)
    );

CREATE TABLE transitlines(
line_name varchar(100) not null primary key,
dest_stop_id int,
origin_stop_id int,
fare double,
foreign key (dest_stop_id) references stops(stop_id),
foreign key (origin_stop_id) references stops(stop_id)
);

CREATE TABLE trains(
train_id int AUTO_INCREMENT not null primary key,
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

INSERT INTO users(username, password, isAdmin, isRep)
VALUES ("testuser", "testpass", false, false);


