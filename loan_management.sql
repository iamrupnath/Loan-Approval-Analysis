-- Active: 1755704517343@@127.0.0.1@3306@loan_management
-- Create the database
CREATE DATABASE loan_management;

-- Use the database
USE loan_management;

-- Create the loan applications table
CREATE TABLE loan_applications (
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    income INT NOT NULL,
    credit_score INT NOT NULL,
    loan_amount INT NOT NULL,
    years_employed INT NOT NULL,
    points INT NOT NULL,
    loan_approved VARCHAR(10) NOT NULL
);

-- Display all records
SELECT * FROM loan_applications
LIMIT 5;


-- Q1: Find all applicants whose loan amount is greater than 30% of their annual income

SELECT name, city, income, loan_amount, 
       ROUND((loan_amount / income * 100), 2) AS loan_to_income_ratio
FROM loan_applications
WHERE loan_amount > (income * 0.30)
ORDER BY loan_to_income_ratio DESC;

-- Q2: Calculate the average credit score for approved vs rejected loans

SELECT loan_approved, 
       COUNT(*) AS total_applications,
       ROUND(AVG(credit_score), 2) AS avg_credit_score,
       ROUND(AVG(income), 2) AS avg_income
FROM loan_applications
GROUP BY loan_approved;

-- Q3: Find applicants who have above-average income but below-average credit scores

SELECT name, city, income, credit_score, loan_approved
FROM loan_applications
WHERE income > (SELECT AVG(income) FROM loan_applications)
  AND credit_score < (SELECT AVG(credit_score) FROM loan_applications);

-- Q4: Rank applicants by their points and show their loan approval status

SELECT name, city, points, credit_score, loan_approved,
       RANK() OVER (ORDER BY points DESC) AS points_rank
FROM loan_applications
ORDER BY points DESC;

-- Q5: Calculate the debt-to-income ratio and categorize applicants into risk levels
-- (Low Risk: <25%, Medium Risk: 25-40%, High Risk: >40%)

SELECT name, city, income, loan_amount,
       ROUND((loan_amount / income * 100), 2) AS dti_ratio,
       CASE 
           WHEN (loan_amount / income * 100) < 25 THEN 'Low Risk'
           WHEN (loan_amount / income * 100) BETWEEN 25 AND 40 THEN 'Medium Risk'
           ELSE 'High Risk'
       END AS risk_category,
       loan_approved
FROM loan_applications
ORDER BY dti_ratio;

-- Q6: Find the applicant(s) with the highest loan amount in each approval status category

SELECT name, city, loan_amount, loan_approved
FROM loan_applications la1
WHERE loan_amount = (
    SELECT MAX(loan_amount)
    FROM loan_applications la2
    WHERE la1.loan_approved = la2.loan_approved
);

-- Q7: Calculate cumulative statistics for applicants ordered by credit score

SELECT name, credit_score, loan_amount,
       SUM(loan_amount) OVER (ORDER BY credit_score) AS cumulative_loan_amount,
       AVG(credit_score) OVER (ORDER BY credit_score ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg_credit
FROM loan_applications
ORDER BY credit_score;

-- Q8: Find applicants whose years of employment is above average 
-- but still got rejected (loan_approved = 'FALSE')

SELECT name, city, years_employed, credit_score, points, loan_approved
FROM loan_applications
WHERE years_employed > (SELECT AVG(years_employed) FROM loan_applications)
  AND loan_approved = 'FALSE'
ORDER BY years_employed DESC;

-- Q9: Create a scoring system: Calculate total_score = (credit_score * 0.4) + (points * 10) + (years_employed * 5)
-- and compare it with loan approval status

SELECT name, city, credit_score, points, years_employed,
       ROUND((credit_score * 0.4) + (points * 10) + (years_employed * 5), 2) AS total_score,
       loan_approved,
       CASE 
           WHEN loan_approved = 'TRUE' THEN 'Approved'
           ELSE 'Rejected'
       END AS status
FROM loan_applications
ORDER BY total_score DESC;

-- Q10 : Find all applicants who have either:
-- (high credit score > 600 AND low points < 50) OR (low income < 60000 AND approved)

SELECT name, city, income, credit_score, points, loan_approved
FROM loan_applications
WHERE (credit_score > 600 AND points < 50)
   OR (income < 60000 AND loan_approved = 'TRUE')
ORDER BY credit_score DESC;

