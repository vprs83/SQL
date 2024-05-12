-- Stratascratch coding question solutions

/*
    Not checked solution!
    
    ID 10368 Population Density

    You are working on a data analysis project at Deloitte where you need to analyze a dataset containing information
    about various cities. Your task is to calculate the population density of these cities, rounded to the nearest integer, and identify the cities with the minimum and maximum densities.
    The population density should be calculated as (Population / Area).

    The output should contain 'city', 'country', 'density'.
*/

CREATE TABLE cities_population(
    city        VARCHAR2(50),
    country     VARCHAR2(50),
    population  NUMBER,
    area        NUMBER
);

SELECT city, country, density
FROM (
        SELECT  city,
                country,
                ROUND(population/area) density,
                DENSE_RANK() OVER(ORDER BY population/area DESC) rank
        from cities_population
        WHERE area <> 0
    ) sq
WHERE rank = 1 OR rank = (
                            SELECT MAX(rank)
                            FROM (
                                    SELECT DENSE_RANK() OVER(ORDER BY population/area DESC) rank
                                    from cities_population
                                    WHERE area <> 0
                                ) AS sq2
                        )
ORDER BY density ASC;

/*
    ID 10322 Finding User Purchases
    
    Write a query that'll identify returning active users. 
    A returning active user is a user that has made a second purchase 
    within 7 days of any other of their purchases. 
    Output a list of user_ids of these returning active users.
*/

CREATE TABLE cities_population(
    id          NUMBER,
    user_id     NUMBER,
    item        VARCHAR2(50),
    created_at  DATE,
    revenue     NUMBER
);

-- use self join    
SELECT DISTINCT at.user_id "Returning active users"
                --at.created_at,
                --at2.created_at
FROM amazon_transactions at
JOIN amazon_transactions at2
    ON at.user_id = at2.user_id
WHERE   at.created_at + INTERVAL '7 DAY' >= at2.created_at AND 
        at.created_at <> at2.created_at AND
        at.created_at < at2.created_at
ORDER BY at.user_id;

-- use analytic function LEAD(), without self join
SELECT DISTINCT user_id "Returning active users"
        -- created_at,
        -- next_created_at
FROM (
        SELECT  DISTINCT user_id,
                created_at,
                LEAD(created_at) OVER(PARTITION BY user_id ORDER BY created_at) AS next_created_at
        FROM amazon_transactions
    ) sq
WHERE next_created_at - created_at <= 7
ORDER BY user_id;

-- use analytic function LEAD(), without self join
-- use CTE
WITH next_purchase_date AS
(
    SELECT  DISTINCT user_id,
            created_at,
            LEAD(created_at) OVER(PARTITION BY user_id ORDER BY created_at) AS next_created_at
    FROM amazon_transactions
)
SELECT DISTINCT user_id "Returning active users"
FROM next_purchase_date
WHERE next_created_at - created_at <= 7
ORDER BY user_id;

/*
    ID 10352    Users By Average Session Time

    Calculate each user's average session time. 
    A session is defined as the time difference between a page_load and page_exit. 
    For simplicity, assume a user has only 1 session per day and if there are multiple 
    of the same events on that day, consider only the latest page_load and earliest page_exit, 
    with an obvious restriction that load time event should happen before exit time event . 
    Output the user_id and their average session time.
*/

-- average session time
-- session = page_exit - page_load
-- 1 session per day
-- latest page_load
-- earliest page_exit

CREATE TABLE facebook_web_log (
    user_id     NUMBER,
    datetime    TIMESTAMP,
    action:     VARCHAR2(20)
);

SELECT  DISTINCT user_id,
        AVG(sq3.session) OVER(PARTITION BY user_id) "Average session time"
