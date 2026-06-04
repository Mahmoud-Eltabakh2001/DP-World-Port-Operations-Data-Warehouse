CREATE DATABASE DP_World_WH;

USE DP_World_WH;

--Dim_MoveType
CREATE TABLE Dim_MoveType(
 MoveType_Key INT NOT NULL IDENTITY(1,1),
 Move_Type NVARCHAR(20) NOT NULL,

 StartDate DATE NOT NULL DEFAULT(GETDATE()),
 EndDate DATE NULL,
 Is_Current TINYINT NOT NULL DEFAULT(1),
 SSC TINYINT NOT NULL DEFAULT(1),

 CONSTRAINT pk_movetype PRIMARY KEY(MoveType_Key)
 );

 SELECT DISTINCT [Move_Type]
 FROM [DP_WORLD_DB].[Staging].[ContainerMovements]

 SELECT * FROM Dim_MoveType;
 --------------------------------------------------------------------------------------

 -- Dim_VesselCall
 CREATE TABLE Dim_VesselCall(
 VesselCall_Key INT NOT NULL IDENTITY(1,1),
 VesselCall_Id INT NOT NULL,
 Vessel_Name NVARCHAR(50) NOT NULL,
 Voyage_No NVARCHAR(20) NOT NULL,
 Status NVARCHAR(20) NOT NULL,

 StartDate DATE NOT NULL DEFAULT(GETDATE()),
 EndDate DATE NULL,
 Is_Current TINYINT NOT NULL DEFAULT(1),
 SSC TINYINT NOT NULL DEFAULT(1),

 CONSTRAINT pk_vesselcall PRIMARY KEY(VesselCall_Key)
 );

 SELECT DISTINCT [Vessel_Call_Id],[Vessel_Name],[Voyage_No],[Status]
 FROM [DP_WORLD_DB].[Staging].[VesselCalls]

 SELECT * FROM Dim_VesselCall
---------------------------------------------------------------------------------------------

--Dim_Terminal
 CREATE TABLE Dim_Terminal(
 Terminal_Key INT NOT NULL IDENTITY(1,1),
 Terminal_Id INT NOT NULL,
 Terminal_Code NVARCHAR(20) NOT NULL,
 Terminal_Name NVARCHAR(50) NOT NULL,
 Zone NVARCHAR(20),
 Terminal_Type NVARCHAR(50),

 StartDate DATE NOT NULL DEFAULT(GETDATE()),
 EndDate DATE NULL,
 Is_Current TINYINT NOT NULL DEFAULT(1),
 SSC TINYINT NOT NULL DEFAULT(1),

 CONSTRAINT pk_terminal PRIMARY KEY(Terminal_Key)
 );

 SELECT DISTINCT [Terminal_Id],[Terminal_Code],[Terminal_Name],[Zone],[Terminal_Type]
 FROM [DP_WORLD_DB].[Staging].[Terminals]

 SELECT * FROM Dim_Terminal;
 --------------------------------------------------------------------------------------------------

 --Dim_Customer
CREATE TABLE Dim_Customer(
 Customer_Key INT NOT NULL IDENTITY(1,1),
 Customer_Id INT NOT NULL ,
 Customer_Code NVARCHAR(20) NOT NULL,
 Customer_Name NVARCHAR(50) NOT NULL,
 Country NVARCHAR(10) NULL,
 Customer_Tier NVARCHAR(50) NOT NULL,
 Credit_Limit Int NOT NULL,
 Active_Flag TINYINT NOT NULL,
 OnBoarded_Date DATE NOT NULL,
 Effective_From DATE NOT NULL DEFAULT(GETDATE()),
 Effective_To DATE NULL,
 Change_Reason NVARCHAR(50) NOT NULL DEFAULT('Initial'),

 Is_Current TINYINT NOT NULL DEFAULT(1),
 SSC TINYINT NOT NULL DEFAULT(1),

 CONSTRAINT pk_customer PRIMARY KEY(Customer_Key)
 );

 SELECT DISTINCT [Customer_Id],[Customer_Code],[Customer_Name],[Country],[Customer_Tier],[Credit_Limit],
                 [Active_Flag],[OnBoarded_Date]
 FROM [DP_WORLD_DB].[Staging].[Customers] 
 -------


INSERT INTO [DP_WORLD_DB].[Staging].Customers
Values(13,'ASDF','Mahmoud','EGY','VIP',123456,1,'2025-05-23');

UPDATE [DP_WORLD_DB].[Staging].Customers
SET Customer_Tier='Platium'
WHERE Customer_Id=13;

