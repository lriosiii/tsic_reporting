
SELECT   Sal.SalutationName
		, m.MentorID
		, M.FirstName as MentorFirstNane
		, M.LastName as MentorLastName
		, M.FirstName + ' ' + M.LastName as MentorFullName
		, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) AS SSN
		, MS.MentorStatusName
		, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)) AS MentorDOB
		, M.HomePhoneNumber
		, M.MobilePhoneNumber
		, M.WorkPhoneNumber
		, M.Gender
		, M.EmployerName
		, M.EmailAddress
		, M.AdditionalEmailAddress
		, S.FirstName as StudentFirstName
		, S.LastName as StudentLastName
		, S.FirstName + ' ' + S.LastName as StudentFullName
		, SES.SessionDate
		, SES.SessionDuration
		, SES.SessionNote
		--, SES.InsertedDate  	  --TODO: re-apply field when they become availble in new mentoringsessions table
		--, SES.DBUser		  --TODO: re-apply field when they become availble in new mentoringsessions table
		, M.OfficeID
		, M.MentorStatusID
		, c.CountyName
		, S.CurrentGradeLevelID
		, M.AmericorMentor
		, Sch.SchoolName
		, 1 AS EnteredThruWebsite
FROM Mentors.Mentors M
	LEFT OUTER JOIN Lookups.Salutations Sal On M.SalutationID = Sal.SalutationID
	INNER JOIN Common.Addresses A ON M.AddressID = A.AddressID
	INNER JOIN Lookups.MentorStatuses MS ON M.MentorStatusID = MS.MentorStatusID
	INNER JOIN Students.MentoringSessions SES ON M.MentorID = SES.MentorID
	INNER JOIN Students.Students S ON SES.StudentID = S.StudentID
	INNER JOIN Schools.Schools Sch ON S.SchoolID = Sch.SchoolID
	LEFT OUTER JOIN Lookups.Counties C ON C.CountyID = m.CountyID
Where 1=1
	AND ses.IsDeleted = 0
	And S.IsDeleted = 0
	And M.IsDeleted = 0
	AND sessionsourceid = 2

