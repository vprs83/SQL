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
    ID 10308    Salaries Differences
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
                SUM(pairs) AS sum_of_pairs,
                COUNT(users) OVER() users_amount
        FROM users_union
        GROUP BY users
    )
SELECT  users,
        (sum_of_pairs / users_amount) * 100 AS popularity_percent
FROM users_and_amount_of_friends_calc
ORDER BY users ASC;

/*
    ID 10176    Bikes Last Used    
    Find the last time each bike was in use. 
    Output both the bike number and the date-timestamp of the bike's last use (i.e., the date-time the bike was returned). 
    Order the results by bikes that were most recently used.
*/

SELECT  DISTINCT bike_number,
        LAST_VALUE(end_time) OVER(PARTITION BY bike_number) last_used
FROM dc_bikeshare_q1_2012
ORDER BY last_used DESC;

SELECT COUNT(bike_number)           FROM dc_bikeshare_q1_2012;  -- 100
SELECT COUNT(DISTINCT bike_number)  FROM dc_bikeshare_q1_2012;  -- 98

-- Hints solution
SELECT bike_number,
       max(end_time) last_used
FROM dc_bikeshare_q1_2012
GROUP BY bike_number
ORDER BY last_used DESC;

/*
    ID 10159    Ranking Most Active Guests
    
    Rank guests based on the total number of messages they've exchanged with any of the hosts. 
    Guests with the same number of messages as other guests should have the same rank. 
    Do not skip rankings if the preceding rankings are identical.
    Output the rank, guest id, and number of total messages they've sent. Order by the highest number of total messages first.
*/
SELECT  DENSE_RANK() OVER(ORDER BY SUM(n_messages) DESC) AS ranking,
        id_guest,
        SUM(n_messages)
FROM airbnb_contacts
GROUP BY id_guest
ORDER BY ranking ASC;

/*
    ID 10077    Income By Title and Gender
    
    Find the average total compensation based on employee titles and gender. 
    Total compensation is calculated by adding both the salary and bonus of each employee. 
    However, not every employee receives a bonus so disregard employees without bonuses in your calculation. 
    Employee can receive more than one bonus.
    Output the employee title, gender (i.e., sex), along with the average total compensation.
*/
WITH total_compensation_calc(id, employee_title, sex, total_compensation) AS
(
    SELECT  DISTINCT e.id,
            employee_title,
            sex,
            e.salary + SUM(b.bonus) OVER(PARTITION BY b.worker_ref_id)
    FROM sf_employee e
    JOIN sf_bonus b ON e.id = b.worker_ref_id
)
SELECT  employee_title,
        sex,
        AVG(total_compensation)
FROM total_compensation_calc
GROUP BY employee_title, sex;

/*
    ID 10134    Spam Posts
    
    Calculate the percentage of spam posts in all viewed posts by day. 
    A post is considered a spam if a string "spam" is inside keywords of the post. 
    Note that the facebook_posts table stores all posts posted by users. 
    The facebook_post_views table is an action table denoting if a user has viewed a post.
*/
WITH spam_and_non_spam_posts AS (
        SELECT  DISTINCT fp.post_date AS date, 
                COUNT(  CASE 
                            WHEN fp.post_keywords LIKE '%spam%'
                            THEN fp.post_id
                            ELSE NULL
                        END
                    )               OVER post_date_w    AS n_spam,
                COUNT(fp.post_id)   OVER post_date_w    AS n_posts
        FROM facebook_posts fp
        JOIN facebook_post_views fpv ON fp.post_id = fpv.post_id
        WINDOW post_date_w AS (
            PARTITION BY fp.post_date
        )
)
SELECT  date,    
        --CAST(n_spam AS numeric) / CAST(n_posts AS numeric) * 100 AS spam_share,
        --float4(n_spam) / float4(n_posts) * 100 AS spam_share
        (n_spam/n_posts::real) * 100 AS spam_share
FROM spam_and_non_spam_posts
ORDER BY date;

/*
    ID 10299    Finding Updated Records
    
    We have a table with employees and their salaries, however, some of the records are old and contain outdated salary information. 
    Find the current salary of each employee assuming that salaries increase each year. 
    Output their id, first name, last name, department ID, and current salary. 
    Order your list by employee ID in ascending order.
*/
SELECT  DISTINCT id,
        first_name,
        last_name,
        department_id,
        MAX(salary) OVER(PARTITION BY id) current_salary
FROM ms_employee_salary
ORDER BY id ASC;

