OPEN SYMMETRIC KEY SymmetricKey1
DECRYPTION BY CERTIFICATE Certificate1;

SELECT   Sal.SalutationName
		, m.MentorID
		, M.FirstName as MentorFirstNane
		, M.LastName as MentorLastName
		, M.FirstName + ' ' + M.LastName as MentorFullName
		, CONVERT(varchar, DecryptByKey(M.EncryptedSSN))AS SSN
		, MS.MentorStatusName
		, CONVERT(varchar, DecryptByKey(M.EncryptedBirthDate)) as MentorDOB
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
		, SES.InsertedDate
		, SES.DBUser
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
	INNER JOIN Students.WebMentoringSessions SES ON M.MentorID = SES.MentorID
	INNER JOIN Students.Students S ON SES.StudentID = S.StudentID
	INNER JOIN Schools.Schools Sch ON S.SchoolID = Sch.SchoolID
	LEFT OUTER JOIN Lookups.Counties C ON C.CountyID = m.CountyID
Where SES.IsDeleted = 0
And S.IsDeleted = 0
And M.IsDeleted = 0


CLOSE SYMMETRIC KEY SymmetricKey1;
