WITH -- Common CTE for total active students for the time period (for mentor match rates, etc)
	 totalMentorSessionsCte (TotalMentorSessions, StudentID, OfficeID) As
	(
		Select Count(sms.StudentID) As TotalMentorSessions,
			ss.StudentID,
			ss.OfficeID
		From Students.MentoringSessions sms 
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where ss.StudentStatusID 
				In (1, 3, 4, 5) -- All active except "On Hold" 
			--And ss.ContractSignedDate  
			--	< '2014-06-30'
			And sms.SessionDate Between dbo.July1() AND dbo.Jun30()
			And sms.IsDeleted = 0
			And sms.SessionDuration > 0
-- 			And sms.MentorID IN
-- 			(Select MentorID
-- 			 FROM Students.StudentMentors
-- 			 Where StudentID = ss.StudentID
-- 			 And (UnassignedDate IS NULL Or UnassignedDate = '')
-- 			 AND MentorAssignmentTypeID = 1)
		Group By ss.StudentID, ss.OfficeID
		--Order By ss.StudentID --for testing
	),

	-- CTE for last mentor/student session date
	LastMentorSessionDate (LastSessionDate, StudentID, OfficeID) As
	(
		Select MAX(sms.SessionDate) As LastSessionDate, 
			ss.StudentID,
			ss.OfficeID
		From Students.MentoringSessions sms 
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where ss.StudentStatusID 
				In (1, 3, 4, 5) -- All active except "On Hold" 
			--And ss.ContractSignedDate  
			--	< '2014-06-30'
			And sms.IsDeleted = 0
			And sms.SessionDuration > 0
			And sms.SessionDate Between dbo.July1() AND dbo.Jun30()
-- 			And sms.MentorID IN
-- 			(Select MentorID
-- 			 FROM Students.StudentMentors
-- 			 Where StudentID = ss.StudentID
-- 			 And (UnassignedDate IS NULL Or UnassignedDate = '')
-- 			 AND MentorAssignmentTypeID = 1)
		Group By ss.StudentID, ss.OfficeID
		--Order By ss.StudentID --for testing
	),

	---- CTE for last mentor/student session date
	FirstMentorSessionDate (FirstSessionDate, StudentID, OfficeID) As
	(
		Select MIN(sms.SessionDate) As FirstSessionDate, 
			ss.StudentID,
			ss.OfficeID
		From Students.MentoringSessions sms 
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where ss.StudentStatusID 
				In (1, 3, 4, 5) -- All active except "On Hold" 
			--And ss.ContractSignedDate  
			--	< '2014-06-30'
			And sms.IsDeleted = 0
			And sms.SessionDuration > 0
			And sms.SessionDate Between dbo.July1() AND dbo.Jun30()
-- 			And sms.MentorID IN
-- 			(Select MentorID
-- 			 FROM Students.StudentMentors
-- 			 Where StudentID = ss.StudentID
-- 			 And (UnassignedDate IS NULL Or UnassignedDate = '')
-- 			 AND MentorAssignmentTypeID = 1)
		Group By ss.StudentID, ss.OfficeID
		--Order By ss.StudentID --for testing
	),

	-- CTE for mentor/student assigned date
	MentorAssignedDate (AssignedDate, StudentID, OfficeID) As
	(
		Select MIN(sms.AssignedDate) As AssignedDate, 
			ss.StudentID,
			ss.OfficeID
		From Students.StudentMentors sms 
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where ss.StudentStatusID 
				In (1, 3, 4, 5) -- All active except "On Hold" 
			--And ss.ContractSignedDate  
			--	< '2014-06-30'
			--And (sms.UnassignedDate > '2013-08-01' OR SMS.UnassignedDate IS NULL)
			And (SMS.UnassignedDate IS NULL)
			AND SMS.MentorAssignmentTypeID = 1
			--AND SMS.IsPrimary = 1
            And SMS.IsDeleted = 0
		Group By ss.StudentID, ss.OfficeID
		--Order By ss.StudentID --for testing
	),
	-- CTE for mentor names
	MentorNamesCte (StudentID, Mentors) As
	(
		Select Main.StudentID,
       Left(Main.Mentors,Len(Main.Mentors)-1) As "Mentors"
From(Select distinct ST2.StudentID, 
           (Select ST1.FirstName + ' ' + ST1.LastName + ', ' AS [text()]
            From Mentors.Mentors ST1
				Left Outer Join Students.StudentMentors SMS ON ST1.MentorID = SMS.MentorID
            Where SMS.StudentID = ST2.StudentID 
				--AND (SMS.UnassignedDate > '2013-08-01' OR SMS.UnassignedDate IS NULL)
				AND SMS.AssignedDate Between dbo.July1() And dbo.Jun30()
				AND (SMS.UnassignedDate IS NULL)
				AND (SMS.MentorAssignmentTypeID = 1)
            For XML PATH ('')) [Mentors]
     From Students.Students ST2) [Main]
	 --ORDER BY Main.StudentID
	)
