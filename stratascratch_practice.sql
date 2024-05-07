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


