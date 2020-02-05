SELECT
			S.StudentID,
			s.FirstName,
			s.LastName,
			cnt.CountyName,
			ss.StudentStatusName,
			LEFT(s.ContractSignedDate,4) as EntryYear,
			s.ContractSignedDate,
			s.HighSchoolDiplomaDate,
			s.GraduationYear,
			fs.FamilySituationName,
			(Select top (1) sh.StatusChangeDate
				from students.StatusHistory sh
				where sh.StudentID = s.StudentID and s.StudentStatusID in (19,20,21,22,23,24)
				order by StatusChangeDate desc
			) as TerminationDate,
			(Select top (1) case when s.EntryGPA is null then sax.GPA else s.EntryGPA end as EntryGPA
				from students.Applications sax
				where sax.IsDeleted = 0 and sax.StudentID = s.StudentID
			) EntryGPA,
			(Select top (1) case when s.PriorityType is null then sax.PriorityType else s.PriorityType end as PriorityType
			from students.Applications sax
			where sax.IsDeleted = 0 and sax.StudentID = s.StudentID
			) PriorityType,
			(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 14 And SARFX.OptionID = 1)
					THEN 'Yes'
					ELSE 'No'
				END) AS MigrantWorker,
			(SELECT CASE
			WHEN S.StudentID IN (
				SELECT SX.StudentID
				FROM Students.Applications SX INNER JOIN
				Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
				WHERE SARFX.RiskFactorID = 12 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
			END) AS IncarceratedParent,
			(SELECT CASE
			WHEN S.StudentID IN (
				SELECT SX.StudentID
				FROM Students.Applications SX INNER JOIN
				Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
				WHERE SARFX.RiskFactorID = 19 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
			END) AS SingleParent,
			(SELECT CASE
			WHEN S.StudentID IN (
				SELECT SX.StudentID
				FROM Students.Applications SX INNER JOIN
				Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
				WHERE SARFX.RiskFactorID = 17 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
			END) AS PoorRelationsBtwnParents,
			(SELECT CASE
			WHEN S.StudentID IN (
				SELECT SX.StudentID
				FROM Students.Applications SX INNER JOIN
				Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
				WHERE SARFX.RiskFactorID = 3 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
			END) AS DCFInvolvement,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 24 And SARFX.OptionID = 1)
					THEN 'Yes'
					ELSE 'No'
				END) AS FirstToCompleteHS,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 23 And SARFX.OptionID = 1)
					THEN 'Yes'
					ELSE 'No'
				END) AS FirstGenerationCollege,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 8 And SARFX.OptionID = 1)
					THEN 'Yes'
					ELSE 'No'
				END) AS ExtendFamilyRaisingStudent,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 9 And SARFX.OptionID = 1)
					THEN 'Yes'
					ELSE 'No'
				END) AS TANFRecipient,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 7 And SARFX.OptionID = 1)
					THEN 'Yes'
					ELSE 'No'
				END) AS ExtendFamilyInHome,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 6 And SARFX.OptionID = 1)
					THEN 'Yes'
					ELSE 'No'
				END) AS EnglishNotSpokenInHome,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 13 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
				END) AS LossOfEmployment,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 10 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
				END) AS HomeInForclosure,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 11 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
				END) AS Homeless,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 21 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
				END) AS HasOrHadFosterCare,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 4 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
				END) AS DeceasedParent,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 18 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
				END) AS SeriousIllness,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 5 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
				END) AS DisabledOrFamilyMemberIs,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 20 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
				END) AS TeenParent,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 16 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
				END) AS ParentWasTeenParent,
				(SELECT CASE
				WHEN S.StudentID IN (
					SELECT SX.StudentID
					FROM Students.Applications SX INNER JOIN
					Students.ApplicationRiskFactors SARFX ON SX.ApplicationID = SARFX.ApplicationID
					WHERE SARFX.RiskFactorID = 1 And SARFX.OptionID = 1)
				THEN 'Yes'
				ELSE 'No'
				END) AS AbsentParent

				,s.EntryGradeLevelID
				,s.Gender
				, (Select case when s.ishispanic = '1' then 'Hispanic' ELSE R.RaceName end) as RaceEth
				,(Select top (1) sax.AnnualHouseholdIncome
				from students.Applications sax
				where sax.IsDeleted = 0 and sax.StudentID = s.StudentID
				) AnnualHouseholdIncome

				,(Select top (1) sax.AdultsInHousehold
				from students.Applications sax
				where sax.IsDeleted = 0 and sax.StudentID = s.StudentID
				) AdultsInHousehold

				,(Select top (1) sax.ChildrenInHousehold
				from students.Applications sax
				where sax.IsDeleted = 0 and sax.StudentID = s.StudentID
				) ChildrenInHousehold
				,s.Affiliation

				,s.OfficeID
				,(Select top (1) sax.ApplicationCompletionDate
				from students.Applications sax
				where sax.IsDeleted = 0 and sax.StudentID = s.StudentID
				) ApplicationCompletionDate
		,s.CurrentGradeLevelID
		,sc.SchoolName
FROM         Students.Students AS S LEFT OUTER JOIN
					  Lookups.Counties AS CNT ON S.CountyID = CNT.CountyID LEFT OUTER JOIN
                      Schools.Schools AS SC ON S.SchoolID = SC.SchoolID LEFT OUTER JOIN
                      Lookups.StudentStatuses AS SS ON S.StudentStatusID = SS.StudentStatusID LEFT OUTER JOIN
                      Common.Addresses AS SAddress ON S.AddressID = SAddress.AddressID LEFT OUTER JOIN
                      Lookups.GradeLevels AS GR ON S.CurrentGradeLevelID = GR.GradeLevelID LEFT OUTER JOIN
                      Lookups.Races AS R ON S.RaceID = R.RaceID LEFT OUTER JOIN
					  Lookups.Ethnicities AS E ON S.EthnicityID = E.EthnicityID LEFT OUTER JOIN
				      Lookups.FamilySituations FS ON S.FamilySituationID = FS.FamilySituationID --INNER  JOIN

WHERE       s.StudentStatusID in (1,2,3,4,5,9,10,11,12,13,14,15,19,20,21,22,23,24,28) and s.IsDeleted = 0
			--and s.Affiliation like '%RSS%'
