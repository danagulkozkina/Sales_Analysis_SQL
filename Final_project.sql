CREATE database Customers_transactionsl;
UPDATE Customers_transactionsl.customers SET Gender=NULL WHERE Gender="";
UPDATE Customers_transactionsl.customers SET Age=NULL WHERE Age="";
USE Customers_transactionsl;
SELECT * FROM customers;
CREATE TABLE transactions
(date_new DATE,
Id_check INT,
ID_client INT,
Count_products DECIMAL(10,3),
Sum_payment DECIMAL(10,2));

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TRANSACTIONS_final.csv.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

SHOW VARIABLES LIKE "secure_file_priv";
truncate table transactions;

SELECT * FROM transactions;
SELECT * FROM customers;
#Cписок клиентов с непрерывной историей за год, то есть каждый месяц на регулярной основе без пропусков за указанный годовой период, средний чек за период с 01.06.2015 по 01.06.2016,
# средняя сумма покупок за месяц, количество всех операций по клиенту за период;

SELECT
	Id_client,
	year (date_new) AS year_date,
    month(date_new) AS month_date,
	AVG(Sum_payment) AS avg_sum_payment,
    COUNT(*) AS total_count_products_month,
    SUM(Sum_payment) AS total_sum_month
FROM transactions 
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY Id_client, year(date_new),month(date_new)
ORDER BY avg_sum_payment DESC;

   #информацию в разрезе месяцев:
-- средняя сумма чека в месяц;
-- среднее количество операций в месяц;
-- среднее количество клиентов, которые совершали операции;
-- долю от общего количества операций за год и долю в месяц от общей суммы операций;
-- вывести % соотношение M/F/NA в каждом месяце с их долей затрат;

SELECT
	year (t.date_new) AS year_date,
    month(t.date_new) AS month_date,
	AVG(t.Sum_payment) AS avg_check_payment,
    COUNT(DISTINCT t.Id_client) AS active_clients_month,
    COUNT(t.Id_client)/COUNT(DISTINCT t.Id_client) AS avg_operations_per_month,
    COUNT(t.Id_client)/(SELECT COUNT(*) FROM transactions WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01' ) AS share_of_total_operations_year,
    SUM(t.Sum_payment)/(SELECT SUM(Sum_payment) FROM transactions WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS share_of_total_revenue_year,
    
	ROUND(100.0*COUNT(CASE WHEN c.Gender='M' THEN 1 END)/COUNT(t.Id_client),2) AS pct_ops_male,
    ROUND(100.0*COUNT(CASE WHEN c.Gender='F' THEN 1 END)/COUNT(t.Id_client),2) AS pct_ops_female,
    ROUND(100.0*COUNT(CASE WHEN c.Gender IS NULL OR c.Gender='NA' THEN 1 END)/COUNT(t.Id_client),2) AS pct_ops_na,
    
    ROUND(100.0*SUM(CASE WHEN c.Gender='M' THEN t.Sum_payment ELSE 0 END)/SUM(t.Sum_payment),2) AS pct_spend_male,
    ROUND(100.0*SUM(CASE WHEN c.Gender='F' THEN t.Sum_payment ELSE 0 END)/SUM(t.Sum_payment),2) AS pct_spend_female,
    ROUND(100.0*SUM(CASE WHEN c.Gender IS NULL OR c.Gender='NA' THEN t.Sum_payment ELSE 0 END)/SUM(t.Sum_payment),2) AS pct_spend_na

FROM transactions t
JOIN  customers c 
ON t.Id_client=c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY year_date, month_date
ORDER BY year_date, month_date;

#Возрастные группы клиентов с шагом 10 лет и отдельно клиентов, у которых нет данной информации, с параметрами сумма и количество операций за весь период, и поквартально - средние показатели и %.

SELECT 
	CASE
    WHEN c.Age IS NULL THEN 'Нет данных'
    ELSE CONCAT((c.Age DIV 10)*10,'-', (c.Age DIV 10)*10+9) END AS 'Возрастная группа',
    
	QUARTER(t.date_new) AS 'Квартал',
    SUM(t.Sum_payment) AS 'Общая сумма',
    COUNT(*) AS 'Количество операций',
    ROUND(SUM(t.Sum_payment)/3,2) AS 'Средняя сумма в месяц',
    ROUND(COUNT(*)/3,2) AS 'Среднее количество операций в месяц',
    ROUND(100.0*SUM(t.Sum_payment)/(SELECT SUM(tr.Sum_payment) FROM transactions tr WHERE tr.date_new BETWEEN '2015-06-01' AND '2016-06-01'),2) AS '% от выручки за год'
    FROM transactions t 
    JOIN customers c
    ON c.Id_client=t.ID_client
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY 1,2
    ORDER BY 1,2;
    























    