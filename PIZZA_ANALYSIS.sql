#CHECKING EACH TABLE BY ITS OWN TO HAVE AN OVERVIEW OF OUR DATA:

select * from pizza_types;

select * from pizzas;

select * from order_details;

select * from orders;

#1--WHAT IS THE DATE RANGE?
select min(`date`), max(`date`)
from orders;

#2--WHAT IS THE TOTAL AMOUNT OF ORDERS IN THE DATE RANGE?
select count(*)
from orders;

#3--WHAT IS THE TOTAL AMOUNT OF PIZZAS SOLD?
select sum(quantity)
from order_details;

#4--WHAT IS THE TOTAL REVENUE?
select sum(od.quantity * pi.price) AS TOTAL_REVENUE
from order_details od
join pizzas pi
	on od.pizza_id = pi.pizza_id;
    
#5--WHICH PIZZA SELLS THE MOST IN QUANTITY?
select pizza_id, sum(quantity)
from order_details
group by pizza_id
order by sum(quantity) desc;

#6--WHICH PIZZA SELLS THE MOST IN QUANTITY WITH PIZZA NAME AND CATEGORY?
select pt.name AS pizza_name,
	   pt.category AS pizza_category,
       sum(od.quantity) AS TOTAL_QUANTITY
FROM order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name, pt.category
order by TOTAL_QUANTITY desc;

#7--WHICH PIZZA SIZE GENERATES THE MOST REVENUE?
select p.size as pizza_size, sum(od.quantity * p.price) as generated_revenue
from order_details od 
join pizzas p
			 on od.pizza_id = p.pizza_id
group by p.size
order by generated_revenue desc;

#8--WHAT IS THE AVERAGE NUMBER OF PIZZAS PER ORDER?
SELECT AVG(SUM) AS AVERAGE_PIZZAS_PER_ORDER FROM
 (select order_id as order_number, SUM(quantity) AS SUM
 from order_details
 group by order_number) AS ORDER_TOTAL;
 
 #9--WHAT ARE THE TOP THREE DAYS WITH HIGHEST SALE?
select  o.`date` as `DAY`, sum(quantity*price) AS TOTAL_SALES
from orders o
join order_details od
				ON o.order_id = od.order_id
join pizzas p
				ON od.pizza_id = p.pizza_id
group by o.`date`
order by total_SALES desc LIMIT 3;

#10--HOW DOES SALES VARY BY CATEGORY?
SELECT pt.category AS pizza_category , SUM(quantity * price) AS TOTAL_SALES
from order_details od 
join pizzas p 
				ON od.pizza_id = p.pizza_id
join pizza_types pt 
				ON p.pizza_type_id = pt.pizza_type_id
group by pt.category ;

#11--WHICH PIZZA TYPE AND SIZE COMBINATION GENERATES THE HIGHEST REVENUE?
SELECT 
    pt.name AS pizza_name,
    p.size,
    SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name, p.size
ORDER BY total_revenue DESC;

#12--WHAT IS THE PEAK ORDERING HOUR:
SELECT 
    HOUR(os.time) AS ordering_hour,
    COUNT(DISTINCT os.order_id) AS num_orders
FROM orders os
JOIN order_details od
    ON os.order_id = od.order_id
GROUP BY ordering_hour
ORDER BY num_orders DESC;

#13--FOR EACH PIZZA CATEGORY RANK THE PIZZAS BY TOTAL REVENUE AND SHOW THE TOP SELLING PIZZA IN EACH CATEGORY.
WITH ranked_pizzas AS
 (
    SELECT 
        pt.category,
        pt.name AS pizza_name,
        SUM(od.quantity * ps.price) AS total_revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * ps.price) DESC) AS rnk
    FROM order_details od
    JOIN pizzas ps
        ON od.pizza_id = ps.pizza_id
    JOIN pizza_types pt
        ON ps.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
)
SELECT category, pizza_name, total_revenue
FROM ranked_pizzas
WHERE rnk = 1;

#14:WHAT PERCENTAGE OF TOTAL REVENUE DOES EACH PIZZA CATEGORY CONTRIBUTE?

With TOTAL_REVENUES_CATEGORY AS
(
SELECT 
	    pt.category,
        SUM(od.quantity * ps.price) AS revenue_category
    FROM order_details od
    JOIN pizzas ps
        ON od.pizza_id = ps.pizza_id
    JOIN pizza_types pt
        ON ps.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category
)
select category,
	   revenue_category,
       revenue_category / SUM(revenue_category) over () * 100 AS REVENUE_PERCENTAGE	   
FROM TOTAL_REVENUES_CATEGORY
ORDER BY REVENUE_PERCENTAGE DESC;

#15--: For each day, calculate the running (cumulative) total revenue over time.

select * from order_details;
select * from orders;
select * from pizzas;

select `date`,
		DAILY_REVENUE,
        SUM(DAILY_REVENUE) OVER(ORDER BY `date`) AS RUNNING_TOTAL_REVENUE
FROM(
select  os.`date`,
		sum(od.quantity * ps.price) AS DAILY_REVENUE		
from orders os
join order_details od
		on os.order_id = od.order_id
join pizzas ps
		on od.pizza_id = ps.pizza_id
group by os.`date`
) AS DAILY_SALES



	







