CREATE TABLE rails (
file_number varchar(12) CONSTRAINT railsPK PRIMARY KEY,
digitized_flag boolean,
status varchar(50) NOT NULL,
age_with_custodian INT,
date_received_in_rpc date,
rpc varchar(12) NOT NULL,
location_site varchar(50),
location_room varchar(50),
location_shelf varchar(50),
location_notes varchar(255)
);