/*
    ID 9942     Largest Olympics
    
    Find the Olympics with the highest number of athletes. 
    The Olympics game is a combination of the year and the season, and is found in the 'games' column. 
    Output the Olympics along with the corresponding number of athletes.
*/
WITH
    unique_athletes AS (
        SELECT  DISTINCT id,
                games
        FROM olympics_athletes_events
    ),
    athletes_count AS (
        SELECT  DISTINCT games,
                COUNT(id) OVER(PARTITION BY games) number_of_athletes
        FROM unique_athletes
    ),
    games_ranking AS (
        SELECT  games,
                number_of_athletes,
                DENSE_RANK() OVER(ORDER BY number_of_athletes DESC) game_rank
        FROM athletes_count
    )
SELECT  games,
        number_of_athletes
FROM games_ranking
WHERE game_rank = 1;

/*
    ID 9892     Second Highest Salary
    Find the second highest salary of employees.
*/
WITH salary_ranking AS (
    SELECT  salary,
            DENSE_RANK() OVER(ORDER BY salary DESC) AS salary_rank
    FROM employee
)
SELECT salary
FROM   salary_ranking
WHERE  salary_rank = 2;

/*
    ID 9847     Number of Workers by Department Starting in April or Later
    
    Find the number of workers by department who joined in or after April.
    Output the department name along with the corresponding number of workers.
    Sort records based on the number of workers in descending order.
*/
SELECT  DISTINCT department,
        COUNT(worker_id) OVER(PARTITION BY department) number_of_workers
FROM worker
WHERE EXTRACT(MONTH FROM joining_date) >= 4;

/*
    ID 9915     Highest Cost Orders
    
    Find the customer with the highest daily total order cost between 2019-02-01 to 2019-05-01.
    If customer had more than one order on a certain day, sum the order costs on daily basis.
    Output customer's first name, total cost of their items, and the date.
    For simplicity, you can assume that every first name in the dataset is unique.
*/
WITH customers_with_max_order_costs AS (
    SELECT  DISTINCT c.id id,
            c.first_name name,
            o.order_date date,
            SUM(o.total_order_cost) OVER(PARTITION BY o.cust_id, order_date) order_sum
    FROM customers c
    JOIN orders o ON c.id = o.cust_id
    WHERE o.order_date BETWEEN '2019-02-01' AND '2019-05-01'
)
SELECT  name,
        date,
        MAX(order_sum)
FROM customers_with_max_order_costs
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1;

/*
    ID 9894     Employee and Manager Salaries
    Find employees who are earning more than their managers.
    Output the employee's first name along with the corresponding salary.
*/
SELECT  e.first_name,
        e.salary
FROM employee e
JOIN employee e2 ON e.manager_id = e2.id
WHERE e.salary > e2.salary;

/*
    ID 10141    Apple Product Counts
    
    Find the number of Apple product users and the number of total users with a device and group the counts by language.
    Assume Apple products are only MacBook-Pro, iPhone 5s, and iPad-air.
    Output the language along with the total number of Apple users and users with any device.
    Order your results based on the number of total users in descending order.

*/
-- SELECT COUNT(DISTINCT user_id)
-- FROM playbook_events;   -- 85

-- SELECT COUNT(user_id)
-- FROM playbook_events;   -- 100
WITH
    total_users AS (
        SELECT  DISTINCT user_id
        FROM    playbook_events
    ),
    apple_users AS (
        SELECT  DISTINCT user_id
        FROM    playbook_events
        WHERE   device IN ('macbook pro', 'iphone 5s', 'ipad air')
    )
SELECT  DISTINCT pu.language,
        COUNT(au.user_id) OVER language_w n_apple_users,
        COUNT(tu.user_id) OVER language_w n_total_users
FROM        total_users tu
LEFT JOIN   apple_users au ON tu.user_id = au.user_id
JOIN        playbook_users pu ON tu.user_id = pu.user_id
WINDOW      language_w AS ( PARTITION BY pu.language )
ORDER BY    n_total_users DESC;

/*
    ID 514  Marketing Campaign Success [Advanced]
    
    You have a table of in-app purchases by user.
    Users that make their first in-app purchase are placed in a marketing campaign where they see call-to-actions for more in-app purchases.
    Find the number of users that made additional in-app purchases due to the success of the marketing campaign.
    The marketing campaign doesn't start until one day after the initial in-app purchase so users that only made one or multiple purchases on the first day do not count,
    nor do we count users that over time purchase only the products they purchased on the first day.
*/
WITH
    first_purchase_date_filt AS (
        SELECT  user_id,
                MIN(created_at) first_purchase_date
        FROM    marketing_campaign
        GROUP BY user_id
    ),
    first_date_and_purchases_filt AS (
        SELECT  user_id,
                created_at,
                product_id
        FROM    marketing_campaign mc
        WHERE   created_at IN   (
                                    SELECT  fp.first_purchase_date
                                    FROM    first_purchase_date_filt AS fp
                                    WHERE   mc.user_id = fp.user_id
                                )
    )
