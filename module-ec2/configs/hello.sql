create role psqluser with login;

create database hello_postgres with owner psqluser;

\c hello_postgres psqluser;

create table hello(
    tag_name varchar(32),
    tag_value text
);


insert into hello (tag_name, tag_value) values('Hello', 'Postgresql');
insert into hello (tag_name, tag_value) values('Hello1', 'Postgresql1');
insert into hello (tag_name, tag_value) values('Hello2', 'Postgresql2');
insert into hello (tag_name, tag_value) values('Hello3', 'Postgresql3');
insert into hello (tag_name, tag_value) values('Hello4', 'Postgresql4');