--------------------
--Migrate data:
--------------------

delete from customers;

insert into customers
(id, name, contact_person_name, contact_phone_number, contact_email,
 account_number, address1, address2, city, state, zip, active,
 equipment_access, certification_access, vehicle_access)
select id, name, contact_person_name, contact_phone_number, contact_email,
 account_number, address1, address2, city, state, zip, case when active=B'1' then true else false end,
 case when equipment_access=B'1' then true else false end,
 case when certification_access=B'1' then true else false end,
 case when vehicle_access=B'1' then true else false end
from customer
where id not in (2, 3, 4, 6);

update customers set name = 'CertoTrack' where id = 5;

delete from users;

drop index index_users_on_email;

insert into users
(id, first_name, last_name, email, username,
 customer_id, expiration_notification_interval)
select
 id, first_name, last_name, email, username,
 customer_id, notification_interval
from myuser where customer_id not in (2, 3, 4, 6);

update users set admin=true where username='admin';

delete from locations;

insert into locations
(id, name, customer_id)
select id, name, customer_id from location
where customer_id not in (2, 3, 4, 6);

delete from equipment;

insert into equipment
(id, serial_number, last_inspection_date,inspection_interval,
name,expiration_date,comments,created_at,updated_at,
customer_id,location_id,employee_id, created_by)
select myequipment.id,serial_number,last_inspection_date,inspection_interval,
name,expiration_date,notes,myequipment.created_date,myequipment.last_updated_date,
myequipment.customer_id,location_id,trooper_id, myuser.username
from myequipment,
  myuser
where myequipment.customer_id not in (2, 3, 4, 6)
and myequipment.created_by_user_id = myuser.id;


delete from employees;

insert into employees
(id, first_name, last_name, location_id, employee_number,
 customer_id, active, deactivation_date, created_at, updated_at)
select
id, first_name, last_name, location_id, employee_number,
customer_id,
case when active=B'1' then true else false end,
deactivation_date, created_date, edited_date
from trooper
where customer_id not in (2, 3, 4, 6);

update certification_type set customer_id = 5 where id = 20;

delete from certification_types;

insert into certification_types
(id, name, interval, units_required, customer_id,
created_at,updated_at, created_by)
select id, name, certification_interval, units_required, customer_id,
created_date, edited_date, created_by_user_id
from certification_type
where customer_id not in (2, 3, 4, 6);

delete from certifications;

insert into certifications
(id, certification_type_id, employee_id, customer_id,
 active, created_at, updated_at, active_certification_period_id, created_by)
select id, certification_type_id, trooper_id,
customer_id,
case when active=B'1' then true else false end,
created_date, edited_date, active_certification_period_id, created_by_user_id
from certification
where customer_id not in (2, 3, 4, 6);

delete from certification_periods;

insert into certification_periods
(id, trainer, start_date, end_date, units_achieved,
comments, certification_id)
select cp.id, cp.trainer, cp.start_date, cp.end_date, cp.units_achieved,
cp.notes, ccp.certification_certification_periods_id
from
certification_period cp,
certification_certification_period ccp,
certification c
where ccp.certification_period_id = cp.id
and c.id = ccp.certification_certification_periods_id
and c.customer_id not in (2, 3, 4, 6);

delete from service_types;

insert into service_types
(id, name, expiration_type, interval_date, interval_mileage,
 customer_id, created_at, updated_at, created_by)
select
 id, name, expiration_type, interval_date, interval_mileage,
 customer_id, created_date, edited_date, created_by_user_id
 expiration_type
from service_type
where customer_id not in (2, 3, 4, 6);

delete from vehicles;

insert into vehicles
(id, vehicle_number, vin, make, vehicle_model, license_plate, year,
 mileage, location_id, customer_id, created_at, updated_at, created_by)
select
id, car_number, vin, make, model, license_plate,
year, mileage, location_id, customer_id, created_date,
edited_date, created_by_user_id
from vehicle
where customer_id not in (2, 3, 4, 6);

delete from services;

--Skip services, but if need, must create service_periods!
-- insert into services
--(id, service_type_id, vehicle_id, customer_id, active_service_period_id,
-- created_at, updated_at, created_by  )
--select
--id, service_type_id, vehicle_id, customer_id,
--from services
--where customer_id not in (2, 3, 4, 6);

 alter sequence users_id_seq restart with 100;
 alter sequence locations_id_seq restart with 500;
 alter sequence certifications_id_seq restart with 6000;
 alter sequence employees_id_seq restart with 1500;
 alter sequence equipment_id_seq restart with 3000;
 alter sequence customers_id_seq restart with 100;
 alter sequence certification_types_id_seq restart with 1000;
 alter sequence certification_periods_id_seq restart with 10000;
 alter sequence vehicles_id_seq restart with 100;
 alter sequence service_types_id_seq restart with 100;

--------------------
--Cleanup old tables
--------------------

DROP TABLE "DATABASECHANGELOG";
DROP TABLE "DATABASECHANGELOG--LOCK";
DROP TABLE "acl_class";
DROP TABLE "certification";
DROP TABLE "certification_certification_period";
DROP TABLE "certification_period";
DROP TABLE "certification_type";
DROP TABLE "contact";
DROP TABLE "county";
DROP TABLE "customer";
DROP TABLE "myequipment";
DROP TABLE "location";
DROP TABLE "password_history";
DROP TABLE "position";
DROP TABLE "road";
DROP TABLE "role";
DROP TABLE "service";
DROP TABLE "service_type";
DROP TABLE "system_time";
DROP TABLE "test_report";
DROP TABLE "trooper";
DROP TABLE "myuser";
DROP TABLE "user_role";
DROP TABLE "vehicle";