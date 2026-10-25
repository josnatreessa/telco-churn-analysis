CREATE DATABASE telco_churn;
USE telco_churn;
CREATE TABLE customer_raw(customer_id varchar(20), gender varchar(10),
SeniorCitizen tinyint, Partner varchar(5),Dependents varchar(5),tenure
int,PhoneService varchar(5), MultipleLines varchar(20), InternetService
varchar(20),OnlineSecurity varchar(25),OnlineBackup varchar(25),DeviceProtection
varchar(25), TechSupport varchar(25),StreamingTV varchar(25),StreamingMovies
varchar(25),Contract varchar (20),PaperlessBilling varchar(5),PaymentMethod
varchar(30),MonthlyCharges decimal(8,2),TotalCharges varchar(15),Churn varchar(5));
Rename table customer_raw to customers_raw;
Alter TABLE customers_raw rename column customer_id to customer_ID;
sELECT * FROM customers_raw;
select count(*) from customers_raw;
select count(*) as total_rows, count(distinct customer_id) as unique_customers from customers_raw;
select tenure,customer_id,MonthlyCharges,TotalCharges from customers_raw where trim(TotalCharges)='';
select customer_id,tenure,total_charges from customers_raw where tenure=0;
set sql_safe_updates=0;
update customers_raw set TotalCharges ='0' where trim(TotalCharges)='';
Alter table customers_raw rename column SeniorCitizen to senior_citizen,
rename column Partner to partner,
rename column Dependents to dependents,
rename column  PhoneService to phone_service,
rename column  MultipleLines to multiple_lines,
rename column  InternetService to internet_sevice,
rename column  OnlineSecurity to online_security,
rename column  OnlineBackup to online_backup,
rename column  DeviceProtection to device_protection,
rename column  TechSupport to tech_support,
rename column  StreamingTV to streaming_tv,
rename column  StreamingMovies to streaming_movies,
rename column  Contract to contract,
rename column  PaperlessBilling to paperless_billing,
rename column  PaymentMethod to payment_method,
rename column  MonthlyCharges to monthly_charges,
rename column  TotalCharges to total_charges,
rename column  Churn to churn;
select count(*) as null_tenure from customers_raw where tenure is null;
Select distinct contract from customers_raw;
Alter table customers_raw rename column internet_sevice to internet_service;
Select distinct internet_service from customers_raw;
Select distinct payment_method from customers_raw;
Select distinct churn from customers_raw;
Select max(monthly_charges),min(monthly_charges),max(tenure),min(tenure) from customers_raw;
CREATE TABLE customers AS
SELECT
    customer_id,
    gender,
    CASE WHEN senior_citizen = 1 THEN 'Yes' ELSE 'No' END AS senior_citizen,
    partner, dependents, tenure, phone_service, multiple_lines,
    internet_service, online_security, online_backup, device_protection,
    tech_support, streaming_tv, streaming_movies, contract,
    paperless_billing, payment_method, monthly_charges,
    CAST(total_charges AS DECIMAL(10,2)) AS total_charges,
    churn,
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49+ months'
    END AS tenure_group
FROM customers_raw;
select count(*) from customers;
describe customers;
Select * from customers limit 10;
select monthly_charges from customers order by monthly_charges desc;
select total_charges from customers order by total_charges desc;
describe customers;
select * from customers;
SET SQL_SAFE_UPDATES=0;
update customers 
set multiple_lines='No'
where multiple_lines='No phone servive';
SET SQL_SAFE_UPDATES=1;
select * from customers;
Select count(*) from customers where multiple_lines='No phone service';
update customers 
set multiple_lines='No'
where multiple_lines='No phone servive';
SET SQL_SAFE_UPDATES=0;
Select @@SQL_SAFE_UPDATES;
UPDATE customers
SET multiple_lines ='No'
WHERE multiple_lines='No phone service';
Select multiple_lines,count(multiple_lines) as total from customers group by multiple_lines;
 Select count(*) as total_customers,
 sum(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 
 END) AS churned_customers,
 ROUND(SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END)*100.0
 / count(*),2) as churn_rate from customers;
 ----#Overall churn rate = 26.54%----
