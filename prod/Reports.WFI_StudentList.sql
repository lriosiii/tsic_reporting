WITH -- Common CTE for total active students for the time period (for mentor match rates, etc)
	 totalMentorSessionsCte (TotalMentorSessions, StudentID, OfficeID) As
	(
		Select Count(sms.StudentID) As TotalMentorSessions, 
			ss.StudentID,
			ss.OfficeID
		From Students.MentoringSessions sms 
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where --ss.StudentStatusID 
				--In (1, 3, 4, 5) -- All active except "On Hold" And
			 ss.ContractSignedDate  
				<= '2019-06-30'
			And sms.SessionDate Between '2018-07-01' AND '2019-06-30'
			And sms.IsDeleted = 0
			And sms.SessionDuration > 0
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
		Where --ss.StudentStatusID 
				--In (1, 3, 4, 5) -- All active except "On Hold" And
			 ss.ContractSignedDate  
				<= '2019-06-30'
			And sms.IsDeleted = 0
			And sms.SessionDuration > 0
			And sms.SessionDate Between '2018-07-01' AND '2019-06-30'
		Group By ss.StudentID, ss.OfficeID
		--Order By ss.StudentID --for testing
	),
	-- CTE for last CSC visit date
	LastCSCVisitDate (LastSessionDate, StudentID, OfficeID) As
	(
		Select MAX(sc.NoteDate) As LastCSCVisitDate, 
			ss.StudentID,
			ss.OfficeID
		From Students.Communications sc 
			Join Students.Students ss
				On ss.StudentID = sc.StudentID
		Where --ss.StudentStatusID 
				--In (1, 3, 4, 5) -- All active except "On Hold" And
			 ss.ContractSignedDate  
				<= '2019-06-30'
			And sc.IsDeleted = 0
			And sc.StudentCommunicationTypeID = 1  --To ensure it is a college readiness visit.
			And sc.NoteDate Between '2018-07-01' AND '2019-06-30'
		Group By ss.StudentID, ss.OfficeID
		--Order By ss.StudentID --for testing
	),
	-- CTE for mentor/student assigned date
	MentorAssignedDate (AssignedDate, StudentID, OfficeID) As
	(
		Select MAX(sms.AssignedDate) As AssignedDate, 
			ss.StudentID,
			ss.OfficeID
		From Students.StudentMentors sms 
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where --ss.StudentStatusID 
				--In (1, 3, 4, 5) -- All active except "On Hold" And
			 ss.ContractSignedDate  
				< '2019-06-30'
			And (sms.UnassignedDate > '2018-07-01' OR SMS.UnassignedDate IS NULL)
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
				AND (SMS.UnassignedDate > '2018-07-01' OR SMS.UnassignedDate IS NULL)
            For XML PATH ('')) [Mentors]
     From Students.Students ST2) [Main]
	 --ORDER BY Main.StudentID
	)
SELECT	  S.FirstName as StudentFirstName
		, S.LastName as StudentLastName
		, S.LastName + ', ' + S.FirstName as StudentFullName
		--,	M.FirstName as MentorFirstNane
		--, M.LastName as MentorLastName
		--, M.FirstName + ' ' + M.LastName as MentorFullName
		, mncte.Mentors
		, SCH.SchoolName
		,s.ContractSignedDate
		, lmsdcte.LastSessionDate As LastSessionThisYear
		, lcvcte.LastSessionDate As LastCRCVisitThisYear
		, madcte.AssignedDate
		, tmscte.TotalMentorSessions
		, SC.ContractNumber
		, SC.ScholarshipID
		, SC.TDFAccountNumber
		, S.i3ControlGroup
		, S.i3StudyGroupMember
		, S.OfficeID
		, c.CountyName
		,o.OfficeName
		, case
			when s.CurrentGradeLevelID > 12 then Cast('Null' As varchar(4))
			Else Cast(s.CurrentGradeLevelID as varchar(4))
			End as CurrentGradeLevelID
		, SS.StudentStatusName
		, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) AS SSN
		, (
			SELECT TOP(1) StatusChangeDate
			FROM Students.StatusHistory
			Where Students.StatusHistory.StudentID = S.StudentID
			AND Students.StatusHistory.IsDeleted = 0
			ORDER BY StatusChangeDate DESC
		) AS LastStatusChangeDate
		, S.GraduationYear
		, s.HighSchoolDiplomaDate
		
--FROM Mentors.Mentors M
FROM Students.Students S
	
	--INNER JOIN Common.Addresses A ON M.AddressID = A.AddressID 
	--INNER JOIN Lookups.MentorStatuses MS ON M.MentorStatusID = MS.MentorStatusID 
	--INNER JOIN Students.StudentMentors SSM ON S.StudentID = SSM.MentorID
	--INNER JOIN Students.Students S ON SSM.StudentID = S.StudentID
	LEFT OUTER JOIN Lookups.Counties C ON C.CountyID = S.CountyID
	LEFT OUTER JOIN Lookups.StudentStatuses SS ON S.StudentStatusID = SS.StudentStatusID
	LEFT OUTER JOIN Schools.Schools SCH ON SCH.SchoolID = S.SchoolID
	LEFT OUTER JOIN MentorNamesCte mncte ON mncte.StudentID = S.StudentID
	LEFT OUTER JOIN totalMentorSessionsCte tmscte ON S.StudentID = tmscte.StudentID 
	LEFT OUTER JOIN LastMentorSessionDate lmsdcte ON S.StudentID = lmsdcte.StudentID --AND M.MentorID = lmsdcte.MentorID
	LEFT OUTER JOIN MentorAssignedDate madcte on S.StudentID = madcte.StudentID
	LEFT OUTER JOIN LastCSCVisitDate lcvcte on S.StudentID = lcvcte.StudentID
	LEFT OUTER JOIN Offices.Scholarships SC on S.StudentID = SC.StudentID
	left outer join offices.Offices o on s.OfficeID = o.OfficeID
	
Where --S.StudentStatusID IN (1, 3, 4, 5) And
 S.WfiEligible = 1
--AND (SSM.UnassignedDate > '2013-08-01' OR SSM.UnassignedDate IS NULL)
--ORDER BY S.CountyID