UPDATE Dim_Customer
SET Change_Reason='Tier Change'
WHERE Effective_To IS NULL 
AND Customer_Id IN ( SELECT Customer_Id 
                FROM Dim_Customer
                GROUP BY (Customer_Id) 
				HAVING COUNT(Customer_Id) >1)
 ----------------------------------------------------------------------------------------------------------

 --Dim_GateDirection
 CREATE TABLE Dim_GateDirection(
 GateDirection_Key INT NOT NULL IDENTITY(1,1),
 Direction NVARCHAR(10) NOT NULL,

 StartDate DATE NOT NULL DEFAULT(GETDATE()),
 EndDate DATE NULL,
 Is_Current TINYINT NOT NULL DEFAULT(1),
 SSC TINYINT NOT NULL DEFAULT(1),

 CONSTRAINT pk_gatedirection PRIMARY KEY(GateDirection_Key)
 );

 SELECT DISTINCT Direction
 FROM [DP_WORLD_DB].[Staging].[GateTransactions]

 SELECT * FROM Dim_GateDirection;
 --------------------------------------------------------------------------------------------------------------

 --Dim_Shift
CREATE TABLE Dim_Shift(
 Shift_Key INT NOT NULL IDENTITY(1,1),
 Shift_Id INT NOT NULL,
 Shift_Code NVARCHAR(20) NOT NULL,
 Shift_Name NVARCHAR(50),
 Start_Time TIME,
 End_Time TIME,

 StartDate DATE NOT NULL DEFAULT(GETDATE()),
 EndDate DATE NULL,
 Is_Current TINYINT NOT NULL DEFAULT(1),
 SSC TINYINT NOT NULL DEFAULT(1),

 CONSTRAINT pk_Shift PRIMARY KEY(Shift_Key)
 );

 SELECT * FROM Dim_Shift;

 SELECT DISTINCT *
 FROM [DP_WORLD_DB].[Staging].[Shifts];
 ------------------------------------------------------------

 --Dim_Container
 CREATE TABLE Dim_Container(
 Container_Key INT NOT NULL IDENTITY(1,1),
 Container_No NVARCHAR(50),
 Length_ft INT ,
 Height_Type NVARCHAR(20),
 Is_Reefer BIT ,

 StartDate DATE NOT NULL DEFAULT(GETDATE()),
 EndDate DATE NULL,
 Is_Current TINYINT NOT NULL DEFAULT(1),
 SSC TINYINT NOT NULL DEFAULT(1),

 CONSTRAINT pk_Container PRIMARY KEY(Container_Key)
 );

 SELECT * FROM Dim_Container;
 SELECT * from [DP_WORLD_DB].[Staging].[ContainerMovements];

SELECT
    Container_No,
    Container_Size,
    LEFT(Container_Size,
         PATINDEX('%[^0-9]%', Container_Size) - 1) AS Length_ft,
    SUBSTRING(
        Container_Size,
        PATINDEX('%[^0-9]%', Container_Size),
        LEN(Container_Size)
    ) AS Height_Type,
   Is_Reefer
FROM [DP_WORLD_DB].[Staging].[ContainerMovements]



SELECT Container_No FROM [DP_WORLD_DB].[Staging].GateTransactions ;


WITH Containers AS
(
    SELECT Container_No
    FROM [DP_WORLD_DB].Staging.ContainerMovements

    UNION

    SELECT Container_No
    FROM [DP_WORLD_DB].Staging.GateTransactions
)
SELECT
    C.Container_No,
    CM.Container_Size,
    LEFT(
        CM.Container_Size,
        PATINDEX('%[^0-9]%', CM.Container_Size) - 1
    ) AS Length_ft,
    SUBSTRING(
        CM.Container_Size,
        PATINDEX('%[^0-9]%', CM.Container_Size),
        LEN(CM.Container_Size)
    ) AS Height_Type,
    CM.Is_Reefer 
FROM Containers C
LEFT JOIN
(
    SELECT
        Container_No,
        Container_Size,
        Is_Reefer,
        ROW_NUMBER() OVER
        (
            PARTITION BY Container_No
            ORDER BY Move_Start_Time DESC
        ) AS rn
    FROM [DP_WORLD_DB].Staging.ContainerMovements
) CM
    ON C.Container_No = CM.Container_No
   AND CM.rn = 1;

----------------------------------------------------------------------------------

-- DimTime
IF OBJECT_ID('dbo.DimTime', 'U') IS NOT NULL
    DROP TABLE dbo.DimTime;