FROM (
        SELECT  sq2.user_id,
                -- sq2.action,
                -- sq2.latest_page_load_time,
                -- sq2.earlest_page_exit_time,
                sq2.earlest_page_exit_time - sq2.latest_page_load_time session
        FROM (
                SELECT  user_id,
                        action,
                        MAX(timestamp) OVER(PARTITION BY user_id, action, DATE(timestamp)) latest_page_load_time,
                        --timestamp,
                        (   
                            SELECT MIN(timestamp) 
                            FROM facebook_web_log fwl_sq 
                            WHERE   fwl_sq.user_id = fwl.user_id AND
                                    action = 'page_exit' AND 
                                    DATE(fwl_sq.timestamp) = DATE(fwl.timestamp)
                        ) earlest_page_exit_time
                FROM facebook_web_log fwl
                WHERE   action = 'page_load'
            ) sq2
        GROUP BY    sq2.user_id,
                    -- sq2.action,
                    sq2.latest_page_load_time,
                    sq2.earlest_page_exit_time
        ) sq3
GROUP BY    user_id, 
            sq3.session
HAVING sq3.session IS NOT NULL;

/*
    ID 10351 Activity Rank
    
    Find the email activity rank for each user. 
    Email activity rank is defined by the total number of emails sent. 
    The user with the highest number of emails sent will have a rank of 1, and so on. 
    Output the user, total emails, and their activity rank. 
    Order records by the total emails in descending order. 
    Sort users with the same number of emails in alphabetical order.
    In your rankings, return a unique value (i.e., a unique rank) even if multiple users have the same number of emails. 
    For tie breaker use alphabetical order of the user usernames.
*/

SELECT  sq2.sq_from_user,
        sq2.sq_number_of_emails,
        ROW_NUMBER() OVER(ORDER BY sq2.sq_number_of_emails DESC)
FROM (
        SELECT  sq.from_user        AS sq_from_user,
                sq.number_of_emails AS sq_number_of_emails,
                DENSE_RANK() OVER(ORDER BY number_of_emails DESC) AS activity_rank
        FROM (
                SELECT  from_user,
                        COUNT(from_user) AS number_of_emails
                FROM google_gmail_emails
                GROUP BY from_user
            ) sq
        ORDER BY activity_rank, from_user ASC
    ) sq2;

-- Hints solution
SELECT  from_user, 
        COUNT(from_user) AS number_of_emails, 
        ROW_NUMBER() OVER(ORDER BY COUNT(from_user) DESC, from_user ASC)
FROM        google_gmail_emails 
GROUP BY    from_user
ORDER BY    2 DESC, 1;

/*
    ID 10319 Monthly Percentage Difference
    
    Given a table of purchases by date, 
    calculate the month-over-month percentage change in revenue. 
    The output should include the year-month date (YYYY-MM) 
    and percentage change, rounded to the 2nd decimal point, 
    and sorted from the beginning of the year to the end of the year.
    
    The percentage change column will be populated from the 2nd month forward 
    and can be calculated as ((this month's revenue - last month's revenue) / last month's revenue)*100.
*/

-- Solution must be verified for PostgreSQL / Oracle !
WITH 
    get_year_and_month_from_field AS
    (
        SELECT  EXTRACT(YEAR from created_at) as year,
                EXTRACT(MONTH from created_at) as month,
                purchase_id,
                value
        FROM sf_transactions
    ),
    year_and_month_concat AS
    (
        SELECT  year || '-' || month AS year_month,
                purchase_id,
                value
        FROM get_year_and_month_from_field
    ),
    year_and_month_string_to_date AS
    (
        SELECT  TO_DATE(year_month, 'YYYY-MM') AS date,
                year_month,
                purchase_id,
                value
        FROM year_and_month_concat
    ),
    revenue_sum_per_month AS
    (
        SELECT  DISTINCT year_month,
                date,
                SUM(value) OVER(PARTITION BY year_month) month_revenue
        FROM year_and_month_string_to_date
    ),
    add_next_month_revenue AS
    (
        SELECT  DISTINCT year_month,
                date,
                month_revenue,
                LAG(month_revenue) OVER(ORDER BY date) next_month_revenue
        FROM revenue_sum_per_month
        ORDER BY date ASC
    )
