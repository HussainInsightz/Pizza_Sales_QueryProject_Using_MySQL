# Basic Query
# Q1) Total no of order place

select * from pizzadata.orders;
select count(order_id) as total_order from pizzadata.orders;

# Q2) Calculate the total Revenue generated from pizza sales. beautify(ctrl + B)

select Round(sum(order_details.quantity * pizzas.price)) as total_pizza_revenue
from order_details join pizzas 
on order_details.pizza_id = pizzas.pizza_id;

select round(sum(order_details.quantity * pizzas.price),0) as total_revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id;

# Q3) Identify the highest price 

select pizza_types.`name`, pizzas.price
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;

# Q4) Identify the most common pizza size order

select order_details.quantity, count(order_details.order_details_id)
from order_details group by order_details.quantity;

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count desc;

# Q5) list the 5 most ordered pizza types along with there quantities

select pizza_types.`name`, sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.`name` order by quantity desc limit 5;

#---------------------------------------------------------------------------------------------------------

# Intermediate Query
# Q1) Join the necessory tables to find the total quantity of each pizza category ordered 

select pizza_types.category, sum(order_details.quantity) as qty_pizza_category
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by qty_pizza_category desc;

# Q2) Determine the distribution of order by hour of the day

select hour(order_time) as hour, count(order_id) as order_count from orders
group by hour(order_time);

# Q3) Join relevant tables to find the category wise distribution of pizzas

select category, count(`name`) from pizza_types
group by category;

# Q4) group the orders by date and calculate the average number of pizzas ordered per day

select round(avg(quantity),0) as Avg_pizza_order_per_day from 
(select orders.order_date, sum(order_details.quantity) as quantity
from orders join order_details 
on orders.order_id = order_details.order_id
group by orders.order_date) as order_qty;

# Q4) Determine the top 3 ordered pizza types based on revenue

select pizza_types.`name`, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.`name` order by revenue desc limit 3;

# Advance Query
# Q1) Calculate the percentage contribution of each pizza type to total revenue 

select pizza_types.category, round(sum(order_details.quantity * pizzas.price) / 817860 * 100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc;

# Q2) Analyse the cummilative revenue generated over the time 

select order_date, sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, round(sum(order_details.quantity * pizzas.price),0) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales ;

# Q3) Determine the top 3 most ordered pizza types based on revenue for each pizza category

select category, `name`, revenue 
from
(select category,`name`, revenue, rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.`name`, round(sum(order_details.quantity * pizzas.price),0) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.`name`) as a) as b 
where rn <= 3;