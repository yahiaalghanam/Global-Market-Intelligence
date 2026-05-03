# 🌍 Global Market Intelligence

A modern **data analytics platform** that integrates **gold prices, currency exchange rates, and inflation indicators** into a unified analytical system to generate actionable economic insights.

---

## 📌 Overview

This project builds an **end-to-end data pipeline and analytics solution** designed to:

* Track global and local market indicators
* Analyze relationships between **gold, currencies, and inflation**
* Enable **data-driven decision making** through dashboards

The system follows a layered architecture (**Bronze → Silver → Gold**) to ensure scalability, data quality, and analytical flexibility.

---

## 🎯 Objectives

* Build a **centralized data warehouse** for economic indicators
* Transform raw data into **clean, structured datasets**
* Generate **insights on market trends and correlations**
* Deliver **interactive dashboards (Power BI)** for stakeholders

---

## 🏗️ Architecture

<img src="Images/DWH Archeticture.png" width="900"/>


### 🔹 Data Layers

#### 1. Bronze Layer (Raw Data)

* Ingests raw data from multiple sources
* Minimal transformation
* Stores:

  * Gold prices
  * Currency exchange rates (USD, EUR, SAR, etc.)
  * Inflation data

---

#### 2. Silver Layer (Cleaned Data)

* Data cleaning and normalization
* Handling missing values and inconsistencies
* Feature engineering:

  * Price changes
  * Spread calculations
  * Trend indicators

---

#### 3. Gold Layer (Business-Level Data)

* Aggregated and analytics-ready tables
* Optimized for reporting and dashboards
* Supports:

  * KPI calculations
  * Trend analysis
  * Correlation insights

---

# 🔧 Data Pipeline Implementation

## ⚙️ Stored Procedures

The pipeline is automated using SQL stored procedures for each processing stage:

### 🥉 Bronze Layer Procedure

* Responsible for loading raw data into the bronze tables
* Handles initial ingestion from source

### 🥈 Silver Layer Procedure

* Cleans and transforms data from bronze
* Applies business logic and calculations:

  * Spread calculation
  * Price change
  * Trend classification
* Standardizes all currencies into a unified format

---

## 🥇 Gold Layer (Views)

Instead of physical tables, the Gold layer is implemented using **SQL Views**:

### Why Views?

* Always reflects latest data
* No data duplication
* Optimized for Power BI consumption

## 🥈 Cleaned Data (Silver Layer)

### Improvements:

* Continuous date series
* Standardized schema across currencies
* Added:

  * `egp_price`
  * `spread`
  * `price_change`
  * `trend`
---

## 📊 Data Model

Core datasets include:

* **Gold Prices**
* **Currencies**

  * USD
  * EUR
  * SAR
* **Inflation Indicators**

  * Headline
  * Core
  * Regulated items
  * Fruits & vegetables

---

## ⚙️ Technologies Used

* **SQL Server** → Data storage & transformation
* **Power BI** → Data visualization & dashboards
* **ETL Concepts** → Data pipeline design
* **Data Warehousing** → Layered architecture

---

## 📈 Key Features

* 📅 Time-series tracking of economic indicators
* 🔄 Automated data transformation pipeline
* 📊 Interactive dashboards for insights
* 📉 Trend & volatility analysis
* 🔗 Correlation between:

  * Gold prices
  * Exchange rates
  * Inflation

---

## 📊 Example Insights

* Relationship between **gold price and inflation trends**
* Currency fluctuations impact on **local gold prices**
* Identification of **market volatility periods**
* Spread analysis across currencies

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/yahiaalghanam/Global-Market-Intelligence.git
cd Global-Market-Intelligence
```

### 2. Setup Database

* Create a SQL Server database
* Run scripts in order:

  * Bronze layer
  * Silver layer
  * Gold layer

### 3. Connect Power BI

* Load Gold layer tables
* Build dashboards using provided model

---

## 📊 Dashboard Components

* Latest gold price (dynamic KPI)
* Currency comparison charts
* Inflation trend analysis
* Market correlation visuals

---

## 📂 Project Structure

```
Global-Market-Intelligence/
│── bronze/        # Raw data ingestion
│── silver/        # Cleaned & transformed data
│── gold/          # Analytical layer
│── dashboards/    # Power BI reports
│── scripts/       # SQL transformations
```

---

## 🧠 Business Value

This project demonstrates:

* Strong **data engineering fundamentals**
* Real-world **financial analytics use case**
* Ability to transform raw data into **decision-ready insights**
* End-to-end ownership of a **data pipeline + BI solution**

---

## 📌 Future Improvements

* Real-time data ingestion (streaming)
* Predictive analytics (ML models)
* API integration for live market data
* Advanced financial indicators

---

## 🤝 Contributing

Contributions are welcome. Feel free to fork the repo and submit pull requests.

---

## 📄 License

This project is for educational and portfolio purposes.

---

## 👤 Author

**Yahia Alghanam**
Data & Analytics Engineer 