SELECT  year_month,
        -- date,
        -- month_revenue,
        -- next_month_revenue,
        ((month_revenue - next_month_revenue) / next_month_revenue) * 100 "%"
FROM add_next_month_revenue;

/*
    ID 10318 New Products
    
    You are given a table of product launches by company by year. 
    Write a query to count the net difference between the number of products companies launched in 2020 
    with the number of products companies launched in the previous year. 
    Output the name of the companies and a net difference of net products released for 2020 compared to the previous year.
*/
WITH 
    number_of_products_launched_per_year AS
    (
        SELECT  DISTINCT year, 
                company_name,
                COUNT(product_name) OVER(PARTITION BY year, company_name) AS number_of_launched_products_crnt_year
        FROM car_launches
    ),
    add_products_lauched_previous_year AS
    (
        SELECT  year, 
                company_name,
                number_of_launched_products_crnt_year,
                LAG(number_of_launched_products_crnt_year) OVER(PARTITION BY company_name ORDER BY year) number_of_launched_products_prev_year
        FROM number_of_products_launched_per_year
        ORDER BY company_name, year
    ),
    net_difference AS
    (
        SELECT  company_name,
                number_of_launched_products_crnt_year - number_of_launched_products_prev_year AS net_products
        FROM add_products_lauched_previous_year
        WHERE number_of_launched_products_prev_year IS NOT NULL
    )
SELECT * FROM net_difference;

/*
    ID 10304 Risky Projects
    
    Identify projects that are at risk for going overbudget. 
    A project is considered to be overbudget if the cost of all employees assigned to the project is greater than the budget of the project. 
    
    You'll need to prorate the cost of the employees to the duration of the project. For example, 
    if the budget for a project that takes half a year to complete is $10K, then the total half-year salary of all employees assigned to the project should not exceed $10K. 
    Salary is defined on a yearly basis, so be careful how to calculate salaries for the projects that last less or more than one year.
    
    Output a list of projects that are overbudget with their project name, project budget, and prorated total employee expense (rounded to the next dollar amount).
    
    HINT: to make it simpler, consider that all years have 365 days. You don't need to think about the leap years.
*/
WITH prorated_total_employee_expense_calc AS
(
    SELECT  DISTINCT lp.title,
            lp.budget,
            --CEILING(SUM((CAST(le.salary AS REAL) / 365) * (lp.end_date::date - lp.start_date::date)) OVER(PARTITION BY lp.id)) AS prorated_employee_expense
            CEILING(SUM((CAST(le.salary AS REAL) / 365) * DATEDIFF(lp.end_date, lp.start_date)) OVER(PARTITION BY lp.id)) AS prorated_total_employee_expense
    FROM linkedin_projects lp
    JOIN linkedin_emp_projects lep ON lp.id = lep.project_id
    JOIN linkedin_employees le ON lep.emp_id = le.id
)
SELECT  title,
        budget,
        prorated_total_employee_expense
FROM  prorated_total_employee_expense_calc
WHERE prorated_total_employee_expense > budget
ORDER BY title;

/*
    ID 10308 Salaries Differences

    Write a query that calculates the difference between the highest salaries found in the marketing and engineering departments. 
    Output just the absolute difference in salaries.
*/
WITH max_salary_by_department AS
(
    SELECT  DISTINCT d.department,
            MAX(salary) OVER(PARTITION BY department_id) max_salary
    FROM db_employee e
    JOIN db_dept d ON e.department_id = d.id
    WHERE d.department IN ('marketing', 'engineering')
)
SELECT MAX(max_salary) - MIN(max_salary) AS "Absolute difference in salaries"
FROM max_salary_by_department;