Select * from customers;
Select contract, count(*) as total_customers,
sum(CASE WHEN churn='YES' then 1 else 0 end) as churned_customers,
round(sum(CASE WHEN churn='Yes' then 1 else 0 end)*100.0/
count(*),2) as churn_rate from customers group by contract
 order by churn_rate DESC;
 ----# Churn by contract type
 ----# Insight: Month-to-Month customers churn the most (42.71%), two-year the least (2.83%).----
 Select internet_service, count(*) as total_customers,
 sum(CASE WHEN churn='Yes' then 1 else 0 end) as churned_customers,
 round(sum(CASE WHEN churn='Yes' then 1 else 0 end)*100.0/
 count(*),2) as churn_rate from customers group by internet_service
  order by churn_rate DESC;
---- #Churn by internet service
---- #Insight: Fiber optic churns the most (41.89%), more than double DSL (18.96%).
----# customers with no internet churn the least (7.40%).----
SELECT payment_method, count(*) as total_customers,
sum(CASE WHEN churn='Yes' then 1 else 0 end) as churned_customers,
 round(sum(CASE WHEN churn='Yes' then 1 else 0 end)*100.0/
 count(*),2) as churn_rate from customers group by payment_method
  order by churn_rate DESC;
----#Churn by payment method
----# Insight: Electronic check customers churn the most (45.29%), about 3x the rate of
----# credit card automatic (15.24%). Both automatic payment methods have the lowest churn.----
Select tenure_group, count(*) as total_customers,
sum(CASE WHEN churn='Yes' then 1 else 0 end) as churned_customers,
 round(sum(CASE WHEN churn='Yes' then 1 else 0 end)*100.0/
 count(*),2) as churn_rate from customers group by tenure_group
  order by churn_rate DESC;
----# Churn by tenure group
----# Insight: Churn falls steadily with tenure, from 47.44% in the first year to 9.51%
----# for customers with 49+ months. The first 12 months are the highest-risk period.----
Select churn, count(*) as total_customers,
round(avg(monthly_charges),2) as avg_monthly_charges
from customers group by churn;
----# Average monthly charges: churned vs retained
----#Insight: Churned customers pay more per month ($74.44) than retained customers ($61.27),
----# suggesting higher-priced plans, such as fiber optic, may be driving churn.----
Select round(sum(CASE WHEN churn='Yes' then monthly_charges
 else 0 end),2) as monthly_revenue_lost,
 round(sum(CASE WHEN churn='Yes' then monthly_charges else
 0 end)*100.0 / sum(monthly_charges), 2) as 
 pct_od_total_revenue from customers;
----# Monthly revenue lost to churn
----# Insight: Churned customers represent about 30.5% of total monthly revenue (~139K/month),
----#so churn is a major revenue problem, not just a customer-count problem.----
SELECT tech_support,
COUNT(*) AS total_customers,
ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customers
WHERE internet_service <> 'No'
GROUP BY tech_support;
----# Churn by tech support (customers with internet only)
----# Insight: Customers without tech support churn at 41.64%, versus 15.17% for those with it.
----#Tech support may help retain customers.----
SELECT online_security,
COUNT(*) AS total_customers,
ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customers
WHERE internet_service <> 'No'
GROUP BY online_security;
----# Churn by online security (customers with internet only)
----# Insight: Customers without online security churn at 41.77%, versus 14.61% for those with it.
----# Like tech support, security add-ons are linked to lower churn.----
SELECT COUNT(*) AS customers,
ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customers
WHERE contract = 'Month-to-month'
AND internet_service = 'Fiber optic'
AND payment_method = 'Electronic check';
----# Insight: Month-to-month + fiber optic + electronic check customers churn at 60.37%,
----# more than double the overall rate (26.54%). This is the highest-risk segment.----



       