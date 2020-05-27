SELECT  o.OfficeName
	  ,c.CountyName
      ,s.LastName As GradLastName
	  ,s.firstName As GradFirstName
	  ,s.MiddleName As GradMiddleName
	  ,s.Gender As GradGender
	  ,ss.StudentStatusName
	  ,a.Address1 As GradAddress1
	  ,a.Address2 As GradAddress2
	  ,a.City	As GradCity
	  ,a.StateID As GradStateID
	  ,a.ZipCode As GradZipCode
	  ,s.HighSchoolDiplomaDate
	  ,s.GraduationYear
	  ,CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) AS SSN
	  ,CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)) AS GradDOB
	  ,s.HomePhoneNumber As GradHomePhone
	  ,s.WorkPhoneNumber As GradWorkPhone
	  ,s.MobilePhoneNumber As GradMobilePhone
	  ,s.EmailAddress As GradEmail
	  ,sm.LastName As MentorLastName
	  ,sm.FirstName As MentorFirstName
	  ,sm.LastName + ', ' + sm.FirstName As MentorFullName
	  ,sm.Gender As MentorGender
	  ,sm.EmployerName As MentorEmployer
	  ,sm.AssignedDate
	  ,ma.Address1 As MentorAddress1
	  ,ma.Address2 As MentorAddress2
	  ,ma.City As MentorCity
	  ,ma.StateID as MentorStateID
	  ,ma.ZipCode As MentorZipCode
	  ,sm.MobilePhoneNumber As MentorMobilePhone
	  ,sm.WorkPhoneNumber As MentorWorkPhone
	  ,sm.EmailAddress As MentorEmail
	  ,s.OfficeID



  FROM [Students].[Students] s
  LEFT OUTER JOIN Common.Addresses a ON s.AddressID = a.AddressID
  LEFT OUTER JOIN Offices.Offices o On s.OfficeID = o.OfficeID
  LEFT OUTER JOIN Lookups.Counties c on s.CountyID = c.CountyID
  LEFT OUTER JOIN Lookups.StudentStatuses ss ON s.StudentStatusID = ss.StudentStatusID
  LEFT OUTER JOIN Students.GraduateMentors sm ON s.StudentID = sm.StudentID
  LEFT OUTER JOIN Common.Addresses ma on sm.AddressID = ma.AddressID


  Where s.StudentStatusID IN (11,12,13,14,15,25,28)
  AND s.IsDeleted = 0

  --Order By  ContractNumber  --OfficeName, LastName, FirstName
