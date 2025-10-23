import csv
import random
from datetime import datetime
from faker import Faker


fake = Faker()

# Configuration
num_orders = 2000          # Number of orders to generate
min_customer_id = 1        # customer IDs range from 1 to 1000
max_customer_id = 1000
orders_filename = 'orders.csv'
order_items_filename = 'order_items.csv'
customers_filename = 'customers.csv'

# Generate orders.csv with columns: order_id, customer_id, order_date
with open(orders_filename, 'w', newline='') as orders_file:
    orders_writer = csv.writer(orders_file)
    orders_writer.writerow(['order_id', 'customer_id', 'order_date'])
    orders_data = []  # To store order_ids for order_items generation
    for order_id in range(1, num_orders + 1):
        customer_id = random.randint(min_customer_id, max_customer_id)
        # Generate a random datetime within the last 365 days
        order_date = fake.date_time_between(start_date='-365d', end_date='now')
        orders_writer.writerow([order_id, customer_id, order_date])
        orders_data.append(order_id)

# Generate order_items.csv with columns: order_item_id, order_id, product_id, quantity, price
order_item_id = 1
with open(order_items_filename, 'w', newline='') as items_file:
    items_writer = csv.writer(items_file)
    items_writer.writerow(['order_item_id', 'order_id', 'product_id', 'quantity', 'price'])
    for order_id in orders_data:
        # For each order, generate between 1 and 3 order items
        num_items = random.randint(1, 3)
        for _ in range(num_items):
            product_id = random.randint(1, 100000)  # Assuming product IDs from 1 to 100000
            quantity = random.randint(1, 5)
            # Generate a random price, for example between 10.00 and 100.00 or mimic your product range
            price = round(random.uniform(10.00, 20000.00), 2)
            items_writer.writerow([order_item_id, order_id, product_id, quantity, price])
            order_item_id += 1


with open(customers_filename, 'w', newline='') as customers_file:
    writer = csv.writer(customers_file)
    # Write header row
    writer.writerow(['first_name', 'last_name', 'email'])
    
    # Generate fake customer data
    for _ in range(max_customer_id):
        writer.writerow([fake.first_name(), fake.last_name(), fake.email()])


print("All done!")