CREATE TABLE dbo.DimTime
(
    TimeKey INT NOT NULL,
    FullTime TIME(0),
    HourNumber TINYINT,
    MinuteNumber TINYINT,
    SecondNumber TINYINT,
    Period NVARCHAR(2),
    TimeBand NVARCHAR(20),

	CONSTRAINT pk_time PRIMARY KEY(TimeKey)
);


WITH TimeSeries AS
(
    SELECT CAST('00:00:00' AS TIME(0)) AS TimeValue

    UNION ALL

    SELECT DATEADD(SECOND, 1, TimeValue)
    FROM TimeSeries
    WHERE TimeValue < '23:59:59'
)

INSERT INTO dbo.DimTime
(
    TimeKey,
    FullTime,
    HourNumber,
    MinuteNumber,
    SecondNumber,
    Period,
    TimeBand
)
SELECT
      DATEPART(HOUR, TimeValue) * 10000
    + DATEPART(MINUTE, TimeValue) * 100
    + DATEPART(SECOND, TimeValue) AS TimeKey
    ,TimeValue AS FullTime
    ,DATEPART(HOUR, TimeValue) AS HourNumber
    ,DATEPART(MINUTE, TimeValue) AS MinuteNumber
    ,DATEPART(SECOND, TimeValue) AS SecondNumber
    ,CASE
        WHEN DATEPART(HOUR, TimeValue) < 12 THEN 'AM'
        ELSE 'PM'
     END AS Period
    ,CASE
        WHEN DATEPART(HOUR, TimeValue) BETWEEN 0 AND 5 THEN 'Night'
        WHEN DATEPART(HOUR, TimeValue) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN DATEPART(HOUR, TimeValue) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
     END AS TimeBand
FROM TimeSeries
OPTION (MAXRECURSION 0);

SELECT * FROM dbo.DimTime


------------------------------------------------------------------------

--Dim_Equipment
CREATE TABLE Dim_Equipment
(
    Equipment_Key INT NOT NULL IDENTITY(1,1),
	Equipment_Id INT,
	Equipment_Code NVARCHAR(20),
	Equipment_Type NVARCHAR(50),
	Terminal_Key INT,
	Capacity_Tons INT,
	Acquired_Date DATE,
	Status NVARCHAR(20),

	StartDate DATE NOT NULL DEFAULT(GETDATE()),
    EndDate DATE NULL,
    Is_Current TINYINT NOT NULL DEFAULT(1),
    SSC TINYINT NOT NULL DEFAULT(1),

	CONSTRAINT pk_equipment PRIMARY KEY(Equipment_Key),
	CONSTRAINT fk_equipment_terminal FOREIGN KEY (Terminal_Key) 
	REFERENCES Dim_Terminal(Terminal_Key)
);

SELECT DISTINCT *
FROM [DP_WORLD_DB].[Staging].[Equipment];

SELECT * FROM Dim_Equipment;

SELECT Terminal_Key,Terminal_Id
FROM Dim_Terminal
WHERE Is_Current=1;

-----------------------------------------------------------------

--Dim_Date
CREATE TABLE Dim_Date
(
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    DayNumber TINYINT,
    MonthNumber TINYINT,
    MonthName VARCHAR(20),
    QuarterNumber TINYINT,
    YearNumber SMALLINT,
    DayOfWeekNumber TINYINT,
    DayOfWeekName VARCHAR(20),
    IsWeekend BIT
);

SELECT
    DATEADD(YEAR,-1, MIN(dt)) AS MinDate,
    DATEADD(YEAR, 1, MAX(dt)) AS MaxDate
FROM
(
    SELECT CAST(Move_Start_Time AS DATE) AS dt FROM [DP_WORLD_DB].[Staging].ContainerMovements WHERE Move_Start_Time IS NOT NULL
    UNION ALL
    SELECT CAST(Move_End_Time AS DATE) FROM [DP_WORLD_DB].[Staging].ContainerMovements WHERE Move_End_Time IS NOT NULL
    UNION ALL
    SELECT CAST(ETA AS DATE) FROM [DP_WORLD_DB].[Staging].VesselCalls WHERE ETA IS NOT NULL
    UNION ALL
    SELECT CAST(ATA AS DATE) FROM [DP_WORLD_DB].[Staging].VesselCalls WHERE ATA IS NOT NULL
    UNION ALL
    SELECT CAST(ATD AS DATE) FROM [DP_WORLD_DB].[Staging].VesselCalls WHERE ATD IS NOT NULL
    UNION ALL
    SELECT CAST(Gate_In_Time AS DATE) FROM [DP_WORLD_DB].[Staging].GateTransactions WHERE Gate_In_Time IS NOT NULL
    UNION ALL
    SELECT CAST(Gate_Out_Time AS DATE) FROM [DP_WORLD_DB].[Staging].GateTransactions WHERE Gate_Out_Time IS NOT NULL
) D;

