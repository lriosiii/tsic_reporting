 --CTE collects count of College Readiness Contact per student
 With totalCollegeReadinessContactCte (TotalCRContacts, StudentID, OfficeID) As 
	
    (
        Select  Count(sc.StudentID),
        ss.StudentID,
        ss.OfficeID
		From Students.Communications sc
        Join Students.Students ss On ss.StudentID = sc.StudentID
        left join reports.BSC_Dates b on ss.StudentID = b.studentid
		Where 1=1
			AND ss.StudentStatusID In (1, 3, 4, 5) -- All active except "On Hold"
			And  ((b.IsTransfer = 0 and  sc.NoteDate Between dbo.July1() AND dbo.Jun30()) or (b.IsTransfer = 1 and  sc.NoteDate Between b.MMCSCDate AND dbo.Jun30()))
            AND ss.IsDeleted = 0
			And sc.StudentCommunicationTypeID = 1
			And sc.IsDeleted = 0
			And b.MMCSCDate <= '2021-10-31'     -- Change back to 10-31 for mid year, Change to 03-31 for end of year
		Group By ss.StudentID,  ss.OfficeID
	)

SELECT
        ss.StudentID,
       ss.FirstName,
       ss.LastName,
       ss.CurrentGradeLevelID,
       isnull(tcrcte.TotalCRContacts, 0) As TotalCRContacts,
        AV.LastName + ', ' + AV.FirstName AS CollegeSuccessCoachName ,
       ss.OfficeID,
       bscd.IsTransfer,
       bscd.tdate as TrasnferDate,
       tcrcte.TotalCRContacts,
       MMCSCDate

FROM		Students.Students ss
Left Outer Join totalCollegeReadinessContactCte tcrcte ON ss.StudentID = tcrcte.StudentID
LEFT OUTER JOIN Offices.Offices oo ON oo.OfficeID = ss.OfficeID
LEFT OUTER JOIN Offices.Staff AS AV ON AV.StaffID = ss.AdvocateID
Left Outer Join reports.BSC_Dates bscd on bscd.StudentID = ss.StudentID

WHERE		ss.StudentStatusID IN (1, 3, 4, 5)
			and SS.IsDeleted = 0
			AND bscd.MMCSCDate <= '2021-10-31'  --- Change to 10-31 for mid year, Change to 03-31 for end of year
			AND ( (tcrcte.TotalCRContacts IS NULL)


-- 		-------------- Need to comment out scenario 3 and 4 for mid-year report and update total contacts for scenarios 1 and 2 to 2, 1 ----------------
--                      For full year, uncomment scenarios 3 and 4 scenario 1 and 2 should be 4 and 2
-- 		--------------------------------------------------------------------------------------------------------------------------
--

             OR (tcrcte.TotalCRContacts  < 2 AND CurrentGradeLevelID Between 11 AND 12 And bscd.MMCSCDate <= '2020-10-31') --Scenario 1
             OR (tcrcte.TotalCRContacts < 1 AND CurrentGradeLevelID Between 5 AND 10 And bscd.MMCSCDate <= '2020-10-31') --Scenario 2
--
--              OR (tcrcte.TotalCRContacts < 2 AND CurrentGradeLevelID Between 11 AND 12 And bscd.MMCSCDate Between '2019-11-01' AND'2020-03-31') --Scenario 3
--              OR (tcrcte.TotalCRContacts < 1 AND CurrentGradeLevelID Between 6 AND 10 And bscd.MMCSCDate Between '2019-11-01' AND'2020-03-31') --Scenario 4
--
			    )
