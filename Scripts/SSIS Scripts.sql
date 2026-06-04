
-- Fact-ContainerMovements

 SELECT Movement_Id,Vessel_Call_Id,Container_No,
        Move_Type,Equipment_Id,Shift_Id,Customer_Id,Terminal_Id,
		Move_Start_Time,Move_End_Time,
		CAST(Move_Start_Time AS DATE) AS Move_StartDate,
		CAST(Move_Start_Time AS time) AS Move_StartTime,
		CAST(Move_End_Time AS DATE) AS Move_EndDate,
		CAST(Move_End_Time AS time) AS Move_EndTime,
		Weight_Tons
 FROM [DP_WORLD_DB].Staging.ContainerMovements;


 SELECT VesselCall_Key,VesselCall_Id
 FROM Dim_VesselCall
 WHERE Is_Current=1;

 SELECT  Container_Key,Container_No
 FROM Dim_Container
 WHERE Is_Current=1;

 SELECT MoveType_Key,Move_Type  
 FROM Dim_MoveType
 WHERE Is_Current=1;

 SELECT Equipment_Key,Equipment_Id 
 FROM Dim_Equipment
 WHERE Is_Current=1;

 SELECT Shift_Key,Shift_Id
 FROM Dim_Shift
 WHERE Is_Current=1;

 SELECT Customer_Key,Customer_Id
 FROM Dim_Customer
 WHERE Is_Current=1;

 SELECT Terminal_Key,Terminal_Id
 FROM Dim_Terminal
 WHERE Is_Current=1;

 SELECT DateKey as Move_StartDate_Key ,FullDate
 FROM Dim_Date;

 SELECT DateKey as Move_EndDate_Key ,FullDate
 FROM Dim_Date;

 SELECT TimeKey as Move_StartTime_Key ,FullTime
 FROM DimTime;

 SELECT TimeKey as Move_EndTime_Key ,FullTime
 FROM DimTime;

 SELECT Move_End_Time,Move_Start_Time ,Move_End_Time-Move_Start_Time AS Move_Duration_Mins
 FROM [DP_WORLD_DB].[Staging].[ContainerMovements]

 SELECT
    Move_Start_Time,
    Move_End_Time,
    DATEDIFF(MINUTE, Move_Start_Time, Move_End_Time) AS Move_Duration_Mins
FROM [DP_WORLD_DB].[Staging].[ContainerMovements];

SELECT * FROM Fact_ContainerMovements;

------------------------------------------------------------------------------------------------------------

-- Fact_VesselCalls

SELECT Vessel_Call_Id,Customer_Id,Terminal_Id,
       ETA,ATA,ATD,
	   CAST( ETA AS DATE ) AS ETA_Date,
	   CAST( ATA AS DATE ) AS ATA_Date,
	   CAST( ATD AS DATE ) AS ATD_Date,
	   Total_Moves_Planned,Total_Moves_Actual
FROM [DP_WORLD_DB].[Staging].[VesselCalls];

SELECT VesselCall_Key,VesselCall_Id
FROM Dim_VesselCall
WHERE Is_Current=1;

SELECT Customer_Key,Customer_Id
FROM Dim_Customer
WHERE Is_Current=1;

SELECT Terminal_Key , Terminal_Id
FROM Dim_Terminal
WHERE Is_Current=1;

SELECT DateKey AS ETA_Date_Key , FullDate
FROM Dim_Date;

SELECT DateKey AS ATA_Date_Key , FullDate
FROM Dim_Date;

SELECT DateKey AS ATD_Date_Key , FullDate
FROM Dim_Date;

SELECT * FROM Fact_VesselCalls;


-------------------------------------------------------------------------------------

-- Fact_GateTransactions

SELECT Gate_Txn_Id,Truck_Plate,Container_No,Customer_Id,Terminal_Id,Direction,Shift_Id,
       CAST (Gate_In_Time AS DATE) AS GateInDate,
	   CAST( Gate_In_Time AS TIME) AS GateInTime,
	   CAST( Gate_Out_Time AS DATE ) AS GateOutDate,
	   CAST( Gate_Out_Time AS Time ) AS GateOutTime,
	   Gate_In_Time,
	   Gate_Out_Time
FROM [DP_WORLD_DB].[Staging].[GateTransactions]


SELECT  Container_Key , Container_No
FROM Dim_Container
WHERE Is_Current = 1;

SELECT Customer_Key,Customer_Id
FROM Dim_Customer
WHERE Is_Current = 1;

SELECT Terminal_Key,Terminal_Id
FROM Dim_Terminal
WHERE Is_Current = 1;

SELECT Shift_Key,Shift_Id
FROM Dim_Shift
WHERE Is_Current = 1;

SELECT GateDirection_Key , Direction
FROM Dim_GateDirection
WHERE Is_Current = 1;

SELECT DateKey as Gate_In_Date_Key,FullDate
FROM Dim_Date

SELECT DateKey as Gate_Out_Date_Key,FullDate
FROM Dim_Date

SELECT TimeKey as Gate_In_Time_Key,FullTime
FROM DimTime

SELECT TimeKey as Gate_Out_Time_Key,FullTime
FROM DimTime

------------------------------------------------------------

--Incremental Load

SELECT LastID 
FROM ETL_Control_Metadata
WHERE TableName='ContainerMovements';

UPDATE ETL_Control_Metadata
SET LastID=?
WHERE WHERE TableName='ContainerMovements';


SELECT Max([Movement_Id]) AS Movement_Id
FROM [DP_WORLD_DB].[Staging].[ContainerMovements]

SELECT LastID 
FROM ETL_Control_Metadata
WHERE TableName='GateTransactions';


SELECT Max(Gate_Txn_Id) AS Gate_Txn_Id
FROM [DP_WORLD_DB].[Staging].[GateTransactions]
