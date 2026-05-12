# Telco Project - i2i Systems Database Case Study

## Project Overview

This project is prepared for the i2i Systems telecom database case study.

The main purpose of the project is to design a relational database schema by using the given telecom CSV files and to write SQL queries for customer, tariff, usage and payment analysis.

The dataset contains customer information, tariff package information and monthly usage/payment records. Based on these files, I created Oracle-compatible SQL table creation scripts and query solutions.

---

## Dataset Files

The project uses three CSV files:

| File Name | Description |
|---|---|
| `CUSTOMERS.csv` | Contains customer information such as customer ID, name, city, signup date and tariff ID |
| `TARIFFS.csv` | Contains tariff package details such as monthly fee, data limit, minute limit and SMS limit |
| `MONTHLY_STATS.csv` | Contains monthly usage values and payment status for customers |

---

## Repository Structure

```text
telco-project/
│
├── CUSTOMERS.csv
├── MONTHLY_STATS.csv
├── TARIFFS.csv
├── README.md
│
└── sql/
    ├── TABLE_CREATION_SCRIPTS.sql
    └── SOLUTIONS.sql
