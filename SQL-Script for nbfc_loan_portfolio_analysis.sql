create database bank_loan_db;
use bank_loan_db;
create table bank_loans(
id	int primary key,
address_state varchar(10),	
application_type varchar(30),	
emp_length	varchar(20),
emp_title	varchar(100),
grade	varchar(5),
home_ownership	varchar(30),
issue_date	date,
last_credit_pull_date	date,
last_payment_date	date,
loan_status	  varchar(30),
next_payment_date	date,
member_id	int,
purpose	varchar(30),
sub_grade	varchar(10),
term	varchar(30),
verification_status	varchar(30),
annual_income float,	
dti	float,
installment	float,
int_rate	float,
loan_amount	float,
total_acc	int,
total_payment float

);
 select * from bank_loans where trim(emp_title)="";
 desc bank_loans;
 -- truncate bank_loans;
 -- drop table bank_loans;
 
 select * from bank_loans;
 -- ----------------------------------------------------------------------------------------------
-- 1.	Total Loan Applications: 
   
    select count(id) as total_loan_application from bank_loans;
   
-- 1.1	Month-to-Date (MTD) Loan Applications: 
 
     select month(issue_date) as month,count(id) as total_loan_application from bank_loans
       where month(issue_date)=12 and year(issue_date)=2021 group by 1;
       
-- 1.2	Previous-Month-to-Date (PMTD) Loan Applications: 
  
  select month(issue_date) as month,count(id) as total_loan_application from bank_loans
       where month(issue_date)=11 and year(issue_date)=2021 group by 1;

-- 1.3	MoM Change % for total Loan Applications = ((MTD - PMTD) / PMTD) * 100:
    with cte1 as
     (select month(issue_date) as months,count(id) as total_loan_application from bank_loans
       where year(issue_date)=2021 group by 1),
  cte2 as
    (select months, total_loan_application, lead(total_loan_application,1)
        over(order by months desc) as total_loan_application_lead  from cte1)
	
    select round(((total_loan_application-total_loan_application_lead)/total_loan_application_lead)
          *100,2) as MoM_change_percent from cte2 where months=12;
          
      select * from bank_loans;
  -- ----------------------------------------------------------------------------------------------
  -- 2.	Total Funded Amount: 

select sum(loan_amount)as funded_amount from bank_loans;

-- 2.1	MTD Total Funded Amount:

  select month(issue_date)as months, sum(loan_amount)as funded_amount from bank_loans
       where month(issue_date)=12 and year(issue_date)=2021 group by month(issue_date);

-- 2.2	PMTD Total Funded Amount:

  select month(issue_date)as months, sum(loan_amount)as funded_amount from bank_loans
       where month(issue_date)=11 and year(issue_date)=2021 group by month(issue_date);


-- 2.3 MoM Change % for total Funded Amount = ((MTD - PMTD) / PMTD) * 100:

 with cte1 as
     (select month(issue_date) as months,sum(loan_amount) as funded_amount from bank_loans
       where year(issue_date)=2021 group by month(issue_date)),
  cte2 as
    (select months, funded_amount, lead(funded_amount,1)
        over(order by months desc) as funded_amount_lead  from cte1)
	
    select round(((funded_amount-funded_amount_lead)/funded_amount_lead)
          *100,2) as MoM_change_percent from cte2 where months=12;
  
    select * from bank_loans; 
  -- ----------------------------------------------------------------------------------------  
 -- 3.	Total Amount Received: 
   
   select sum(total_payment) as received_amount from bank_loans;
    

-- 3.1	 (MTD) Total Amount Received:
select month(issue_date)as months, sum(total_payment) as received_amount from bank_loans
       where month(issue_date)=12 and year(issue_date)=2021 group by month(issue_date);

-- 3.2	  (PMTD) Total Amount Received:

  select month(issue_date)as months, sum(total_payment) as received_amount from bank_loans
       where month(issue_date)=11 and year(issue_date)=2021 group by month(issue_date);
  
   select * from bank_loans; 
 -- ---------------------------------------------------------------------------------------  
  -- 4. Average Interest Rate: 
 
    select avg(int_rate) as avg_interest_rate from bank_loans;

  -- 4.1	(MTD) Average Interest Rate:

  select month(issue_date)as months, avg(int_rate) as avg_interest_rate from bank_loans
         where month(issue_date)=12 and year(issue_date)=2021 group by month(issue_date);

  -- 4.2 (PMTD) Average Interest Rate:

  select month(issue_date)as months, avg(int_rate) as avg_interest_rate from bank_loans
         where month(issue_date)=11 and year(issue_date)=2021 group by month(issue_date);
         
	 select * from bank_loans;
-- ------------------------------------------------------------------------------------------     
 -- 5.	Average Debt-to-Income Ratio (DTI): 
--   DTI= total monthly EMIs burden/gross monthly income

	select avg(dti) as avg_dti from bank_loans;

-- 5.1	(MTD) Average Debt-to-Income Ratio (DTI):

   select month(issue_date)as months, avg(dti) as avg_dti from bank_loans
         where month(issue_date)=12 and year(issue_date)=2021 group by month(issue_date);


