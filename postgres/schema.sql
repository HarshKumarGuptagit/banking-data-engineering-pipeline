create table customers (
	id SERIAL primary key,
	first_name VARCHAR(100) not null,
	last_name VARCHAR(100) not null,
	email VARCHAR(255) unique not null,
	created_at timestamp with time zone default now()
);

create table accounts (
	id SERIAL primary key,
	customer_id integer not null referenceS customers(id) on delete cascade,
	account_type VARCHAR(50) not null,
	balance numeric(18,2) not null default 0 check (balance >= 0),
	currency CHAR(3) not null default 'USD',
	created_at timestamp with time zone default now()
);

create table transactions (
	id serial primary key,
	account_id integer not null references accounts(id) on delete cascade,
	txn_type VARCHAR(50) not null,
	amount NUMERIC(18,2) not null check (amount>0),
	related_account_id INT NULL,
	status VARCHAR(20) not null default 'COMPLETED',
	created_at TIMESTAMP with TIME zone default NOW()
);