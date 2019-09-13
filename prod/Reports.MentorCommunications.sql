
SELECT  Sal.SalutationName
	  , M.FirstName
	  , M.MiddleName
      , M.LastName
      , M.LastName+ ', '+ M.FirstName as MentorFullName
      , '***-**-' + RIGHT(CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)), 4) As SSNumber
      , CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)) AS BirthDate
      , M.Gender
	  , MC.NoteDate As CommunicationDate
	  , CM.CommunicationMethodName
	  , MC.Note As Communication
	  , OS.LastName + ', ' + OS.FirstName As EnteredByName
	  , U.Username As RecordedByUser
      , A.Address1 as MentorAddress1
      , A.Address2 as MentorAddress2
      , A.City as MentorCity
      , A.StateID as MentorState
      , A.ZipCode as MentorZipCode
      , M.HomePhoneNumber
      , M.MobilePhoneNumber
      , M.WorkPhoneNumber
      , M.EmailAddress
      , CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedDriversLicense)) AS DriversLicense
      , M.EmployerName
      , M.CompanyName
      , M.IsHispanic
	  , M.Predator
	  , M.BackgroundCheckExpirationDate
      , M.FingerPrintDate
      , M.FingerPrintExpireDate
	  , M.TrainingCompletedDate
	  , M.VolunteerApplication
	  , M.VolunteerApplicationNumber
      , M.OfficeID
	  , O.OfficeName
	  , MS.MentorStatusName
FROM Mentors.Mentors M
	LEFT OUTER JOIN Lookups.Salutations Sal on M.salutationID = Sal.SalutationID
	LEFT OUTER JOIN Common.Addresses A ON M.AddressID = A.AddressID
	LEFT OUTER JOIN Offices.Offices O ON M.OfficeID = O.OfficeID
	LEFT OUTER JOIN Lookups.MentorStatuses MS ON M.MentorStatusID = MS.MentorStatusID
	LEFT OUTER JOIN Mentors.Communications MC On M.MentorID = MC.MentorID
	LEFT OUTER JOIN Lookups.CommunicationMethods CM ON MC.CommunicationMethodID = CM.CommunicationMethodId
	LEFT OUTER JOIN Offices.Staff OS ON MC.EnteredByID = OS.StaffID
	LEFT OUTER JOIN [acgsec].[User] U ON U.UserID = MC.RecordedByID
WHERE M.IsDeleted = 0
	AND	MS.IsDeleted = 0
	And MC.IsDeleted = 0
