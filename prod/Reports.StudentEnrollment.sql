SELECT     S.FirstName, S.MiddleName, S.LastName, S.LastName + ', ' + S.FirstName AS StudentFullName, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, s.EncryptedSSN)), CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)), SS.StudentStatusName,
                      GR.GradeLevelName AS CurrentGradeLevel, DATENAME(MM, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate))) AS BirthdayMonth, RIGHT(N'0' + CONVERT(nvarchar(2), MONTH(CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)))), 2)
                      + '_' + DATENAME(MM, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate))) AS BirthdayNumberMonth, S.HomePhoneNumber, S.MobilePhoneNumber, S.WorkPhoneNumber, S.EmailAddress,
                      CASE WHEN S.Gender = 'M' THEN 'Male' ELSE 'Female' END AS Gender, CNT.CountyName, SAddress.Address1 AS StudentAddress1, 
                      SAddress.Address2 AS StudentAddress2, SAddress.City AS StudentCity, SAddress.StateID AS StudentState, SAddress.ZipCode AS StudentZipCode,
					  AAddress.Address1 As AppAddress1, AAddress.Address2 AS AppAddress2, AAddress.City AS AppCity, AAddress.StateID As AppState, AAddress.ZipCode AS AppZipCode,
					  AppSC.SchoolName AS AppSchoolName, APP.EmailAddress AS AppEmailAddress, APP.HomePhoneNumber AS AppHonePhone, APP.MobilePhoneNumber AS AppMobileNumber,
                          (SELECT     TOP (1) ContactName
                            FROM          Students.Contacts AS PG
                            WHERE      (StudentID = S.StudentID) AND (IsPrimaryGuardian = 1)) AS PrimaryGuardianName,
                          (SELECT     TOP (1) ContactName
                            FROM          Students.Contacts AS SG
                            WHERE      (StudentID = S.StudentID) AND (IsSecondaryGuardian = 1)) AS SecondaryGuardianName, SC.SchoolName, 
                      AD.FirstName + ' ' + AD.LastName AS AdvocateFullName, DATEDIFF(YY, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)), GETDATE()) AS StudentAge,
                          (SELECT     TOP (1) M.FirstName + ' ' + M.LastName AS MentorName
                            FROM          Students.StudentMentors AS SM LEFT OUTER JOIN
                                                   Mentors.Mentors AS M ON SM.MentorID = M.MentorID
                            WHERE      (SM.StudentID = S.StudentID) AND (SM.IsPrimary = 1)) AS MentorName, S.IsHispanic, R.RaceName, 0 AS SomeNewField,
                          (SELECT     SUM(DaysUnExcused) AS DaysUnExcused
                            FROM          Students.Attendance
                            WHERE      (StudentID = S.StudentID)) AS DaysUnExcused, S.OfficeID, S.Gender AS StudentGender, S.GraduationYear, S.EntryGPA, S.EntryGradeLevelID, 
                      S.CurrentGradeLevelID, S.HighSchoolDiplomaDate, S.Gifted, S.LiabilityRelease, S.MedicalRelease, S.MagnetStudent, S.IBDiploma, S.AlumniAlliance, S.Americorp, 
                      S.IsNationalMeritScholar, S.Leaders4LifeFinalist, S.ContractTypeID, S.IsHomeless, S.IBEnrolled, S.STEMEnrolled, S.FPPSeniorPacket, S.DualEnrollmentCredits, 
                      S.APCredits, S.MediaRelease, S.BehavioralCheckDate, S.ContractID, S.StudentTypeID, S.ContractSignedDate, APP.GPA, APP.PriorityType AS StudType, 
                      APP.CurrentGradeLevelID AS EntryGradeLevel, OO.OfficeName
FROM         Students.Students AS S LEFT OUTER JOIN
                      Students.Applications AS APP ON APP.StudentID = S.StudentID AND APP.IsDeleted = 0 LEFT OUTER JOIN
                      Lookups.Counties AS CNT ON S.CountyID = CNT.CountyID LEFT OUTER JOIN
                      Schools.Schools AS SC ON S.SchoolID = SC.SchoolID LEFT OUTER JOIN
					  Schools.Schools AS AppSc  ON APP.SchoolID = AppSC.SchoolID LEFT OUTER JOIN
                      Lookups.StudentStatuses AS SS ON S.StudentStatusID = SS.StudentStatusID LEFT OUTER JOIN
                      Common.Addresses AS SAddress ON S.AddressID = SAddress.AddressID LEFT OUTER JOIN
					  Common.Addresses As AAddress ON APP.AddressID = AAddress.AddressID LEFT OUTER JOIN
                      Lookups.Ethnicities AS E ON S.EthnicityID = E.EthnicityID LEFT OUTER JOIN
                      Lookups.GradeLevels AS GR ON S.CurrentGradeLevelID = GR.GradeLevelID LEFT OUTER JOIN
                      Lookups.Races AS R ON S.RaceID = R.RaceID LEFT OUTER JOIN
                      Offices.Staff AS AD ON S.AdvocateID = AD.StaffID LEFT OUTER JOIN
					  Offices.Offices OO On OO.OfficeID = s.OfficeID
WHERE     (S.StudentStatusID BETWEEN 6 AND 9) AND S.IsDeleted = 0
--AND S.OfficeID = 35 And S.FirstName = 'Caleb'
