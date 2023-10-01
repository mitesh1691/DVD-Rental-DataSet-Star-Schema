# DVD-Rental-DataSet-Star-Schema

This project focuses on converting a DVD rental database schema into a star schema using SQL. The star schema is a simplified and user-friendly way to organize data, making it perfect for data warehousing and business intelligence purposes.

## Table Structure

The star schema comprises four dimension tables (`dimDate`, `dimCustomer`, `dimFilm`, `dimStore`) and one fact table (`factSales`), each designed to capture different aspects of the DVD rental data:

### Dimension Tables

1. **dimDate**: Contains date-related information like date key, date, year, quarter, month, day, week, and whether it's a weekend date.
2. **dimCustomer**: Stores customer details such as customer key, customer ID, name, contact info, address, and activity status.
3. **dimFilm**: Holds film-related data, including film key, title, description, release year, language, duration, length, rating, and special features.
4. **dimStore**: Contains store-specific data like store key, store ID, address, manager's name, and operational dates.

### Fact Table

- **factSales**: Serves as the fact table in the star schema. It references the dimension tables for date, customer, film, and store using foreign keys. The `sales_amount` column stores the sales amount associated with each transaction.

## Data Insertion

Data insertion into the dimension tables involves a series of SQL scripts that transform data from the original relational database tables into the star schema format. Key data transformations and mappings are performed during this process. For example, in the `dimDate` table, date-related attributes are extracted and weekend information is determined.

## Testing

To highlight the benefits of the star schema for analytical queries, two SQL queries are provided for testing:

### Star Schema Query

This query retrieves film titles, months, cities, and sales revenue from the `factSales` table and dimension tables. It showcases the advantage of the star schema for analytical purposes.

### 3NF Schema Query

This query retrieves similar information but directly from the relational database tables, representing a 3rd normal form (3NF) schema.

## Note

- To successfully execute the SQL code, ensure you provide the necessary data sources (e.g., `payment`, `customer`, `address`, `film`, `rental`, `inventory`, `staff`).

By undertaking this project, I have gained valuable experience in creating a star schema using SQL and gained insights into the advantages it offers for data analysis.
