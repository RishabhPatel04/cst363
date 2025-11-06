-- DDL generated from the provided ERD image (public schema)
-- Tables: Customers, address, Order, payment, product
-- Relationships:
--   Customers has many address (address.customer_id -> Customers.customer_id)
--   Customers has many Order (Order.customer_id -> Customers.customer_id)
--   Order has one payment (payment.order_id -> Order.order_id, unique)
--   Many Order has many product (bridge table order_item)

set search_path to public;

create table if not exists Customers (
  customer_id integer primary key,
  first_name varchar(50) not null,
  last_name varchar(50) not null,
  email varchar(255) not null,
  phone varchar(30),
  created_at timestamp not null default now(),
  constraint uq_customer_email unique (email)
);

create table if not exists address (
  address_id integer primary key,
  customer_id integer not null,
  line1 varchar(100) not null,
  line2 varchar(100),
  city varchar(50) not null,
  state varchar(20) not null,
  postal_code varchar(20) not null,
  country varchar(60) not null,
  is_default boolean not null default false,
  created_at timestamp not null default now(),
  constraint address_customer_fk foreign key (customer_id)
    references Customers(customer_id) on delete cascade,
  constraint uq_address_customer_address unique
    (customer_id, line1, line2, city, state, postal_code, country)
);

create table if not exists "Order" (
  order_id integer primary key,
  customer_id integer not null,
  ship_to_address_id integer not null,
  status varchar(20) not null,
  ordered_at timestamp not null default now(),
  shipped_at timestamp,
  completed_at timestamp,
  canceled_at timestamp,
  constraint order_customer_fk foreign key (customer_id)
    references Customers(customer_id),
  constraint order_ship_address_fk foreign key (ship_to_address_id)
    references address(address_id),
  constraint ck_order_status check (status in (
    'NEW','PAID','SHIPPED','COMPLETED','CANCELED'
  ))
);

create table if not exists payment (
  payment_id integer primary key,
  order_id integer not null,
  amount decimal(10,2) not null,
  method varchar(20) not null,
  paid_at timestamp not null default now(),
  txn_reference varchar(100),
  constraint payment_order_fk foreign key (order_id)
    references "Order"(order_id) on delete cascade,
  constraint ux_payment_order unique (order_id),
  constraint ck_payment_amount_nonneg check (amount >= 0)
);

create table if not exists product (
  product_id integer primary key,
  sku varchar(64) not null,
  name varchar(120) not null,
  description text,
  current_unit_price decimal(10,2) not null,
  active boolean not null default true,
  created_at timestamp not null default now(),
  constraint uq_product_sku unique (sku)
);

create table if not exists order_item (
  order_id integer not null,
  product_id integer not null,
  quantity integer not null default 1,
  unit_price decimal(10,2) not null,
  primary key (order_id, product_id),
  constraint order_item_order_fk foreign key (order_id)
    references "Order"(order_id) on delete cascade,
  constraint order_item_product_fk foreign key (product_id)
    references product(product_id),
  constraint ck_order_item_qty_pos check (quantity > 0),
  constraint ck_order_item_price_nonneg check (unit_price >= 0)
);

-- Task 1 — Entity sets & attributes
-- Customer
-- customer_id (PK)
-- first_name, last_name
-- email (UNIQUE), phone
-- created_at
-- Address (customer-stored shipping addresses)
-- address_id (PK)
-- customer_id (FK → Customer)
-- line1, line2, city, state, postal_code, country
-- is_default (BOOL)
-- created_at
-- Order
-- order_id (PK)
-- customer_id (FK → Customer)
-- ship_to_address_id (FK → Address) — must belong to the same customer
-- status (e.g., ‘draft’, ‘placed’, ‘shipped’, ‘completed’, ‘canceled’)
-- ordered_at, shipped_at, completed_at, canceled_at
-- total_amount (DERIVED: do not store; = Σ(order_lines.quantity * order_lines.unit_price_at_sale))
-- Product
-- product_id (PK)
-- sku (UNIQUE)
-- name
-- description
-- current_unit_price
-- active (BOOL)
-- created_at
-- OrderLine (line items; associative entity between Order and Product)
-- order_line_id (PK)
-- (or composite PK: (order_id, line_no))
-- order_id (FK → Order)
-- product_id (FK → Product)
-- line_no (1,2,3… within an order) (useful if you choose composite PK)
-- quantity (INT > 0)
-- unit_price_at_sale (the captured unit price at time of sale)
-- line_total (OPTIONAL DERIVED = quantity * unit_price_at_sale; may store for convenience if allowed)
-- Payment (optional, one per order)
-- payment_id (PK)
-- order_id (FK → Order, UNIQUE) — enforces “zero or one payment per order”
-- amount (should equal derived order total at time of payment)
-- method (e.g., ‘card’, ‘cash’, ‘ach’)
-- status (‘authorized’, ‘captured’, ‘failed’, ‘refunded’)
-- paid_at
-- txn_reference
-- Task 2 — Relationship sets (with attributes/cardinalities)
-- Customer — places — Order
-- Cardinality: Customer 1 : M Order
-- Participation: Customer partial (a customer may have 0 orders); Order total (each order belongs to exactly 1 customer)
-- Attributes on relationship: none (all live on Order)
-- Customer — has — Address
-- Cardinality: Customer 1 : M Address
-- Participation: Customer partial; Address total (each address belongs to exactly 1 customer)
-- Attributes on relationship: none (Address holds them)
-- Order — ships_to — Address
-- Cardinality: Order M : 1 Address (each order ships to exactly one stored address)
-- Constraint: Address.customer_id must equal Order.customer_id (address must be owned by the ordering customer)
-- Participation: Order total (must have a shipping address); Address partial
-- Attributes on relationship: none (Order stores ship_to_address_id)
-- Order — contains — Product (via OrderLine)
-- Conceptual cardinality: Order M : N Product
-- Realized by associative entity OrderLine with attributes:
-- quantity, unit_price_at_sale (and optionally line_total)
-- Participation: Order total in OrderLine (≥1 line); Product partial (a product can be in 0+ orders)
-- Order — is_paid_by — Payment
-- Cardinality: Order 1 : 0..1 Payment
-- Participation: Order partial (unpaid allowed); Payment total (each payment pays exactly one order)
-- Attributes on relationship: none (Payment holds payment details)
-- Implementation: UNIQUE constraint on Payment.order_id enforces at most one payment per order