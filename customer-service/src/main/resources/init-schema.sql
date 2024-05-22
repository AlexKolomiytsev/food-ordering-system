DROP SCHEMA if exists customer CASCADE;

CREATE SCHEMA customer;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE customer.customers (
    id uuid NOT NULL,
    username character varying COLLATE pg_catalog."default" NOT NULL,
    first_name character varying COLLATE pg_catalog."default" NOT NULL,
    last_name character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT customer_pkey PRIMARY KEY (id)
);

DROP MATERIALIZED VIEW IF EXISTS customer.order_customer_m_view;

CREATE MATERIALIZED VIEW customer.order_customer_m_view TABLESPACE pg_default
AS
    SELECT id,
           username,
           first_name,
           last_name
    FROM customer.customers
WITH DATA;

refresh materialized view customer.order_customer_m_view;

DROP function IF exists customer.refresh_order_customer_m_view;

CREATE OR replace function customer.refresh_order_customer_m_view()
RETURNS trigger
as '
BEGIN
    REFRESH MATERIALIZED VIEW customer.order_customer_m_view;
    RETURN null;
END;
' language plpgsql;

DROP trigger IF exists refresh_order_customer_m_view ON customer.customers;

CREATE trigger refresh_order_customer_m_view
AFTER INSERT OR UPDATE OR DELETE OR truncate
ON customer.customers FOR each statement
EXECUTE PROCEDURE customer.refresh_order_customer_m_view();