WITH Dates AS
(
    SELECT CAST(? AS DATE) AS DateValue

    UNION ALL

    SELECT DATEADD(DAY,1,DateValue)
    FROM Dates
    WHERE DateValue < CAST(? AS DATE)
)

INSERT INTO dbo.Dim_Date
(
    DateKey,
    FullDate,
    DayNumber,
    MonthNumber,
    MonthName,
    QuarterNumber,
    YearNumber,
    DayOfWeekNumber,
    DayOfWeekName,
    IsWeekend
)
SELECT
      YEAR(DateValue) * 10000
    + MONTH(DateValue) * 100
    + DAY(DateValue)                AS DateKey
    ,DateValue                      AS FullDate
    ,DAY(DateValue)                 AS DayNumber
    ,MONTH(DateValue)               AS MonthNumber
    ,DATENAME(MONTH, DateValue)     AS MonthName
    ,DATEPART(QUARTER, DateValue)   AS QuarterNumber
    ,YEAR(DateValue)                AS YearNumber
    ,DATEPART(WEEKDAY, DateValue)   AS DayOfWeekNumber
    ,DATENAME(WEEKDAY, DateValue)   AS DayOfWeekName
    ,CASE
        WHEN DATENAME(WEEKDAY, DateValue) IN ('Friday','Saturday')
        THEN 1
        ELSE 0
     END                            AS IsWeekend
FROM Dates
OPTION (MAXRECURSION 0);

SELECT * FROM Dim_Date;

--------------------------------------------------------------------------

--Fact_ContainerMovements
CREATE TABLE Fact_ContainerMovements (
 Movement_Key INT NOT NULL IDENTITY(1,1),
 Movement_Id INT,
 Vessel_Call_Key INT,
 Container_Key INT,
 Move_Type_Key INT,
 Equipment_Key INT,
 Shift_Key INT,
 Customer_Key INT,
 Terminal_Key INT,
 Move_StartDate_Key INT,
 Move_EndDate_Key INT,
 Move_StartTime_Key INT,
 Move_EndTime_Key INT,

 Move_Durations_Mins INT,
 Weight_Tons FLOAT,

 Created_At DATE DEFAULT(GETDATE()) ,
 SSC TINYINT NOT NULL,

 CONSTRAINT pk_containermovements PRIMARY KEY (Movement_Key),
 CONSTRAINT fk_containermovements_vesselcall     FOREIGN KEY(Vessel_Call_Key)    REFERENCES Dim_VesselCall(VesselCall_Key),
 CONSTRAINT fk_containermovements_container      FOREIGN KEY(Container_Key)      REFERENCES Dim_Container(Container_Key),
 CONSTRAINT fk_containermovements_movetype       FOREIGN KEY(Move_Type_Key)      REFERENCES Dim_MoveType(MoveType_Key),
 CONSTRAINT fk_containermovements_equipment      FOREIGN KEY(Equipment_Key)      REFERENCES Dim_Equipment(Equipment_Key),
 CONSTRAINT fk_containermovements_shift          FOREIGN KEY(Shift_Key)          REFERENCES Dim_Shift(Shift_Key),
 CONSTRAINT fk_containermovements_customer       FOREIGN KEY(Customer_Key)       REFERENCES Dim_Customer(Customer_Key),
 CONSTRAINT fk_containermovements_terminal       FOREIGN KEY(Terminal_Key)       REFERENCES Dim_Terminal(Terminal_Key),
 CONSTRAINT fk_containermovements_move_startdate FOREIGN KEY(Move_StartDate_Key) REFERENCES Dim_Date(DateKey),
 CONSTRAINT fk_containermovements_move_enddate   FOREIGN KEY(Move_EndDate_Key)   REFERENCES Dim_Date(DateKey),
 CONSTRAINT fk_containermovements_move_starttime FOREIGN KEY(Move_StartTime_Key) REFERENCES DimTime(TimeKey),
 CONSTRAINT fk_containermovements_move_endtime   FOREIGN KEY(Move_EndTime_Key)   REFERENCES DimTime(TimeKey),

 );

 SELECT * FROM Fact_ContainerMovements;

------------------------------------------------------------------------------------------------

