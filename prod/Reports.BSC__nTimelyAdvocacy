 --CTE collects count of College Readiness Contact per student
 With totalCollegeReadinessContactCte (TotalCRContacts, StudentID, OfficeID) As 
	
		(Select  Count(sc.StudentID), 
			ss.StudentID,
			ss.OfficeID
		From Students.Communications sc 
			Join Students.Students ss On ss.StudentID = sc.StudentID
			left join reports.BSC_Dates b on ss.StudentID = b.studentid
		Where 1=1
			AND ss.StudentStatusID In (1, 3, 4, 5) -- All active except "On Hold" 
			And  ((b.IsTransfer = 0 and  sc.NoteDate Between '2019-07-01' AND '2020-06-30') or (b.IsTransfer = 1 and  sc.NoteDate Between b.MMCSCDate AND '2020-06-30'))
					and ss.IsDeleted = 0
			And sc.StudentCommunicationTypeID = 1
			And sc.IsDeleted = 0
			And b.MMCSCDate <= '2019-10-31'     --- web Change back to 10-31 for mid year JL 1/27/2016, Change to 03-31 for end of year; -DR
		Group By ss.StudentID,  ss.OfficeID
		--Order By ss.StudentID --for testing
	)
	
SELECT    ss.FirstName, ss.LastName, ss.CurrentGradeLevelID, ss.ContractSignedDate, sch.SchoolName, isnull(tcrcte.TotalCRContacts, 0) As TotalCRContacts,
			
			AV.LastName + ', ' + AV.FirstName AS CollegeSuccessCoachName , oo.OfficeName, ss.OfficeID, bscd.IsTransfer, bscd.tdate as TrasnferDate
			--CASE
			--	When tcrcte.TotalCRContacts IS NULL THEN 1 
			--	When ss.CurrentGradeLevelID Between 6 And 10 AND tcrcte.TotalCRContacts < 1 THEN 1
			--	When ss.CurrentGradeLevelID Between 6 And 10 AND tcrcte.TotalCRContacts >= 1 THEN 0
			--	When ss.CurrentGradeLevelID Between 11 And 12 And tcrcte.TotalCRContacts < 2 THEN 1
			--	When ss.CurrentGradeLevelID Between 11 And 12 And tcrcte.TotalCRContacts >= 2 THEN 0   
			--END As IsAtRisk
			
FROM		Students.Students ss 
Left Outer Join totalCollegeReadinessContactCte tcrcte ON ss.StudentID = tcrcte.StudentID 
LEFT OUTER JOIN Schools.Schools AS sch ON ss.SchoolID = sch.SchoolID 
LEFT OUTER JOIN Offices.Offices oo ON oo.OfficeID = ss.OfficeID 
LEFT OUTER JOIN Offices.Staff AS AV ON AV.StaffID = ss.AdvocateID 
Left Outer Join reports.BSC_Dates bscd on bscd.StudentID = ss.StudentID

WHERE		ss.StudentStatusID IN (1, 3, 4, 5)
			and SS.IsDeleted = 0
			--AND ss.CurrentGradeLevelID IS NOT NULL   -- This line creates a problem with execution time  JL 5/5/2015
			AND bscd.MMCSCDate <= '2019-10-31'  --- Change back to 10-31 for mid year JL 1/27/2016, Change to 03-31 for end of year; -DR
			AND (
				 (tcrcte.TotalCRContacts IS NULL) 

		-------------- Need to comment out 3 and 4 scneario for mid-year report and update total contacts to 2, 1 ----------------
		--------------------------------------------------------------------------------------------------------------------------
				 -- For full year, scenario 1 and 2 should be 4 and 2
				 -- UnCommented out 2 lines above this per Ele 1/27/2011 - to be commented for mid-year BSC     JL
				 OR (tcrcte.TotalCRContacts < 2 AND CurrentGradeLevelID Between 11 AND 12 And bscd.MMCSCDate <= '2019-10-31') --Scenario 1
				 OR (tcrcte.TotalCRContacts < 1 AND CurrentGradeLevelID Between 5 AND 10 And bscd.MMCSCDate <= '2019-10-31') --Scenario 2

				 --OR (tcrcte.TotalCRContacts < 2 AND CurrentGradeLevelID Between 11 AND 12 And bscd.MMCSCDate Between '2019-11-01' AND'2020-03-31') 
				 --OR (tcrcte.TotalCRContacts < 1 AND CurrentGradeLevelID Between 6 AND 10 And bscd.MMCSCDate Between '2019-11-01' AND'2020-03-31') 
				 
			    )
				--AND ss.OfficeID = 17
				--ORDER BY ContractSignedDate
