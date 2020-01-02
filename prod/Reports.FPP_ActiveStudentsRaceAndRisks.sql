SELECT     S.FirstName, S.MiddleName, S.LastName, S.LastName + ', ' + S.FirstName AS StudentFullName, S.SSN, S.BirthDate, SS.StudentStatusName,
                      GR.GradeLevelName AS CurrentGradeLevel, S.Affiliation, S.HomePhoneNumber, S.MobilePhoneNumber, S.WorkPhoneNumber, S.EmailAddress,
                      CASE WHEN S.Gender = 'M' THEN 'Male' ELSE 'Female' END AS Gender, CNT.CountyName, SAddress.Address1 AS StudentAddress1,
                      SAddress.Address2 AS StudentAddress2, SAddress.City AS StudentCity, SAddress.StateID AS StudentState,
					  SAddress.ZipCode AS StudentZipCode,
                          (SELECT     TOP (1) ContactName
                            FROM          Students.Contacts AS PG
                            WHERE      (StudentID = S.StudentID)) AS PrimaryGuardianName,
                          (SELECT     TOP (1) ContactName
                            FROM          Students.Contacts AS SG
                            WHERE      (StudentID = S.StudentID) AND (IsSecondaryGuardian = 1)) AS SecondaryGuardianName, SC.SchoolName,
                      DATEDIFF(YY, S.BirthDate, GETDATE()) AS StudentAge,
					  (
						SELECT CASE
							WHEN S.IsHispanic = 1 THEN 'Hispanic'
							ELSE
								 R.RaceName
							END
					  ) As EthnicRaceName,
                       S.OfficeID, S.ContractSignedDate, s.StudentReferenceID, S.HighSchoolDiplomaDate, FS.FamilySituationName,
					  --SARF.RiskFactorWeight, RF.RiskFactorName,
					  (SELECT CASE
						WHEN S.StudentID IN (
							SELECT SX.StudentID
							FROM Students.Applications SX INNER JOIN
							Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
							WHERE SARFX.RiskFactorID = 14 And SARFX.OptionID = 1)
						THEN 1
						ELSE 0
						END) AS MigrantWorker,
						(SELECT CASE
						WHEN S.StudentID IN (
							SELECT SX.StudentID
							FROM Students.Applications SX INNER JOIN
							Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
							WHERE SARFX.RiskFactorID = 12 And SARFX.OptionID = 1)
						THEN 1
						ELSE 0
						END) AS IncarceratedParent,
						(SELECT CASE
						WHEN S.StudentID IN (
							SELECT SX.StudentID
							FROM Students.Applications SX INNER JOIN
							Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
							WHERE SARFX.RiskFactorID = 19 And SARFX.OptionID = 1)
						THEN 1
						ELSE 0
						END) AS SingleParent,
						(SELECT CASE
						WHEN S.StudentID IN (
							SELECT SX.StudentID
							FROM Students.Applications SX INNER JOIN
							Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
							WHERE SARFX.RiskFactorID = 8 And SARFX.OptionID = 1)
						THEN 1
						ELSE 0
						END) AS ExtendFamilyRaisingStudent,
						(SELECT CASE
						WHEN S.StudentID IN (
							SELECT SX.StudentID
							FROM Students.Applications SX INNER JOIN
							Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
							WHERE SARFX.RiskFactorID = 21 And SARFX.OptionID = 1)
						THEN 1
						ELSE 0
						END) AS HasOrHadFosterCare,
						(SELECT CASE
						WHEN S.StudentID IN (
							SELECT SX.StudentID
							FROM Students.Applications SX INNER JOIN
							Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
							WHERE SARFX.RiskFactorID = 4 And SARFX.OptionID = 1)
						THEN 1
						ELSE 0
						END) AS DeceasedParent,
						(SELECT CASE
						WHEN S.StudentID IN (
							SELECT SX.StudentID
							FROM Students.Applications SX INNER JOIN
							Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
							WHERE SARFX.RiskFactorID = 5 And SARFX.OptionID = 1)
						THEN 1
						ELSE 0
						END) AS DisabledOrFamilyMemberIs,
						(SELECT CASE
						WHEN S.StudentID IN (
							SELECT SX.StudentID
							FROM Students.Applications SX INNER JOIN
							Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
							WHERE SARFX.RiskFactorID = 20 And SARFX.OptionID = 1)
						THEN 1
						ELSE 0
						END) AS TeenParent,
						(SELECT CASE
						WHEN S.StudentID IN (
							SELECT SX.StudentID
							FROM Students.Applications SX INNER JOIN
							Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
							WHERE SARFX.RiskFactorID = 1 And SARFX.OptionID = 1)
						THEN 1
						ELSE 0
						END) AS AbsentParent

FROM         Students.Students AS S LEFT OUTER JOIN
					  Lookups.Counties AS CNT ON S.CountyID = CNT.CountyID LEFT OUTER JOIN
                      Schools.Schools AS SC ON S.SchoolID = SC.SchoolID LEFT OUTER JOIN
                      Lookups.StudentStatuses AS SS ON S.StudentStatusID = SS.StudentStatusID LEFT OUTER JOIN
                      Common.Addresses AS SAddress ON S.AddressID = SAddress.AddressID LEFT OUTER JOIN
                      Lookups.GradeLevels AS GR ON S.CurrentGradeLevelID = GR.GradeLevelID LEFT OUTER JOIN
                      Lookups.Races AS R ON S.RaceID = R.RaceID LEFT OUTER JOIN
					  Lookups.FamilySituations FS ON S.FamilySituationID = FS.FamilySituationID --INNER  JOIN
       --               Students.Applications SA ON S.StudentID = SA.StudentID Inner Join
					  --Students.ApplicationRiskFactors SARF ON SA.ApplicationID = SARF.ApplicationID Inner Join
					  --Lookups.RiskFactors RF ON SARF.RiskFactorID = RF.RiskFactorID
WHERE       S.IsDeleted = 0
AND			S.WfiEligible = 0
AND			(S.StudentStatusID IN (1,3,4,5)
				OR (S.HighSchoolDiplomaDate Between '2019-01-01' AND '2019-06-30'
						AND S.StudentStatusID IN (11,12,13,14,15,25,28)
				)
			)
AND			S.ContractSignedDate Between '2018-07-01' AND '2019-06-30'
--AND			(SARF.RiskFactorID IN (1,4,5,8,12,14,19,20,21))
--ORDER BY	S.HighSchoolDiplomaDate
--SA.ApplicationID Is NULL OR