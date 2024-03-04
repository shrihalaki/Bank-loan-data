--Task 1

--1.New database creation
create database Loans;


alter table [dbo].[Loan_Records_Data] add constraint  fk_customer foreign key(customer_id) references customer_data(customer_id);
alter table [dbo].[Loan_Records_Data] add constraint  fk_banker foreign key(banker_id) references banker_data(banker_id);
alter table [dbo].[Loan_Records_Data] add constraint  fk_loan foreign key(loan_id) references home_loan_data(loan_id);


--2.Query to view all tables
select * from [dbo].[Banker_Data];
select * from [dbo].[Customer_Data];
select * from [dbo].[Home_Loan_Data];
select * from [dbo].[Loan_Records_Data];

--3.Query to view databases
select name from sys.databases; 

--4.Query to view tables from loan database
select table_name from loans.information_schema.tables;
--or
select name from sys.tables

--5.Query to print 5 records in all tables
select top 5 * from [dbo].[Banker_Data] where gender='Female';
select top 10 * from [dbo].[Customer_Data] where first_name  like '%C'

select top 5 * from [dbo].[Home_Loan_Data];
select top 5 * from [dbo].[Loan_Records_Data];

select C.first_name from Customer_Data C inner join Loan_Records_Data L on C.customer_id=L.customer_id
inner join Banker_Data B on L.banker_id=B.banker_id where B.first_name='Stearn'

select C.first_name from Customer_Data C left join Loan_Records_Data L on C.customer_id=L.customer_id
left join Banker_Data B on L.banker_id=B.banker_id where B.first_name='Stearn'

select DATEDIFF(day,dob,customer_since)/365.25 as age from  Customer_Data

select * from Customer_Data where first_name like 'E%';

--Task 2
--1.

select top 2 L.banker_id,B.first_name,B.last_name,COUNT(L.transaction_date) as loan_records 
from [dbo].[Loan_Records_Data] L inner join  [dbo].[Banker_Data] B on L.banker_id=B.banker_id
group by  L.banker_id,B.first_name,B.last_name order by loan_records desc

--2.

select round(avg(DATEDIFF(DAY,dob,date_joined)/365.25),1) as avg_age_male from [dbo].[Banker_Data] where gender='Male';

--3.

select city,AVG(property_value) as high_value_properties from [dbo].[Home_Loan_Data]
 group by city 
 having  AVG(property_value)>3000000

--4.
 
 select customer_id,first_name,last_name,email from Customer_Data where email like '%amazon%';

--5

select property_type,MAX(property_value)as max_property_value 
from [dbo].[Home_Loan_Data] group by property_type order by max_property_value desc;

--6

select count(distinct city) as loan_issued_cities from [dbo].[Home_Loan_Data];

--7

select COUNT(loan_id) as count_loans from [dbo].[Home_Loan_Data] where city='San Francisco';

--8

select avg(DATEDIFF(YEAR,C.dob,L.transaction_date)) as avg_female_age from [dbo].[Loan_Records_Data] L
inner join Customer_Data C 
on L.customer_id=C.customer_id inner join home_loan_data H 
on L.loan_id=H.loan_id
where C.gender='Female'  and H.property_type='Townhome' and H.joint_loan='No';


--9

select top 3 city,avg(loan_percent) as avg_loan from [dbo].[Home_Loan_Data]
group by city order by city desc,avg_loan asc;
--10
 
select AVG(loan_term) as Avg_loanterm from Home_Loan_Data where property_type 
not in ('semi-detached','townhome') and city in ('Sparks','Biloxi','Waco', 'Las Vegas','Lansing')

--Task 3

--1

create view dallas_townhomes_gte_1m as
select * from Home_Loan_Data 
where property_type='Townhome' and city='Dallas' and (property_value*loan_percent)/100>1000000

--2

select count(distinct B.banker_id) as count_of_bank_employee from [dbo].[Loan_Records_Data] L
inner join  [dbo].[Banker_Data] B on L.banker_id=B.banker_id
inner join Home_Loan_Data H on L.loan_id=H.loan_id 
where (H.property_value*H.loan_percent)/100>(select avg((property_value*loan_percent)/100) from Home_Loan_Data)

--3


select C.customer_id,concat(C.first_name,' ',C.last_name) as full_name from Customer_Data C inner join Loan_Records_Data L
on L.customer_id=C.customer_id inner join Banker_Data B
on L.banker_id=B.banker_id where datediff(DAY,B.dob,'2022-08-01')/365.25<30; 

--4



create procedure city_and_above_loan_amt
@city_name varchar(50) ,
@loan_amt_cutoff float as
begin
select C.customer_id,C.first_name,C.last_name,C.email,C.gender,C.phone,C.dob,C.customer_since,C.nationality,
H.loan_id,H.property_type,H.property_value,H.city,H.property_value,H.loan_term,H.postal_code,H.joint_loan
from Customer_Data C inner join Loan_Records_Data L
on L.customer_id=C.customer_id inner join Home_Loan_Data H
on L.loan_id=H.loan_id where H.city=@city_name and (H.property_value*H.loan_percent/100)>@loan_amt_cutoff
end

exec city_and_above_loan_amt @city_name='San Francisco', @loan_amt_cutoff=1500000
--5

select B.banker_id,concat(B.first_name,' ',B.last_name) as banker_name,round(SUM(H.property_value*H.loan_percent)/100,0) as banker_issued_loan
from [dbo].[Home_Loan_Data] H inner join Loan_Records_Data L
on L.loan_id=H.loan_id inner join Banker_Data B
on L.banker_id=B.banker_id where H.city not in ('Dallas','waco') group by B.banker_id,B.first_name,B.last_name

--6

create procedure recent_joiners as
begin
select banker_id,CONCAT(first_name,' ',last_name) as full_name,date_joined from Banker_Data
where date_joined between '2020-09-01' and '2022-09-01'  ;
end

exec recent_joiners;

--7

select COUNT(*) as chinese_customers from Customer_Data C inner join Loan_Records_Data L 
on C.customer_id=L.customer_id inner join Home_Loan_Data H
on L.loan_id=H.loan_id inner join Banker_Data B
on L.banker_id=B.banker_id where C.nationality='China' and H.joint_loan='Yes' and H.property_value<2100000 and B.gender='Female'

--8

select top 3 L.transaction_date,SUM(H.property_value*H.loan_percent/100) as loan_issued
from Home_Loan_Data H inner join Loan_Records_Data L
on H.loan_id=L.loan_id group by L.transaction_date order by loan_issued desc


--9

select C.customer_id,C.first_name,C.last_name,C.customer_since,
case
when C.customer_since<'2015-01-01' then 'Long'
when C.customer_since between '2015-01-01' and '2018-12-31' then 'Mid'  
when C.customer_since>='2019-01-01' then 'Short'
end as Tenure
from Customer_Data C inner join Loan_Records_Data L
on L.customer_id=C.customer_id inner join Home_Loan_Data H
on L.loan_id=H.loan_id where H.property_value between 1500000 and 1900000 

