OPEN SYMMETRIC KEY SymmetricKey1
DECRYPTION BY CERTIFICATE Certificate1;

SELECT  Sal.SalutationName As MentorSalutation
	  , M.FirstName As MentorFirstName
	  , M.MiddleName As MentorMiddleName
      , M.LastName As MentorLastName
      , M.LastName+ ', '+ M.FirstName as MentorFullName
	  , S.FirstName As StudentFirstName
	  , S.MiddleName As StudentMiddleName
	  , S.LastName As StudentLastName
	  , S.LastName + ', ' + S.FirstName As StudentFullName
	  , S.Affiliation
	  , SM.AssignedDate As StudentMatchDate
	  , SM.UnassignedDate
	  , SCH.SchoolName As StudentSchoolName
      , M.SSN
      , M.BirthDate
      , M.Gender
      , A.Address1 as MentorAddress1
      , A.Address2 as MentorAddress2
      , A.City as MentorCity
      , A.StateID as MentorState
      , A.ZipCode as MentorZipCode
      , M.HomePhoneNumber
      , M.MobilePhoneNumber
      , M.WorkPhoneNumber
      , M.EmailAddress
      , M.DriversLicense
      , M.EmployerName
      , M.CompanyName
      , M.IsHispanic
	  , M.MentorStatusID
	  , M.Predator
	  , M.BackgroundCheckExpirationDate
      , R.RaceName
      , JR.JoinReasonName
      , M.FormerStudent
      , M.SchoolEmployee
      , SA.SchoolAreaName as PreferredSchoolArea
      , M.RecruitedBy
      , M.ReferredBy
      , M.IsVIP
      , M.FingerPrintDate
      , M.FingerPrintExpireDate
	  , M.TrainingCompletedDate
	  , M.AmericorMentor
	  , M.AffiliationID
	  , M.VolunteerApplication
	  , M.VolunteerApplicationNumber
	  , M.UserID
      , M.OfficeID
	  , O.OfficeName
	  , MS.MentorStatusName
	  , St.LastName + ', ' + St.FirstName As PrimaryAdvocateName
	  , M.Note
	  , (
			Select MAX(MC.NoteDate)
			From Mentors.Communications MC
			Where M.MentorID = MC.MentorID
	  ) As LastContactDate
	  , (
			Select Max(ms.SessionDate)
			From Students.MentoringSessions ms
			Where M.MentorID = ms.MentorID
			And S.StudentID = ms.StudentID
			And ms.IsDeleted = 0
			And ms.SessionDuration > 0

	  ) As LastSessionDate
	  , (
			Select Min(ms.SessionDate)
			From Students.MentoringSessions ms
			Where M.MentorID = ms.MentorID
			And S.StudentID = ms.StudentID
			And ms.IsDeleted = 0
			And ms.SessionDuration > 0

	  ) As FirstSessionDate

FROM Mentors.Mentors M
	LEFT OUTER JOIN Students.StudentMentors SM On M.MentorID = SM.MentorID
	LEFT OUTER JOIN Students.Students S On SM.StudentID = S.StudentID
	LEFT OUTER JOIN Schools.Schools SCH On S.SchoolID = SCH.SchoolID
	LEFT OUTER JOIN Lookups.Salutations Sal on M.salutationID = Sal.SalutationID
	LEFT OUTER JOIN Common.Addresses A ON M.AddressID = A.AddressID
	LEFT OUTER JOIN Lookups.Races R ON M.RaceID = R.RaceID
	LEFT OUTER JOIN Lookups.JoinReasons JR ON M.JoinReasonID = JR.JoinReasonID
	LEFT OUTER JOIN Lookups.SchoolAreas SA ON M.PreferredSchoolAreaID = SA.SchoolAreaID
	LEFT OUTER JOIN Offices.Offices O ON M.OfficeID = O.OfficeID
	LEFT OUTER JOIN Lookups.MentorStatuses MS ON M.MentorStatusID = MS.MentorStatusID
	LEFT OUTER JOIN Offices.Staff St On M.PrimaryAdvocateID = St.StaffID And St.IsDeleted = 0
WHERE
	M.IsDeleted = 0
	--And O.IsDeleted = 0
	And S.IsDeleted = 0
 --And M.OfficeID = 35
-- ORDER BY M.LastName, M.FirstName    -- For Testing

CLOSE SYMMETRIC KEY SymmetricKey1;