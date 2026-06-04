--Create Staging DB 

CREATE DATABASE DP_WORLD_DB;
USE DP_WORLD_DB;
CREATE SCHEMA Staging;
-------------------------------------------------------------------------------------------------

CREATE TABLE Staging.ContainerMovements (
 Movement_Id INT,
 Vessel_Call_Id INT,
 Container_No VARCHAR(20),
 Container_Size VARCHAR(10),
 Move_Type VARCHAR(10),
 Equipment_Id INT,
 Shift_Id INT,
 Customer_Id INT,
 Terminal_Id INT,
 Move_Start_Time DATETIME,
 Move_End_Time DATETIME,
 Is_Reefer BIT,
 Weight_Tons FLOAT
 )

 SELECT * FROM Staging.ContainerMovements;
--------------------------------------------------------------------------------------------------

 CREATE TABLE Staging.VesselCalls (
 Vessel_Call_Id INT,
 Vessel_Name VARCHAR(50),
 Voyage_No VARCHAR(10),
 Customer_Id INT,
 Terminal_Id INT,
 ETA DATETIME,
 ATA DATETIME,
 ATD DATETIME,
 Total_Moves_Planned INT,
 Total_Moves_Actual INT,
 Status VARCHAR(10) ,
 )

SELECT * FROM Staging.VesselCalls;
--------------------------------------------------------------

CREATE TABLE Staging.GateTransactions (
 Gate_Txn_Id INT,
 Truck_Plate VARCHAR(10),
 Container_No VARCHAR(20),
 Customer_Id INT,
 Terminal_Id INT,
 Direction VARCHAR(5),
 Gate_In_Time DATETIME,
 Gate_Out_Time DATETIME,
 Shift_Id INT,
 )

SELECT * FROM Staging.GateTransactions;
-----------------------------------------------------
 CREATE TABLE Staging.Customers (
 Customer_Id INT,
 Customer_Code VARCHAR(10),
 Customer_Name VARCHAR(50),
 Country VARCHAR(10),
 Customer_Tier VARCHAR(50),
 Credit_Limit Int,
 Active_Flag Bit,
 OnBoarded_Date DATE,
 )

SELECT * FROM Staging.Customers;
------------------------------------------------------------------
CREATE TABLE Staging.CustomerHistory (
 Customer_Id INT,
 Effective_From DATE,
 Effective_To DATE,
 Customer_Tier VARCHAR(50),
 Credit_Limit Int,
 Change_Reason VARCHAR(20)
 )
	
SELECT * FROM Staging.CustomerHistory;
------------------------------------------------------------
CREATE TABLE Staging.Terminals (
 Terminal_Id INT,
 Terminal_Code VARCHAR(10),
 Terminal_Name VARCHAR(50),
 Zone VARCHAR(20),
 Terminal_Type VARCHAR(50),
 )

 SELECT * FROM Staging.Terminals;
------------------------------------------------------------
 CREATE TABLE Staging.Equipment (
 Equipment_Id INT,
 Equipment_Code VARCHAR(10),
 Equipment_Type VARCHAR(50),
 Terminal_Id INT,
 Capacity_Tons INT,
 Acquired_Date DATE,
 Status VARCHAR(20)
 )

SELECT * FROM Staging.Equipment;
--------------------------------------------------------------------
CREATE TABLE Staging.Shifts (
 Shift_Id INT,
 Shift_Code VARCHAR(10),
 Shift_Name VARCHAR(50),
 Start_Time TIME,
 End_Time TIME,
 )

 SELECT * FROM Staging.Shifts;
