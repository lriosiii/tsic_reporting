SELECT     S.FirstName, S.MiddleName, S.LastName, S.LastName + ', ' + S.FirstName AS StudentFullName, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, s.EncryptedSSN)) AS SSN, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, s.EncryptedBirthDate)) AS BirthDate, SS.StudentStatusName, S.Affiliation,
                      GR.GradeLevelName AS CurrentGradeLevel, DATENAME(MM, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, s.EncryptedBirthDate))) AS BirthdayMonth, RIGHT(N'0' + CONVERT(nvarchar(2), MONTH(CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, s.EncryptedBirthDate)))), 2)
                      + '_' + DATENAME(MM, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate))) AS BirthdayNumberMonth, S.HomePhoneNumber, S.MobilePhoneNumber, S.WorkPhoneNumber, S.EmailAddress,
                      CASE WHEN S.Gender = 'M' THEN 'Male' ELSE 'Female' END AS Gender, CNT.CountyName, SAddress.Address1 AS StudentAddress1, 
                      SAddress.Address2 AS StudentAddress2, SAddress.City AS StudentCity, SAddress.StateID AS StudentState, SAddress.ZipCode AS StudentZipCode, SC.SchoolName, 
                      DATEDIFF(YY, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, s.EncryptedBirthDate)), GETDATE()) AS StudentAge, S.IsHispanic, R.RaceName, S.HighSchoolDiplomaDate, S.GraduationYear, SelCol.CollegeName AS SelectedCollege, S.StudentID As StudentBEID,
                          (SELECT     SUM(DaysUnExcused) AS Expr1
                            FROM          Students.Attendance
                            WHERE      (StudentID = S.StudentID)) AS DaysUnExcused, S.OfficeID, S.StudentReferenceID, S.ProbationLevelID, adv.FirstName + ' ' + adv.LastName As AdvocateName
					  , s.HousingScholarship, 'XXX-XX-'+ RIGHT(CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, s.EncryptedSSN)),4) As SocSecNum, S.ContractSignedDate, S.FacebookUsername, S.TwitterAccount
					  ,(SELECT  TOP (1) M.LastName + ', ' + M.FirstName
						FROM Mentors.Mentors M
						INNER JOIN Students.StudentMentors SM ON M.MentorID = SM.MentorID 
						Where (SM.UnassignedDate IS NULL OR SM.UnassignedDate = '')
						AND SM.MentorAssignmentTypeID = 1
						AND SM.StudentID = S.StudentID
						And SM.IsDeleted = 0
					  ) AS PrimaryMentorName
					  ,(SELECT  TOP (1) M.HomePhoneNumber
						FROM Mentors.Mentors M
						INNER JOIN Students.StudentMentors SM ON M.MentorID = SM.MentorID 
						Where (SM.UnassignedDate IS NULL OR SM.UnassignedDate = '')
						AND SM.MentorAssignmentTypeID = 1
						AND SM.StudentID = S.StudentID
						And SM.IsDeleted = 0
					  ) AS PrimaryMentorPhone
					  ,(Select Top(1) os.ContractNumber
						From Offices.Scholarships os
						Where os.StudentID = S.StudentID
						And os.IsDeleted = 0
					  ) As ContractNumber
FROM         Students.Students AS S LEFT OUTER JOIN
                      Lookups.Counties AS CNT ON S.CountyID = CNT.CountyID LEFT OUTER JOIN
                      Schools.Schools AS SC ON S.SchoolID = SC.SchoolID LEFT OUTER JOIN
					  Offices.Staff adv ON S.AdvocateID = adv.StaffID LEFT OUTER JOIN
                      Lookups.StudentStatuses AS SS ON S.StudentStatusID = SS.StudentStatusID LEFT OUTER JOIN
                      Common.Addresses AS SAddress ON S.AddressID = SAddress.AddressID LEFT OUTER JOIN
                      Lookups.Ethnicities AS E ON S.EthnicityID = E.EthnicityID LEFT OUTER JOIN
                      Lookups.GradeLevels AS GR ON S.CurrentGradeLevelID = GR.GradeLevelID LEFT OUTER JOIN
                      Lookups.Races AS R ON S.RaceID = R.RaceID
					  LEFT OUTER JOIN Students.CollegeInformation AS ci ON ci.StudentID = s.StudentID
					  LEFT OUTER JOIN Lookups.Colleges AS SelCol ON SelCol.CollegeID = ci.CollegeID
WHERE s.isdeleted=0
