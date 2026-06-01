-- 1. GENDER-BASED REVENUE ANALYSIS
-- Insight: Understand revenue contribution by gender

select 
	gender,
	sum(purchase_amount) as total_revenue
from customer_transactions
group by gender;

-- 2. HIGH-SPENDING DISCOUNT USERS
-- Insight: Identify customers who still spend above average even after using discounts

select 
	customer_id, 
	purchase_amount
from customer_transactions
where discount_applied = 'Yes' 
	and purchase_amount >= (
		select avg(purchase_amount) from customer_transactions
	);

-- 3. TOP PRODUCTS BY AVERAGE RATING
-- Insight: Identify highest-rated products for quality focus

select 
	item_purchased, 
	round(avg(review_rating::numeric), 2) as avg_rating
from customer_transactions
group by item_purchased
order by avg(review_rating) desc
limit 5;

-- 4. SHIPPING TYPE VS CUSTOMER SPENDING
-- Insight: Compare spending behavior by shipping preference

select 
	shipping_type, 
	round(avg(purchase_amount), 2) as avg_purchase_amount
from customer_transactions
where shipping_type in ('Standard', 'Express')
group by shipping_type;

-- 5. SUBSCRIPTION IMPACT ON REVENUE
-- Insight: Do subscribed customers generate more value?

select 
	subscription_status, 
	count(customer_id) as total_customers,
	round(avg(purchase_amount), 2) as avg_spend,
	round(sum(purchase_amount), 2) as total_revenue
from customer_transactions
group by subscription_status
order by total_revenue desc;

-- 6. DISCOUNT USAGE RATE BY PRODUCT
-- Insight: Identify products most frequently sold with discounts

select 
	item_purchased,
	round(
		100 * sum(case when discount_applied = 'Yes' then 1 else 0 end)
		/count(*), 2
	) as discount_usage_percentage
from customer_transactions
group by item_purchased
order by discount_usage_percentage desc
limit 5;

-- 7. CUSTOMER SEGMENTATION BASED ON PURCHASE HISTORY
-- Insight: Segment customers into New, Returning, Loyal

with customer_segments as (
	select 
		customer_id, 
		previous_purchases,
		case
			when previous_purchases = 1 then 'New'
			when previous_purchases between 2 and 10 then 'Returning'
			else 'Loyal'
		end as segment
	from customer_transactions
)

select 
	segment, 
	count(*) as total_customers
from customer_segments
group by segment
order by total_customers desc;

-- 8. TOP PRODUCTS WITHIN EACH CATEGORY
-- Insight: Identify best-selling products per category

with ranked_products as (
	select 
		category,
		item_purchased,
		count(customer_id) as total_orders,
		row_number() over(
			partition by category 
			order by count(customer_id) desc
		) as rank
	from customer_transactions
	group by category, item_purchased
)

select 
	category, 
	item_purchased, 
	total_orders,
	rank
from ranked_products
where rank <= 3

-- 9. REPEAT BUYERS & SUBSCRIPTION RELATIONSHIP
-- Insight: Check if frequent buyers are more likely to subscribe

select 
	subscription_status,
	count(customer_id) as repeat_buyer_count
from customer_transactions
where previous_purchases > 5
group by subscription_status;

-- 10. REVENUE BY AGE GROUP
-- Insight: Identify high-value customer age segments

select 
	age_group,
	sum(purchase_amount) as total_revenue
from customer_transactions
group by age_group
order by total_revenue desc;