/*
    ID 10300    Premium vs Freemium
    
    Find the total number of downloads for paying and non-paying users by date. 
    Include only records where non-paying customers have more downloads than paying customers. 
    The output should be sorted by earliest date first and contain 3 columns date, non-paying downloads, paying downloads.
*/
WITH 
    downloads_count(date, customer_status, sum_of_downloads) AS
    (
        SELECT  DISTINCT df.date,
                ad.paying_customer,
                SUM(df.downloads) OVER(PARTITION BY df.date, ad.paying_customer) 
        FROM ms_user_dimension ud
        JOIN ms_acc_dimension ad ON ad.acc_id = ud.acc_id
        JOIN ms_download_facts df ON ud.user_id = df.user_id
        ORDER BY    df.date,
                    ad.paying_customer DESC
    ),
    embedding_output_into_row(date, paying_downloads, non_paying_downloads) AS
    (
        SELECT  date,
                sum_of_downloads,
                LEAD(sum_of_downloads) OVER(PARTITION BY date)
        FROM downloads_count
    )
SELECT  date,
        paying_downloads,
        non_paying_downloads
FROM    embedding_output_into_row
WHERE   non_paying_downloads > paying_downloads AND
        non_paying_downloads IS NOT NULL;
        
/*
    ID 10285    Acceptance Rate By Date
    
    What is the overall friend acceptance rate by date? 
    Your output should have the rate of acceptances by the date the request was sent. 
    Order by the earliest date to latest.
    
    Assume that each friend request starts by a user sending (i.e., user_id_sender) 
    a friend request to another user (i.e., user_id_receiver) that's logged in the table with action = 'sent'. 
    
    If the request is accepted, the table logs action = 'accepted'. 
    If the request is not accepted, no record of action = 'accepted' is logged.
*/
WITH 
    friend_request_process(user_id_sender, date, action, friend_accepted_status) AS
    (
        SELECT  user_id_sender,
                date,
                action,
                LEAD(action) OVER(PARTITION BY user_id_sender)
        FROM fb_friend_requests
    ),
    friend_requests_sended(date, number_of_requests) AS
    (
        SELECT  DISTINCT date, 
                COUNT(user_id_sender) OVER(PARTITION BY date)
        FROM friend_request_process
        WHERE action = 'sent'
    ),
    friend_requests_accepted(date, number_of_requests) AS
    (
        SELECT  DISTINCT date, 
                COUNT(user_id_sender) OVER(PARTITION BY date)
        FROM friend_request_process
        WHERE action = 'sent' AND friend_accepted_status = 'accepted'
    ),
    friend_acceptance_rate(date, rate) AS
    (
        SELECT  rs.date,
                CAST(ra.number_of_requests AS NUMERIC) / CAST(rs.number_of_requests AS NUMERIC)
        FROM friend_requests_sended rs
        JOIN friend_requests_accepted ra ON rs.date = ra.date
    )
SELECT  date,
        rate
FROM friend_acceptance_rate;

/*
    ID 10284    Popularity Percentage
    
    Find the popularity percentage for each user on Meta/Facebook. 
    The popularity percentage is defined as the total number of friends the user has divided by the total number of users on the platform, then converted into a percentage by multiplying by 100.
    Output each user along with their popularity percentage. Order records in ascending order by user id.
    The 'user1' and 'user2' column are pairs of friends.
*/
WITH 
    user_pairs_count1 AS
    (
        SELECT  DISTINCT user1, 
                COUNT(user2) OVER(PARTITION BY user1) pairs
        FROM facebook_friends
    ),
    user_pairs_count2 AS
    (
        SELECT  DISTINCT user2, 
                COUNT(user1) OVER(PARTITION BY user2) pairs
        FROM facebook_friends
    ),
    users_union(users, pairs) AS
    (
        SELECT *
        FROM user_pairs_count1
        UNION
        SELECT *
        FROM user_pairs_count2        
    ),
    users_and_amount_of_friends_calc AS
    (
        SELECT  users,
                SUM(pairs) AS sum_of_pairs
        FROM users_union
        GROUP BY users
    ),
    users_amount_calc AS
    (
        SELECT COUNT(users) users_amount
        FROM users_and_amount_of_friends_calc
    )
SELECT  users,
        (sum_of_pairs / (SELECT users_amount FROM users_amount_calc)) * 100 AS popularity_percent
FROM users_and_amount_of_friends_calc
ORDER BY users ASC;