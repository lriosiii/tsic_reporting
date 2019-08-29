OPEN SYMMETRIC KEY SymmetricKey1
DECRYPTION BY CERTIFICATE Certificate1;

SELECT  Sal.SalutationName
	  , M.FirstName
	  , M.MiddleName
      , M.LastName
      , M.LastName+ ', '+ M.FirstName as MentorFullName
	  ,m.MentorID
      , 'XXX-XX-'+ Right(m.SSN,4) as SSN
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
	  , M.AdditionalEmailAddress
      , M.DriversLicense
      , M.EmployerName
      , M.CompanyName
      , M.IsHispanic
	  , M.MentorStatusID
	  , M.Predator
	  , M.BackgroundCheckExpirationDate
      , R.RaceName
      , JR.JoinReasonName
	  , M.StartDate
	  ,DATEDIFF(year, m.StartDate, Convert (date,(Getdate()))) as YearsMentoring
      , M.FormerStudent
      , M.SchoolEmployee
      , SA.SchoolAreaName as PreferredSchoolArea
      , M.RecruitedBy
      , M.ReferredBy
      , M.IsVIP
	  , MA.ApplicationStartDate as AppStartDate
      , M.FingerPrintDate
      , M.FingerPrintExpireDate
	  , M.TrainingCompletedDate
	  , M.AmericorMentor
	  , M.AffiliationID
	  , M.VolunteerApplication
	  , M.VolunteerApplicationNumber
      , M.OfficeID
	  , O.OfficeName
	  ,co.CountyName
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
			And ms.IsDeleted = 0
			And ms.SessionDuration > 0

	  ) As LastSessionDate
FROM Mentors.Mentors M
	LEFT OUTER JOIN Lookups.Salutations Sal on M.salutationID = Sal.SalutationID
	LEFT OUTER JOIN mentors.Applications ma on m.MentorID = ma.MentorID
	LEFT OUTER JOIN Common.Addresses A ON M.AddressID = A.AddressID
	LEFT OUTER JOIN Lookups.Races R ON M.RaceID = R.RaceID
	LEFT OUTER JOIN Lookups.JoinReasons JR ON M.JoinReasonID = JR.JoinReasonID
	LEFT OUTER JOIN Lookups.SchoolAreas SA ON M.PreferredSchoolAreaID = SA.SchoolAreaID
	LEFT OUTER JOIN Offices.Offices O ON M.OfficeID = O.OfficeID
	LEft OUTER Join lookups.Counties co on co.CountyID = m.CountyID
	LEFT OUTER JOIN Lookups.MentorStatuses MS ON M.MentorStatusID = MS.MentorStatusID
	LEFT OUTER JOIN Offices.Staff St On M.PrimaryAdvocateID = St.StaffID And St.IsDeleted = 0
WHERE
	M.IsDeleted = 0
	--And O.IsDeleted = 0
	--And St.IsDeleted = 0
 --And M.OfficeID = 40


CLOSE SYMMETRIC KEY SymmetricKey1;
