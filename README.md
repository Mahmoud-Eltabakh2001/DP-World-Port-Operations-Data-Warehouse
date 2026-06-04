# DP-World-Port-Operations-Data-Warehouse

## Overview

This project implements an end-to-end Data Warehouse solution for Port Operations data using SQL Server and SQL Server Integration Services (SSIS).

The solution extracts operational data from Excel files, loads it into staging tables, transforms it into a dimensional model, and supports both Full Load and Incremental Load strategies for analytical reporting.

---

## Architecture

### Data Flow Architecture

```text
Excel Files
    │
    ▼
Staging Database
    │
    ▼
Dimension Packages
    │
    ▼
Fact Packages
    │
    ▼
Data Warehouse
    │
    ▼
Reporting & Analytics
```

### Data Warehouse Model

The warehouse follows a Star Schema design consisting of:

#### Fact Tables

* FactContainerMovements
* FactVesselCalls
* FactGateTransactions

#### Dimension Tables

* DimContainer
* DimCustomer (SCD Type 2)
* DimTerminal
* DimEquipment
* DimShift
* DimDate
* DimTime
* DimMoveType
* DimGateDirection
* DimVesselCall

---

## Data Model

Architecture Diagram:

![Port Operations Data Warehouse Architecture][Screens](DWH Architecture.png)

---

## ETL Implementation

The ETL process was implemented using SQL Server Integration Services (SSIS).

### Stage 1 – Source to Staging

A dedicated SSIS package loads the source Excel files into SQL Server staging tables.

Source datasets include:

* ContainerMovements
* VesselCalls
* GateTransactions
* Customers
* CustomerHistory
* Equipment
* Terminals
* Shifts

---

### Stage 2 – Dimension Loading

Each dimension is loaded through an independent SSIS package.

#### Dimension Packages

| Package           | Description                     |
| ----------------- | ------------------------------- |
| Dim_Container     | Container master data           |
| Dim_MoveType      | Container movement types        |
| Dim_Terminal      | Terminal information            |
| Dim_Customer      | Customer dimension (SCD Type 2) |
| Dim_Shift         | Operational shifts              |
| Dim_Equipment     | Equipment information           |
| Dim_Date          | Calendar dimension              |
| Dim_Time          | Time dimension                  |
| Dim_GateDirection | Gate transaction direction      |
| Dim_VesselCall    | Vessel call information         |

---

### Dimension Orchestration

A master package named:

```text
Dims Package
```

uses:

* Sequence Container
* Execute Package Task

to execute all dimension packages in the correct order through a single workflow.

---

## Slowly Changing Dimension (SCD Type 2)

DimCustomer is implemented as a Type 2 Slowly Changing Dimension.

Additional columns:

| Column         | Description        |
| -------------- | ------------------ |
| Effective_From | Record start date  |
| Effective_To   | Record end date    |
| Is_Current     | Active record flag |

Customer history changes are preserved by creating new versions of records instead of overwriting existing values.

---

## Metadata Columns

All dimensions contain ETL metadata columns:

| Column     | Description               |
| ---------- | ------------------------- |
| Created_At | Record creation timestamp |
| SSC        | Source System Code        |

These columns provide lineage and auditability.

---

## Date Dimension Generation

DimDate is generated dynamically using Execute SQL Task.

The package:

1. Retrieves the minimum and maximum dates from source transactional tables.
2. Applies a configurable buffer period.
3. Generates a complete calendar dimension.

Sources used:

* ContainerMovements
* VesselCalls
* GateTransactions

---

## Time Dimension Generation

DimTime is generated programmatically and contains:

* TimeKey
* FullTime
* Hour
* Minute
* Second
* Period (AM/PM)
* TimeBand

The dimension is generated at second-level granularity.

---

## Fact Tables

### FactContainerMovements

Grain:

One record per container movement.

Measures:

* MoveDuration_Mins
* Weight_Tons

---

### FactVesselCalls

Grain:

One record per vessel call.

Measures:

* Turnaround_Hours
* Delay_Mins
* Total_Moves_Planned
* Total_Moves_Actual

---

### FactGateTransactions

Grain:

One record per gate transaction.

Measures:

* GateProcessing_Duration_Mins

---

## Full Load Strategy

Each fact table has a dedicated Full Load package.

Process:

```text
TRUNCATE TABLE
        +
INSERT ALL DATA
```

Available for:

* FactContainerMovements
* FactVesselCalls
* FactGateTransactions

---

## Incremental Load Strategy

Each fact table also has a dedicated Incremental Load package.

The implementation uses sequential business keys as watermarks.

### FactContainerMovements

```text
Movement_Id
```

### FactGateTransactions

```text
Gate_Txn_Id
```

### FactVesselCalls

```text
VesselCall_Id
```

Only records with keys greater than the previously loaded value are processed.

This approach improves performance and reduces ETL execution time.

---

## Repository Structure

```text
├── Excel Files
├── SQL Scripts
│
├── SSIS
│   ├── Source_To_Staging
│   ├── Dimensions
│   │   ├── Dim_Container
│   │   ├── Dim_Customer
│   │   ├── Dim_Date
│   │   ├── Dim_Equipment
│   │   ├── Dim_GateDirection
│   │   ├── Dim_MoveType
│   │   ├── Dim_Shift
│   │   ├── Dim_Terminal
│   │   ├── Dim_Time
│   │   └── Dim_VesselCall
│   │
│   ├── Facts
│   │   ├── Full_Load
│   │   └── Incremental_Load
│   │
│   └── Dims_Package
│
├── Architecture
│   └── architecture.png
│
└── README.md
```

---

## Key Features

* Star Schema Design
* SQL Server Data Warehouse
* SSIS ETL Pipelines
* Incremental Loading
* Full Loading
* SCD Type 2 Implementation
* Metadata & Data Lineage Tracking
* Date & Time Dimensions
* Modular Package Design
* Centralized Dimension Orchestration

---

## Author

Mahmoud Reda

Data Engineer