-- 5.2	(PMTD) Average Debt-to-Income Ratio (DTI):
        
	select month(issue_date)as months, avg(dti) as avg_dti from bank_loans
         where month(issue_date)=11 and year(issue_date)=2021 group by month(issue_date);
-- -------------------------------------------------------------------------------------------         
  /* Good Loan:
 Good Loan Application Percentage, Good Loan Applications, Good Loan Funded Amount,
 Good Loan Total Received Amount */
 -- ----------------------------------------------------------------------------------
  select loan_status, count(id) as good_loan_applications, 
       (count(id)/(select count(id) from bank_loans))*100 as  good_loan_applications_perc,                                                               
            sum(loan_amount) as good_Loan_Funded_Amount, sum(total_payment) as
                good_Loan_Received_Amount from bank_loans 
      where loan_status in ("Fully Paid","Current") group by loan_status; 
-- -------------------------------------------------------------------------------
  
/* Bad Loan:
  Bad Loan Applications, Bad Loan Application Percentage, Bad Loan Funded Amount,
  Bad Loan Total Received Amount, */
-- -------------------------------------------------------------------------------------

select loan_status, count(id) as bad_loan_applications, 
       (count(id)/(select count(id) from bank_loans))*100 as  bad_loan_applications_perc,                                                               
            sum(loan_amount) as bad_Loan_Funded_Amount, sum(total_payment) as
                bad_Loan_Received_Amount from bank_loans 
      where loan_status="Charged Off" group by loan_status; 
-- -------------------------------------------------------------------------------------------
/*Loan Status Grid View:
The report should include the following metrics for each loan status, 
Total Loan Applications 
Total Loan Applications percentage
Total Funded Amount 
Total Amount Received
Average Interest Rate 
Average Debt-to-Income Ratio (DTI) */
-- -----------------------------------------------------------------------------------

select loan_status, count(id) as total_loan_applications, 
       (count(id)/(select count(id) from bank_loans))*100 as  total_loan_applications_perc,                                                               
            sum(loan_amount) as total_Funded_Amount, sum(total_payment) as
                total_Received_Amount, round(avg(int_rate),3) as Average_Interest_Rate,
                round(avg(dti),3) as Average_dti
                from bank_loans group by loan_status; 
-- -------------------------------------------------------------------------------------------
/* Loan Status-MTD- Grid View:
The report should include the following metrics for each loan status, 
Total Loan Applications
Total Loan Applications percentage  
Total Funded Amount 
Total Amount Received
Average Interest Rate 
Average Debt-to-Income Ratio (DTI) */
-- ------------------------------------------------------------------------------------

 select loan_status, count(id) as total_loan_applications, 
   (count(id)/(select count(id) from bank_loans))*100 as  total_loan_applications_perc,                                                               
     sum(loan_amount) as total_Funded_Amount, sum(total_payment) as
		total_Received_Amount, round(avg(int_rate),3) as Average_Interest_Rate,
                round(avg(dti),3) as Average_dti from bank_loans 
		where month(issue_date)=12 and year(issue_date)=2021 group by loan_status;

-- ------------------------------------------------------------------------------------

/* The main metrics are Total Loan Applications, Total Funded Amount, and Total Amount Received,
    Monthly Trends by Issue Date */
    -- --------------------------------------------------------------------------------------

  select month(issue_date) as month_no, monthname(issue_date) as months, count(id) as 
  total_loan_applications, sum(loan_amount) as total_Funded_Amount, sum(total_payment) as
		total_Received_Amount from bank_loans
		where year(issue_date)=2021
        group by month(issue_date), monthname(issue_date) order by month_no;
-- ------------------------------------------------------------------------------------------
-- Regional Analysis by State
 
 select address_state, count(id) as total_loan_applications, 
    sum(loan_amount) as total_Funded_Amount, sum(total_payment) as total_Received_Amount 
     from bank_loans where year(issue_date)=2021 group by address_state;
-- -------------------------------------------------------------------------------------

-- Loan Term Analysis 

  select term, count(id) as total_loan_applications, 
    sum(loan_amount) as total_Funded_Amount, sum(total_payment) as total_Received_Amount 
     from bank_loans where year(issue_date)=2021 group by 1;
-- -----------------------------------------------------------------------------------------
-- Employee Length Analysis 

   select emp_length, count(id) as total_loan_applications, 
    sum(loan_amount) as total_Funded_Amount, sum(total_payment) as total_Received_Amount 
     from bank_loans where year(issue_date)=2021 group by 1;
-- ---------------------------------------------------------------------------------------------
-- Loan Purpose Breakdown 
    select purpose, count(id) as total_loan_applications, 
    sum(loan_amount) as total_Funded_Amount, sum(total_payment) as total_Received_Amount 
     from bank_loans where year(issue_date)=2021 group by 1;
-- ------------------------------------------------------------------------------------------
-- Home Ownership Analysis
   select home_ownership, count(id) as total_loan_applications, 
    sum(loan_amount) as total_Funded_Amount, sum(total_payment) as total_Received_Amount 
     from bank_loans where year(issue_date)=2021 group by 1;
-- ---------------------------------------------------------------------------------------



select distinct loan_status from bank_loans;
  select * from bank_loans; 