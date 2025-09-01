CREATE DATABASE pizzahut;
USE pizzahut;

CREATE TABLE tbl_order (
    order_id INT NOT NULL PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);

CREATE TABLE tbl_orderdetails (
    order_details_id INT NOT NULL PRIMARY KEY,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL
);

ALTER TABLE pizza_types RENAME TO tbl_pizza_types;
ALTER TABLE pizzas RENAME TO tbl_pizzas;
ALTER TABLE tbl_orderdetails RENAME TO tbl_order_details;


-- Retrieve the total number of orders placed.

SELECT count(order_id) as total_orders FROM tbl_order;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price)) as Total_Sales
FROM
    tbl_order_details AS o
        JOIN
    tbl_pizzas AS p ON o.pizza_id = p.pizza_id;
    
   --  Identify the highest-priced pizza.
   
  SELECT 
    pt.name, p.price
FROM
    tbl_pizza_types AS pt
        JOIN
    tbl_pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(od.order_id) AS Count_order
FROM
    tbl_pizzas AS p
        JOIN
    tbl_order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY Count_order DESC;

-- list the top 5 most ordered pizza types along with their quantities.

SELECT pt.name,Sum(od.order_id*od.quantity)as top_5
FROM tbl_order_details As od 
join tbl_pizzas as p  on p.pizza_id = od.pizza_id 
join tbl_pizza_types as pt    on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by top_5 desc limit 5 ;   -- check 


SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    tbl_order_details AS od
        JOIN
    tbl_pizzas AS p ON p.pizza_id = od.pizza_id
        JOIN
    tbl_pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category,
    SUM(od.order_id * od.quantity) AS Total_quantity
FROM
    tbl_order_details AS od
        JOIN
    tbl_pizzas AS p ON p.pizza_id = od.pizza_id
        JOIN
    tbl_pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category 
ORDER BY total_quantity DESC;   

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_time) AS order_count
FROM
    tbl_order
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    tbl_pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
 SELECT 
   round( Avg(quantity)) as avg_pizza_order_per_day
FROM
    (SELECT 
        tbl_order.order_date,
            SUM(tbl_order_details.quantity) AS quantity
    FROM
        tbl_order
    JOIN tbl_order_details ON tbl_order.order_id = tbl_order_details.order_id
    GROUP BY tbl_order.order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    tbl_pizza_types.name,
    SUM(tbl_order_details.quantity * tbl_pizzas.price) AS revenue
FROM
    tbl_pizzas
        JOIN
    tbl_pizza_types ON tbl_pizzas.pizza_type_id = tbl_pizza_types.pizza_type_id
        JOIN
    tbl_order_details ON tbl_order_details.pizza_id = tbl_pizzas.pizza_id
GROUP BY tbl_pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    tbl_pizza_types.category,
    ROUND((SUM(tbl_order_details.quantity * tbl_pizzas.price) / (SELECT 
                    SUM(tbl_order_details.quantity * tbl_pizzas.price) AS Total_Sales
                FROM
                    tbl_order_details
                        JOIN
                    tbl_pizzas ON tbl_order_details.pizza_id = tbl_pizzas.pizza_id)) * 100,
            2) AS revenue_percentage
FROM
    tbl_pizzas
        JOIN
    tbl_pizza_types ON tbl_pizzas.pizza_type_id = tbl_pizza_types.pizza_type_id
        JOIN
    tbl_order_details ON tbl_order_details.pizza_id = tbl_pizzas.pizza_id
GROUP BY tbl_pizza_types.category
ORDER BY revenue_percentage DESC
LIMIT 3;


