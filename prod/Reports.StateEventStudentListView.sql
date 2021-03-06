WITH AllEvents AS
	(
		SELECT S.StudentID,
		E.StateEventID,
		eventname
		FROM Students.Students S, State.Events E
		WHERE E.isdeleted = 0
	)
	
	-- Create subset with only requested students
	SELECT S.StudentID,
 		S.StudentStatusID,
 		SS.StudentStatusName,
 		SG.StatusGroupID,
 		SG.StatusGroupName,
		S.SSN,
		S.FirstName,
		S.MiddleName,
		S.LastName,
		s.emailaddress,
		S.AddressID,
		S.BirthDate,
		S.GraduationYear,
		COALESCE(GL.GradeLevelName, '') as GradeLevelName,
		COALESCE(SC.SchoolName, 'Not Specified') as SchoolName,
		OO.OfficeName,
		DATEDIFF(yy,S.BirthDate,GETDATE()) as Age,
		CASE WHEN S.Gender = 'M' THEN 'Male' ELSE 'Female' END as Gender,
		S.OfficeID,		
		COALESCE(A.FirstName + ' ' + A.LastName, 'Unassigned') as AdvocateName,		
		COALESCE(SM1.MentorName, 'Unassigned') as MentorName,
		AE.StateEventID,
		AE.eventname,
		SE.Attended,
		SE.InvitationSent AS Invited
	FROM Students.Students S
		INNER JOIN Lookups.StudentStatuses SS ON S.StudentStatusID = SS.StudentStatusID		
		INNER JOIN Lookups.StatusGroups SG ON SS.StatusGroupID = SG.StatusGroupID
		LEFT OUTER JOIN Schools.Schools SC ON S.SchoolID = SC.SchoolID
		LEFT OUTER JOIN Offices.Offices OO ON S.OfficeID = OO.OfficeID
		LEFT OUTER JOIN Offices.Staff A ON S.AdvocateID = A.StaffID		
		LEFT OUTER JOIN Lookups.GradeLevels GL ON S.CurrentGradeLevelID = GL.GradeLevelID		
		LEFT OUTER JOIN (SELECT SM.StudentID, M.FirstName + ' ' + M.LastName as MentorName
						FROM Students.StudentMentors SM 
							INNER JOIN Mentors.Mentors M ON M.MentorID = SM.MentorID
						WHERE SM.IsPrimary = 1 AND SM.UnassignedDate IS NULL) SM1 ON S.StudentID = SM1.StudentID
		LEFT OUTER JOIN AllEvents AE ON S.StudentID = AE.StudentID 
		LEFT OUTER JOIN Students.StateEvents SE ON SE.StudentID = S.StudentID AND SE.StateEventID = AE.StateEventID
	WHERE S.IsDeleted = 0 AND GradeLevelID = 12 AND SS.StatusGroupID = 1