-- Fact_VesselCalls
CREATE TABLE Fact_VesselCalls (
 VesselCalls_Key INT NOT NULL IDENTITY(1,1),
 Vessel_Call_Id INT NOT NULL,
 VesselCall_Key INT,
 Customer_Key INT,
 Terminal_Key INT,
 ETA_Date_Key INT,
 ATA_Date_Key INT,
 ATD_Date_Key INT,
 ETA DATETIME,
 ATA DATETIME,
 ATD DATETIME,

 Turnarround_Hours FLOAT ,
 Delay_Mins INT,
 Total_Moves_Planned INT,
 Total_Moves_Actual INT,

 Created_At DATE DEFAULT( GETDATE() ),
 SSC INT NOT NULL,

 CONSTRAINT pk_Vesselcalls PRIMARY KEY(VesselCalls_Key),
 CONSTRAINT fk_Vesselcalls_vesselcal FOREIGN KEY (VesselCall_Key) REFERENCES Dim_VesselCall(VesselCall_Key), 
 CONSTRAINT fk_Vesselcalls_customer  FOREIGN KEY (Customer_Key)   REFERENCES Dim_Customer(Customer_Key), 
 CONSTRAINT fk_Vesselcalls_terminal  FOREIGN KEY (Terminal_Key)   REFERENCES Dim_Terminal(Terminal_Key), 
 CONSTRAINT fk_Vesselcalls_date_eta  FOREIGN KEY (ETA_Date_Key)   REFERENCES Dim_Date(DateKey), 
 CONSTRAINT fk_Vesselcalls_date_ata  FOREIGN KEY (ATA_Date_Key)   REFERENCES Dim_Date(DateKey), 
 CONSTRAINT fk_Vesselcalls_date_atd  FOREIGN KEY (ATD_Date_Key)   REFERENCES Dim_Date(DateKey), 

 );

SELECT * FROM Fact_VesselCalls

------------------------------------------------------------

CREATE TABLE Fact_GateTransactions (
 GateTransaction_Key INT NOT NULL IDENTITY(1,1),
 Gate_Txn_Id INT,
 Truck_Plate NVARCHAR(20),

 Container_Key INT,
 Customer_Key INT,
 Terminal_Key INT,
 Shift_Key INT,
 GateDirection_Key INT,
 Gate_In_Date_Key INT,
 Gate_In_Time_Key INT,
 Gate_Out_Date_Key INT,
 Gate_Out_Time_Key INT,

 GateProcessing_Duration_Mins INT,

 Created_At DATE DEFAULT( GETDATE() ),
 SSC INT NOT NULL,

 CONSTRAINT pk_gatetransactions PRIMARY KEY(GateTransaction_Key),
 CONSTRAINT fk_gatetransactions_container    FOREIGN KEY (Container_Key)     REFERENCES Dim_Container(Container_Key), 
 CONSTRAINT fk_gatetransactions_customer     FOREIGN KEY (Customer_Key)      REFERENCES Dim_Customer(Customer_Key), 
 CONSTRAINT fk_gatetransactions_terminal     FOREIGN KEY (Terminal_Key)      REFERENCES Dim_Terminal(Terminal_Key), 
 CONSTRAINT fk_gatetransactions_shift        FOREIGN KEY (Shift_Key)         REFERENCES Dim_Shift(Shift_Key), 
 CONSTRAINT fk_gatetransactions_direction    FOREIGN KEY (GateDirection_Key) REFERENCES Dim_GateDirection(GateDirection_Key), 
 CONSTRAINT fk_gatetransactions_gatein_date  FOREIGN KEY (Gate_In_Date_Key)  REFERENCES Dim_Date(DateKey), 
 CONSTRAINT fk_gatetransactions_gatein_time  FOREIGN KEY (Gate_In_Time_Key)  REFERENCES DimTime(TimeKey), 
 CONSTRAINT fk_gatetransactions_gateout_date FOREIGN KEY (Gate_Out_Date_Key) REFERENCES Dim_Date(DateKey), 
 CONSTRAINT fk_gatetransactions_gateout_time FOREIGN KEY (Gate_Out_Time_Key) REFERENCES DimTime(TimeKey), 
);

SELECT * FROM Fact_GateTransactions

-----------------------------------------------------------------------

-- ETL_Control_Metadata
CREATE TABLE ETL_Control_Metadata(
  Id INT PRIMARY KEY IDENTITY(1,1),
  TableName NVARCHAR(50),
  LastID BIGINT
)

INSERT INTO ETL_Control_Metadata 
VALUES (('ContainerMovements',0),('GateTransactions',0 ),('VesselCalls',0  ));



