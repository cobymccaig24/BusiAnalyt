/* 
Deepika Vemu
Pragati Khanna
Akshith Mashetty
Harish Gurrapu
Coby Mccaig
Avinash Rajendran
*/

USE Diabetes;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------- VIEW ------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--1

--VIEW: PatientDiabetesInfo

IF OBJECT_ID('PatientDiabetesInfo') IS NOT NULL
    DROP VIEW PatientDiabetesInfo;
GO

CREATE VIEW PatientDiabetesInfo AS
SELECT Patient_Info.ID, GENDER, AGE, HYPERTENSION, HEART_DISEASE, SMOKING_HISTORY, BMI, HBA1C_LEVEL, BLOOD_GLUCOSE_LEVEL, DIABETES
FROM Patient_Info
JOIN Diabetes_Status ON Patient_Info.ID = Diabetes_Status.ID;
GO

SELECT * FROM PatientDiabetesInfo;

/*
Description: Combines patient information and diabetes status for easy analysis.
Shows essential patient details alongside their diabetes status.

Usage:
- Easily query patient information with associated diabetes status.
*/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------- STORED PROCEDURE ------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--2

--STORED PROCEDURE: sp_GetPatientDiabetesStatus


IF OBJECT_ID('sp_GetPatientDiabetesStatus') IS NOT NULL
    DROP PROC sp_GetPatientDiabetesStatus;
GO

CREATE PROC sp_GetPatientDiabetesStatus
    @PatientID INT
AS
BEGIN

    DECLARE @DiabetesStatus NVARCHAR(50);

    SELECT @DiabetesStatus = Diabetes
    FROM Diabetes_Status
    WHERE ID = @PatientID;

    SELECT ID, GENDER, AGE, HYPERTENSION, HEART_DISEASE, SMOKING_HISTORY, BMI, HBA1C_LEVEL, BLOOD_GLUCOSE_LEVEL, @DiabetesStatus AS Diabetes_Status
    FROM Patient_Info
    WHERE ID = @PatientID;
END;
GO

EXEC sp_GetPatientDiabetesStatus @PatientID = 2525;

/*
Description: Retrieves patient details and diabetes status for a specific patient ID.

Usage:
- Quickly obtain comprehensive information about a specific patient's health status.
*/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------ UDF ---------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--3

--USER-DEFINED FUNCTION: fn_GetDiabetesRiskCategory

IF OBJECT_ID('fn_GetDiabetesRiskCategory') IS NOT NULL
    DROP FUNCTION fn_GetDiabetesRiskCategory;
GO

CREATE FUNCTION fn_GetDiabetesRiskCategory(@BMI FLOAT, @Age INT)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @RiskCategory NVARCHAR(255);
    IF @Age < 30
    BEGIN
        IF @BMI < 25
            SET @RiskCategory = 'Low Risk';
        ELSE IF @BMI >= 25 AND @BMI < 30
            SET @RiskCategory = 'Moderate Risk';
        ELSE
            SET @RiskCategory = 'High Risk';
    END
    ELSE IF @Age >= 30 AND @Age < 50
    BEGIN
        IF @BMI < 25
            SET @RiskCategory = 'Moderate Risk';
        ELSE IF @BMI >= 25 AND @BMI < 30
            SET @RiskCategory = 'High Risk';
        ELSE
            SET @RiskCategory = 'Very High Risk';
    END
    ELSE
    BEGIN
        IF @BMI < 25
            SET @RiskCategory = 'Moderate Risk';
        ELSE IF @BMI >= 25 AND @BMI < 30
            SET @RiskCategory = 'High Risk';
        ELSE
            SET @RiskCategory = 'Very High Risk';
    END
    RETURN @RiskCategory;
END;
GO

DECLARE @PatientBMI FLOAT = 20;
DECLARE @PatientAge INT = 35;

SELECT dbo.fn_GetDiabetesRiskCategory(@PatientBMI, @PatientAge) AS DiabetesRiskCategory;

/*
Description: Categorizes a patient's diabetes risk based on their BMI and age, providing valuable insights for healthcare assessment.

Usage:
- The returned risk category helps medical professionals and individuals understand the potential health risks associated with the patient's BMI and age combination.
*/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------- SUMMARY QUERIES ------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--4

--Summary Query 1

SELECT DIABETES, COUNT(*) AS PatientCount, ROUND(AVG(AGE),2) AS AverageAge, ROUND(AVG(BMI),2) AS AverageBMI
FROM Patient_Info
JOIN Diabetes_Status ON Patient_Info.ID = Diabetes_Status.ID
GROUP BY DIABETES;

/*
Description: Calculates the patient count, average age and average BMI of diabetic and non-diabetic patients.

Usage:
- Understand the average age, BMI and distribution of patients based on diabetes status.
*/


--5

--Summary Query 2

SELECT SMOKING_HISTORY, AVG(CAST(DIABETES AS FLOAT))*100 AS AvgDiabetes
FROM Patient_Info
JOIN Diabetes_Status ON Patient_Info.ID = Diabetes_Status.ID
GROUP BY SMOKING_HISTORY;

/*
Description: Calculates the average diabetes value based on smoking history.

Usage:
- Evaluate the average prevalence of diabetes among patients with different smoking histories.
*/


--6

--Summary Query 3