SELECT  COUNT(DISTINCT user_id)
FROM    marketing_campaign mc
WHERE   created_at NOT IN   (
                                SELECT  fdp.created_at
                                FROM    first_date_and_purchases_filt fdp
                                WHERE   mc.user_id = fdp.user_id
                            )
                                AND
        product_id NOT IN   (
                                SELECT  fdp.product_id
                                FROM    first_date_and_purchases_filt fdp
                                WHERE   mc.user_id = fdp.user_id
                            );

/*
    ID 10087    Find all posts which were reacted to with a heart
    Find all posts which were reacted to with a heart. 
    For such posts output all columns from facebook_posts table.
*/
SELECT  DISTINCT fp.post_id,
        fp.poster,
        fp.post_text,
        fp.post_keywords,
        fp.post_date
FROM facebook_posts fp
JOIN facebook_reactions fr ON fp.post_id = fr.post_id
WHERE fr.reaction LIKE 'heart';

/*
    ID 10303    Top Percentile Fraud
    
    ABC Corp is a mid-sized insurer in the US and in the recent past their fraudulent claims have increased significantly for their personal auto insurance portfolio.
    They have developed a ML based predictive model to identify propensity of fraudulent claims. 
    Now, they assign highly experienced claim adjusters for top 5 percentile of claims identified by the model.
    Your objective is to identify the top 5 percentile of claims from each state. 
    Your output should be policy number, state, claim cost, and fraud score.
*/
WITH 
    n_claims_in_five_percentile AS (
        SELECT  DISTINCT state,
                --ROUND(CAST(COUNT(policy_num) OVER(PARTITION BY state) AS numeric) / 100 * 5) five_percents
                CEIL(CAST(COUNT(policy_num) OVER(PARTITION BY state) AS numeric) / 100 * 5) five_percentile
        FROM fraud_score
    ),
    fraud_score_ranking_by_state AS (
        SELECT  *,
            DENSE_RANK() OVER(PARTITION BY state ORDER BY fraud_score DESC) fraud_score_rank
        FROM fraud_score
    )
SELECT  policy_num,
        state,
        claim_cost,
        fraud_score
FROM fraud_score_ranking_by_state fs
WHERE   state IN (SELECT state FROM n_claims_in_five_percentile) AND
        fraud_score_rank <= (   SELECT five_percentile 
                                FROM n_claims_in_five_percentile nc
                                WHERE nc.state = fs.state 
                            );

/*
    ID 10078    Find matching hosts and guests in a way that they are both of the same gender and nationality
    Find matching hosts and guests pairs in a way that they are both of the same gender and nationality.
    Output the host id and the guest id of matched pair.
*/
SELECT  DISTINCT ah.host_id,
        ag.guest_id
FROM airbnb_hosts ah
JOIN airbnb_guests ag 
    ON  ah.nationality = ag.nationality AND
        ah.gender = ag.gender;

/*
    ID 10090    Find the percentage of shipable orders
    Find the percentage of shipable orders.
    Consider an order is shipable if the customer's address is known.
*/
SELECT (COUNT(*) / (SELECT COUNT(DISTINCT id) FROM orders)::real) * 100 percent_shipable
FROM orders o
JOIN customers c ON o.cust_id = c.id
WHERE address IS NOT NULL;

/*
    ID 10046    Top 5 States With 5 Star Businesses
    Find the top 5 states with the most 5 star businesses. 
    Output the state name along with the number of 5-star businesses and order records by the number of 5-star businesses in descending order. In case there are ties in the number of businesses, return all the unique states. 
    If two states have the same result, sort them in alphabetical order.
*/
WITH 
    n_businesses_per_state AS (
        SELECT  DISTINCT state,
                COUNT(*) OVER(PARTITION BY state) n_businesses
        FROM    yelp_business
        WHERE   stars = 5
    ),
    state_runking AS (
        SELECT  state,
                n_businesses,
                RANK() OVER(ORDER BY n_businesses DESC) state_rank
        FROM    n_businesses_per_state
    )
SELECT  state,
        n_businesses
FROM    state_runking
WHERE   state_rank <= 5;