SELECT	O.OfficeName 
		, S.FirstName as StudentFirstName
		, S.LastName as StudentLastName
		, S.LastName + ', ' + S.FirstName as StudentFullName
		--,	M.FirstName as MentorFirstNane
		--, M.LastName as MentorLastName
		--, M.FirstName + ' ' + M.LastName as MentorFullName
		, S.ContractSignedDate
		, mncte.Mentors
		, SCH.SchoolName
		, tmscte.TotalMentorSessions
		, lmsdcte.LastSessionDate As LastSessionThisYear
		--, lmsdcte.LastSessionDate As LastSessionThisYear --Replaced this for today's date above  4/16/2015
		, fmsdcte.FirstSessionDate As FirstSessionThisYear
		, CASE When fmsdcte.FirstSessionDate IS NULL
			Then 0
		  Else
		    DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-01-01'),  IsNull( GetDate(), '1900-01-01'))/30 + 1 
		  END As NumberMonthsWithSessions
		, CASE When (DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( GetDate(), '1900-01-01')) + 1) = 0 
			   Then 0
		  Else 
		    Convert(Int, Ceiling((IsNull(tmscte.TotalMentorSessions, 0) / Cast(DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull(GetDate(), '1900-01-01'))/30  + 1 As Decimal))))
		  End As AvgSessionsMonth
		, madcte.AssignedDate
		, S.i3ControlGroup
		, S.i3StudyGroupMember
		, S.OfficeID
		, S.CurrentGradeLevelID
		, c.CountyName
--FROM Mentors.Mentors M
FROM Students.Students S
	
	--INNER JOIN Common.Addresses A ON M.AddressID = A.AddressID 
	--INNER JOIN Lookups.MentorStatuses MS ON M.MentorStatusID = MS.MentorStatusID 
	--INNER JOIN Students.StudentMentors SSM ON S.StudentID = SSM.MentorID
	--INNER JOIN Students.Students S ON SSM.StudentID = S.StudentID
	INNER JOIN Offices.Offices O ON S.OfficeID = O.OfficeID
	INNER JOIN Lookups.Counties C ON C.CountyID = S.CountyID
	INNER JOIN Schools.Schools SCH ON SCH.SchoolID = S.SchoolID
	INNER JOIN MentorNamesCte mncte ON mncte.StudentID = S.StudentID
	LEFT OUTER JOIN totalMentorSessionsCte tmscte ON S.StudentID = tmscte.StudentID 
	LEFT OUTER JOIN LastMentorSessionDate lmsdcte ON S.StudentID = lmsdcte.StudentID --AND M.MentorID = lmsdcte.MentorID
	LEFT OUTER JOIN FirstMentorSessionDate fmsdcte On S.StudentID = fmsdcte.StudentID
	LEFT OUTER JOIN MentorAssignedDate madcte on S.StudentID = madcte.StudentID
	
Where S.StudentStatusID IN (1, 3, 4, 5) --AND (SSM.UnassignedDate > '2013-08-01' OR SSM.UnassignedDate IS NULL)
--ORDER BY S.CountyID
--And S.OfficeID = 1
--And AssignedDate Between dbo.July1() And dbo.Jun30()
AND S.IsDeleted = 0
