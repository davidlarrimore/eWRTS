CREATE TABLE cis2 (
A_Number varchar(12) CONSTRAINT cis2PK PRIMARY KEY,
First_Name varchar(50) NOT NULL,
Last_Name varchar(50) NOT NULL,
Birthdate date,
Country_Of_Origin varchar(150) NOT NULL,
Port_Of_Entry varchar(150) NOT NULL,
Gender varchar(50) NOT NULL
);