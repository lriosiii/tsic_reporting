/*
TIME OF YEAR UPDATES - Made Summer 2019
BEFORE:And sg.SemesterEndDate Between '2018-11-01' And '2019-03-31'
AFTER: And sg.SemesterEndDate Between '2019-05-01' And '2019-07-31'
BEFORE: And (sa.SemesterEndDate Between '2018-11-01' And '2019-03-31') 
AFTER: And (sa.SemesterEndDate Between '2019-05-01' And '2019-07-31') 
BEFORE: ContractSignedDate < '2018-11-01'
AFTER: ContractSignedDate < '2019-03-31'
BEFORE: And sg.SchoolTermTypeID in (17, 30, 0)
AFTER: And sg.SchoolTermTypeID in (18, 30, 0)
*/

With totalStudentsWithGPACte (TotalStudentsWithGPA, StudentID, OfficeID) As 
	(
		Select Count(sg.StudentID) As TotalStudentsWithGPA,
			sg.studentID,
			ss.OfficeID
		From Students.GPA sg 
			Join Students.Students ss
				On ss.StudentID = sg.StudentID
		Where ss.StudentStatusID 
				In (1, 3, 4, 5) -- All active except "On Hold" 
			And ss.CurrentGradeLevelID  IS NOT NULL
			And sg.SemesterEndDate Between '2020-05-01' And '2020-07-31'
			And sg.SchoolTermTypeID in (18, 30, 0)  -- 10 = quarter 3, 18 is semester 2, 17 is semester 1 - see notes above  5/18/2016
			And (sg.SemesterUnweighted > 0 Or sg.CumulativeUnweighted > 0)
			And sg.IsDeleted = 0
			And ss.ContractSignedDate  < '2020-03-31'
			
		Group By sg.StudentID, ss.OfficeID
		--Order By sg.StudentID --for testing
	)

	,totalStudentsWithAttendanceCte (TotalStudentsWithAttendance, StudentID, OfficeID) As 
	(
		Select Count(sa.StudentID) As TotalStudentsWithAttendance,
			sa.studentID,
			ss.OfficeID
		From Students.Attendance sa 
			Join Students.Students ss
				On ss.StudentID = sa.StudentID
		Where ss.StudentStatusID 
				In (1, 3, 4, 5) -- All active except "On Hold" 
			And ss.CurrentGradeLevelID  IS NOT NULL
			And (sa.SemesterEndDate Between '2020-05-01' And '2020-07-31')
			And sa.SchoolTermTypeID in (18, 30, 0) 
			And sa.IsDeleted = 0
			And ss.IsDeleted = 0
			And ss.ContractSignedDate < '2020-03-31'
		Group By sa.StudentID, ss.OfficeID
	)
	
 
	 --CTE collects count of all students before a specific signing date
	 ,totalStudentsCte (TotalStudents, OfficeID) As 
	(
		Select Count(ss.StudentID) As TotalStudents, 
			ss.OfficeID
		From Students.Students ss
		Where ss.StudentStatusID 
				In (1, 3, 4, 5) -- All active except "On Hold" 
				And ss.IsDeleted = 0
				And ContractSignedDate < '2020-03-31'
						
		Group By ss.OfficeID
	)

	

	--CTE to get total students with a GPA for dates and term types listed.
	, totalStudentsWGPAByOffice (TotalWithGPA, OfficeID) AS
	(
		Select Count(tcrcte.StudentID), 
			tcrcte.OfficeID
		FROM totalStudentsWithGPACte tcrcte
		Group BY tcrcte.OfficeID
	)

	--CTE to get total students with attendance for date range given
	, totalStudentsWAttendanceByOffice (TotalWithAttendance, OfficeID) AS
	(
		Select Count(tcrcte.StudentID), 
			tcrcte.OfficeID
		FROM totalStudentsWithAttendanceCte tcrcte
		Group BY tcrcte.OfficeID
	)
	

SELECT      oo.OfficeName, tcrStuCte.TotalStudents, tcrOffcte.TotalWithGPA,
			Convert(Int, Ceiling((IsNull(tcrOffcte.TotalWithGPA, 0) / Cast(tcrStuCte.TotalStudents As Decimal)) * 100)) As PercentWithGPA,
			tcrAttcte.TotalWithAttendance,
			Convert(Int, Ceiling((IsNull(tcrAttcte.TotalWithAttendance, 0) / Cast(tcrStuCte.TotalStudents As Decimal)) * 100)) As PercentWithAttendance
			
FROM		Offices.Offices oo 
LEFT OUTER JOIN totalStudentsCte tcrStucte ON oo.OfficeID = tcrStucte.OfficeID 
LEFT OUTER JOIN totalStudentsWGPAByOffice tcrOffcte ON oo.OfficeID = tcrOffcte.OfficeID 
LEFT OUTER JOIN totalStudentsWAttendanceByOffice tcrAttcte ON oo.OfficeID = tcrAttcte.OfficeID
			
WHERE		oo.IsDeleted = 0

--ORDER BY    OfficeName
