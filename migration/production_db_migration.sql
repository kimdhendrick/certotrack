--------------------
--Migrate data:
--------------------
update certification_type set created_by_user_id = 1 where created_by_user_id not in (select id from myuser);
update certification set created_by_user_id = 1 where created_by_user_id not in (select id from myuser);
update trooper set created_by_user_id = 1 where created_by_user_id not in (select id from myuser);
update myequipment set created_by_user_id = 1 where created_by_user_id not in (select id from myuser);
update service_type set created_by_user_id = 1 where created_by_user_id not in (select id from myuser);
update vehicle set created_by_user_id = 1 where created_by_user_id not in (select id from myuser);

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
(id, name, customer_id, created_by)
select l.id, l.name, l.customer_id, 'admin'
from location l
where l.customer_id not in (2, 3, 4, 6);

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
 customer_id, active, deactivation_date, created_at, updated_at, created_by)
select
t.id, t.first_name, t.last_name, t.location_id, employee_number,
t.customer_id,
case when t.active=B'1' then true else false end,
deactivation_date, t.created_date, t.edited_date, u.username
from trooper t, myuser u
where t.customer_id not in (2, 3, 4, 6)
and t.created_by_user_id = u.id;

update certification_type set customer_id = 5 where id = 20;

delete from certification_types;

insert into certification_types
(id, name, interval, units_required, customer_id,
created_at,updated_at, created_by)
select ct.id, ct.name, ct.certification_interval, units_required, ct.customer_id,
ct.created_date, ct.edited_date, u.username
from certification_type ct, myuser u
where ct.customer_id not in (2, 3, 4, 6)
and ct.created_by_user_id = u.id;

delete from certifications;

insert into certifications
(id, certification_type_id, employee_id, customer_id,
 active, created_at, updated_at, active_certification_period_id, created_by)
select c.id, certification_type_id, trooper_id,
c.customer_id,
case when c.active=B'1' then true else false end,
c.created_date, c.edited_date, active_certification_period_id, u.username
from certification c, myuser u
where c.customer_id not in (2, 3, 4, 6)
and c.created_by_user_id = u.id;

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
 st.id, st.name, expiration_type, interval_date, interval_mileage,
 st.customer_id, st.created_date, st.edited_date, u.username
 expiration_type
from service_type st, myuser u
where st.customer_id not in (2, 3, 4, 6)
and st.created_by_user_id = u.id;

delete from vehicles;

insert into vehicles
(id, vehicle_number, vin, make, vehicle_model, license_plate, year,
 mileage, location_id, customer_id, created_at, updated_at, created_by)
select
v.id, car_number, vin, make, model, license_plate,
year, mileage, v.location_id, v.customer_id, v.created_date,
v.edited_date, u.username
from vehicle v, myuser u
where v.customer_id not in (2, 3, 4, 6)
and v.created_by_user_id = u.id;

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
DROP TABLE "DATABASECHANGELOGLOCK";
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