SELECT
    CASE
        WHEN BMI < 18.5 THEN 'Underweight'
        WHEN BMI >= 18.5 AND BMI < 25 THEN 'Normal'
        WHEN BMI >= 25 AND BMI < 30 THEN 'Overweight'
        ELSE 'Obese'
    END AS BMICategory,
    ROUND(AVG(CAST(DIABETES AS FLOAT))*100, 2) AS AvgDiabetes
FROM
    Patient_Info
JOIN
    Diabetes_Status ON Patient_Info.ID = Diabetes_Status.ID
GROUP BY
    CASE
        WHEN BMI < 18.5 THEN 'Underweight'
        WHEN BMI >= 18.5 AND BMI < 25 THEN 'Normal'
        WHEN BMI >= 25 AND BMI < 30 THEN 'Overweight'
        ELSE 'Obese'
    END;

/*
Description: Calculates the average diabetes value for different BMI categories.

Usage:
- Understand the average diabetes prevalence across distinct BMI categories.
*/


--7

--Summary Query 4

SELECT GENDER, SUM(CASE WHEN DIABETES = 0 THEN 1 ELSE 0 END) AS Diabetic, SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS 'Non-Diabetic', COUNT(*) AS Count
FROM Patient_Info
JOIN Diabetes_Status ON Patient_Info.ID = Diabetes_Status.ID
GROUP BY GENDER;

/*
Description: Table displaying gender-wise count of patients with diabetes status 0 and 1.

Usage:
- Visualize the distribution of diabetic and non-diabetic patients based on gender.
*/


--8

--Summary Query 5

SELECT
    CASE
        WHEN AGE >= 0 AND AGE <= 20 THEN '0-20'
        WHEN AGE > 20 AND AGE <= 40 THEN '21-40'
        WHEN AGE > 40 AND AGE <= 60 THEN '41-60'
        WHEN AGE > 60 AND AGE <= 80 THEN '61-80'
    END AS AgeGroup,  
    ROUND(AVG(CAST(DIABETES AS FLOAT))*100, 2) AS AvgDiabetes
FROM Patient_Info
JOIN Diabetes_Status ON Patient_Info.ID = Diabetes_Status.ID
GROUP BY
    CASE
        WHEN AGE >= 0 AND AGE <= 20 THEN '0-20'
        WHEN AGE > 20 AND AGE <= 40 THEN '21-40'
        WHEN AGE > 40 AND AGE <= 60 THEN '41-60'
        WHEN AGE > 60 AND AGE <= 80 THEN '61-80'
    END; 


/*
Description: Calculates the average diabetes value for different age categories.

Usage:
- Evaluate the average prevalence of diabetes across distinct age groups.
*/


--9

--Summary Query 6

SELECT
    CASE
        WHEN BLOOD_GLUCOSE_LEVEL >= 80 AND BLOOD_GLUCOSE_LEVEL <= 125 THEN '80-125'
        WHEN BLOOD_GLUCOSE_LEVEL > 125 AND BLOOD_GLUCOSE_LEVEL <= 200 THEN '126-200'
        WHEN BLOOD_GLUCOSE_LEVEL > 200 AND BLOOD_GLUCOSE_LEVEL <= 300 THEN '201-300'
    END AS GlucoseLevelRange, 

    ROUND(AVG(CAST(DIABETES AS FLOAT)) * 10, 2) AS AvgDiabetes  
FROM Patient_Info
JOIN Diabetes_Status ON Patient_Info.ID = Diabetes_Status.ID
GROUP BY
    CASE
        WHEN BLOOD_GLUCOSE_LEVEL >= 80 AND BLOOD_GLUCOSE_LEVEL <= 125 THEN '80-125'
        WHEN BLOOD_GLUCOSE_LEVEL > 125 AND BLOOD_GLUCOSE_LEVEL <= 200 THEN '126-200'
        WHEN BLOOD_GLUCOSE_LEVEL > 200 AND BLOOD_GLUCOSE_LEVEL <= 300 THEN '201-300'
    END  
ORDER BY AvgDiabetes;

/*
Description: Calculates the average diabetes value for different blood glucose level ranges.

Usage:
- Understand the average diabetes prevalence across distinct blood glucose level ranges.
*/


--10

--Summary Query 7

SELECT GENDER, ROUND(AVG(CAST(DIABETES AS FLOAT))*100, 2) AS AvgDiabetes
FROM Patient_Info
JOIN Diabetes_Status ON Patient_Info.ID = Diabetes_Status.ID
GROUP BY GENDER;

/*
Description: Calculate the average percentage of diabetic patients by gender.

Usage:
- Useful for understanding the gender-wise distribution of diabetes cases.
*/


--11

--Summary Query 8

SELECT
    HYPERTENSION,
    HEART_DISEASE,
    GENDER,
    ROUND(AVG(CAST(DIABETES AS FLOAT)) * 100, 2) AS AvgDiabetes FROM
    Patient_Info
JOIN Diabetes_Status ON Patient_Info.ID = Diabetes_Status.ID
GROUP BY
    GROUPING SETS (
        (HYPERTENSION, HEART_DISEASE, GENDER), 
        (HYPERTENSION, HEART_DISEASE)
    );

/*
Description: Calculates the average diabetes value based on hypertension, heart disease, and gender.
Includes subtotals for hypertension and heart disease.

Usage:
- Analyze the average prevalence of diabetes considering hypertension, heart disease, and gender.
- Subtotals provide additional insights into diabetes distribution based on health conditions.
*/