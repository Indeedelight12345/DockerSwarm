-- create_table_script.sql

-- Step 1: Create a simple table
CREATE OR REPLACE TABLE example_table (
    id INT,
    name STRING,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Retrieve the DDL of the table
SELECT GET_DDL('TABLE', 'example_table');
