
SELECT M.MentorID,
 		M.MentorStatusID,
 		SS.MentorStatusName,
 		SG.StatusGroupID,
 		SG.StatusGroupName,
 		SG.FilterMask,
		CONVERT(varchar, DecryptByKey(EncryptedSSN)) AS 'SSN',
		M.FirstName,
		M.MiddleName,
		M.LastName,
		M.FirstName + ' ' + M.LastName AS FullName,
		M.AddressID,
		CONVERT(varchar, DecryptByKey(EncryptedBirthDate)) AS 'BirthDate',
		DATEDIFF(yy,CONVERT(varchar, DecryptByKey(EncryptedBirthDate)),GETDATE()) as Age,
		CASE WHEN M.Gender = 'M' THEN 'Male' ELSE 'Female' END as Gender,
		M.OfficeID
		,(SELECT TOP 1 S.FirstName +' ' + S.LastName as StudentName
			FROM Students.StudentMentors SM
				INNER JOIN Students.Students S ON SM.StudentID = S.StudentID
			WHERE SM.MentorID = M.MentorID
			  AND SM.IsDeleted = 0
			  AND SM.MentorAssignmentTypeID = 1
			  AND SM.UnassignedDate IS NULL
			ORDER BY SM.AssignedDate, S.LastName, S.FirstName
		) as Student1Name,
		(SELECT TOP 1 S.FirstName + ' ' + S.LastName as StudentName
			FROM Students.StudentMentors SM
				INNER JOIN Students.Students S ON SM.StudentID = S.StudentID
			WHERE SM.MentorID = M.MentorID
			  AND SM.IsDeleted = 0
			   AND SM.MentorAssignmentTypeID = 1
			  AND SM.UnassignedDate IS NULL
			  AND SM.StudentID <> (SELECT TOP 1 S.StudentID
									FROM Students.StudentMentors SM
										INNER JOIN Students.Students S ON SM.StudentID = S.StudentID
									WHERE SM.MentorID = M.MentorID
										AND SM.IsDeleted = 0
										AND SM.UnassignedDate IS NULL
										ORDER BY SM.AssignedDate, S.LastName, S.FirstName
									)
			ORDER BY SM.AssignedDate
		) as Student2Name
		,M.IsDeleted,
		CASE WHEN SG.StatusGroupID = 1 then 1 else 0 end as StatusGroupIsActive,
		CASE WHEN SG.StatusGroupID = 2 then 1 else 0 end as StatusGroupIsApplicants,
		CASE WHEN SG.StatusGroupID = 3 then 1 else 0 end as StatusGroupIsEligible,
		CASE WHEN SG.StatusGroupID = 4 then 1 else 0 end as StatusGroupIsGraduates,
		CASE WHEN SG.StatusGroupID = 5 then 1 else 0 end as StatusGroupIsInactive,
		CASE WHEN SG.StatusGroupID = 6 then 1 else 0 end as StatusGroupIsOther,
		CASE WHEN SG.StatusGroupID = 7 then 1 else 0 end as StatusGroupIsRetired,
		CASE WHEN SG.StatusGroupID = 8 then 1 else 0 end as StatusGroupIsTerminated,
		CASE WHEN SG.StatusGroupID = 9 then 1 else 0 end as StatusGroupIsRejected

	FROM Mentors.Mentors M
		INNER JOIN Lookups.MentorStatuses SS ON M.MentorStatusID = SS.MentorStatusID
			INNER JOIN Lookups.StatusGroups SG ON SS.StatusGroupID = SG.StatusGroupID
