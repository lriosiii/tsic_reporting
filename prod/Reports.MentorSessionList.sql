OPEN SYMMETRIC KEY SymmetricKey1
DECRYPTION BY CERTIFICATE Certificate1;

SELECT   Sal.SalutationName
		,M.FirstName as MentorFirstNane
		, M.LastName as MentorLastName
		, M.FirstName + ' ' + M.LastName as MentorFullName
		, CONVERT(varchar, DecryptByKey(M.EncryptedSSN)) AS SSN
		, MS.MentorStatusName
		, CONVERT(varchar, DecryptByKey(M.EncryptedBirthDate)) as MentorDOB
		, M.HomePhoneNumber
		, M.MobilePhoneNumber
		, M.WorkPhoneNumber
		, M.Gender
		, r.RaceName
		, M.EmployerName
		, M.EmailAddress
		, M.AdditionalEmailAddress
		, S.FirstName as StudentFirstName
		, S.LastName as StudentLastName
		, S.FirstName + ' ' + S.LastName as StudentFullName
		,lss.StudentStatusName
		, S.BirthDate as StudentDOB
		, (
				SELECT Top 1 sm.AssignedDate
				From Students.StudentMentors sm
				Where sm.StudentID = S.StudentID and sm.MentorID = m.MentorID
		  ) As AssignedDate
		  , (
				SELECT Top 1 sm.UnassignedDate
				From Students.StudentMentors sm
				Where sm.StudentID = S.StudentID and sm.MentorID = m.MentorID
		  ) As UnassignedDate
		, SES.SessionDate
		, SES.SessionDuration
		, SES.SessionNote
		, M.OfficeID
		, M.MentorStatusID
		, c.CountyName
		, S.CurrentGradeLevelID
		, M.AmericorMentor
		, Sch.SchoolName
		, S.Affiliation
		, (
				SELECT Top 1 os.DONOR
				From Offices.Scholarships os
				Where os.StudentID = S.StudentID
		  ) As Donor


FROM Mentors.Mentors M
	LEFT OUTER JOIN Lookups.Salutations Sal On M.SalutationID = Sal.SalutationID
	INNER JOIN Common.Addresses A ON M.AddressID = A.AddressID
	INNER JOIN Lookups.MentorStatuses MS ON M.MentorStatusID = MS.MentorStatusID
	INNER JOIN Students.MentoringSessions SES ON M.MentorID = SES.MentorID
	INNER JOIN Students.Students S ON SES.StudentID = S.StudentID
	INNER JOIN lookups.StudentStatuses lss on s.StudentStatusID = lss.StudentStatusID
	INNER JOIN Schools.Schools Sch ON S.SchoolID = Sch.SchoolID
	LEFT OUTER JOIN Lookups.Counties C ON C.CountyID = m.CountyID
	LEFT OUTER JOIN Lookups.Races R on m.RaceID = r.RaceID
WHERE M.IsDeleted = 0
AND S.IsDeleted = 0 and ses.IsDeleted = 0


CLOSE SYMMETRIC KEY SymmetricKey1;