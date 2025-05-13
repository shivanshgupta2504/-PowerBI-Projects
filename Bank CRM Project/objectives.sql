use bankcrm;


SET SQL_SAFE_UPDATES = 0;
update customerinfo
set `Bank DOJ` = STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y');
SET SQL_SAFE_UPDATES = 1;

select * from customerinfo;

-- 2. Identify the top 5 customers with the highest Estimated Salary in the 
-- last quarter of the year. 
select * from customerinfo
where quarter(`Bank DOJ`) = 4
order by EstimatedSalary desc
limit 5;

-- 3. Calculate the average number of products used by customers who have a credit card. 
select avg(NumOfProducts) as Average_number_of_products
from bank_churn
where HasCrCard = 1;

-- 5. Compare the average credit score of customers who have exited and those who remain. 
select
	case
		when Exited = 1 then 'Remain'
        else
			'Exited'
	end as Customer_type,
    avg(CreditScore) as Average_credit_score
from bank_churn
group by 1;

-- 6. Which gender has a higher average estimated salary, and how does it relate 
-- to the number of active accounts?
select
	g.GenderCategory as Gender,
    avg(c.EstimatedSalary) as Average_Estimated_Salary,
    count(c.CustomerId) as Active_members
from customerinfo c join gender g on c.GenderID = g.GenderID
where c.CustomerId in (
	select CustomerId
    from bank_churn
    where IsActiveMember = 1
)
group by 1;

-- 7. Segment the customers based on their credit score and identify the segment with the highest exit rate.
select
	case 
		when CreditScore < 400 then 'Low'
		when CreditScore between 400 and 700 then 'Medium'
        else 'High'
	end as CreditScoreSegment,
	count(*) as TotalCustomers,
    sum(Exited) as ExitedCustomers,
    round(sum(Exited) * 100.0 / count(*), 2) as ExitRate
from bank_churn
group by
	case 
		when CreditScore < 400 then 'Low'
		when CreditScore between 400 and 700 then 'Medium'
        else 'High'
	end
order by ExitRate desc;

-- 8. Find out which geographic region has the highest number of active customers with a tenure greater than 5 years.
select
	g.GeographyLocation,
    count(*) as TotalActiveCustomers
from geography g left join customerinfo ci on g.GeographyID = ci.GeographyID left join bank_churn bc on ci.CustomerId = bc.CustomerId
where bc.Tenure > 5 and bc.IsActiveMember = 1
group by 1
order by 2 desc;

-- 11. Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). 
select
	date_format(`Bank DOJ`, '%Y-%m') as YearMonth,
    count(*) as TotalCustomers
from customerinfo
group by 1
order by 1;

-- 15. Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. 
-- Also, rank the gender according to the average value.
select
	g.GeographyLocation,
    ge.GenderCategory,
    round(avg(ci.EstimatedSalary), 2) as AveargeIncome,
    rank() 
    over(
		partition by g.GeographyLocation 
		order by round(avg(ci.EstimatedSalary), 2) desc
	) as IncomeRank
from 
	customerinfo ci 
    join geography g on ci.GeographyID = g.GeographyID 
    join gender ge on ge.GenderID = ci.GenderID
group by 1,2;

-- 16. Using SQL, write a query to find out the average tenure of the people 
-- who have exited in each age bracket (18-30, 30-50, 50+).
select
	case
		when ci.Age < 30 then '18-30'
        when ci.Age < 50 then '30-50'
        else
			'50+'
	end as AgeBucket,
	round(avg(bc.Tenure), 2) as AverageTenure
from 
	customerinfo ci 
    left join 
    bank_churn bc 
    on ci.CustomerId = bc.CustomerId
where bc.Exited = 1
group by 1;

-- 23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
select
	*,
    case
		when Exited = 1 then 'Exit'
        else
			'Retain'
	end as 'ExitCategory'
from bank_churn;

-- 25. Write the query to get the customer IDs, their last name, and whether they are active or not for the customers 
-- whose surname ends with “on”.
select
	CustomerId,
    Surname
from customerinfo
where Surname like '%on';
