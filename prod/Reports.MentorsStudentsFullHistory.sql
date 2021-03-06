SELECT      Sal.SalutationName, offices.officename, Mentors.Mentors.LastName, Mentors.Mentors.FirstName, Mentors.Mentors.MiddleName, Mentors.mentors.Gender as MentorGender, Lookups.MentorStatuses.MentorStatusName, Students.StudentMentors.IsPrimary as IsPrimary, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, mentors.EncryptedBirthDate)) AS BirthDate,
                      Mentors.Mentors.EmailAddress, Common.Addresses.Address1, Common.Addresses.Address2, Common.Addresses.City, Lookups.States.StateName, Common.Addresses.ZipCode, 
                      Mentors.Mentors.HomePhoneNumber, Mentors.Mentors.MobilePhoneNumber, Mentors.Mentors.WorkPhoneNumber, Mentors.Mentors.PagerPhoneNumber, 
                      Students.Students.LastName AS StudentLastName, Students.Students.FirstName AS StudentFirstName, Students.Students.MiddleName AS StudentMiddleNane, 
                      Mentors.Mentors.FirstName + ' ' + Mentors.Mentors.LastName As MentorName, Students.Students.FirstName + ' ' + Students.Students.LastName As StudentName, Students.students.StudentReferenceID as StudentID,
					  Lookups.StudentStatuses.StudentStatusName, Schools.Schools.SchoolName, Schools.Schools.PrimaryPhoneNumber As SchoolPhoneNumber, Students.Students.CurrentGradeLevelID, Students.students.Gender as StudentGender, Lookups.Counties.CountyName, 
                      Mentors.Mentors.OfficeID, Students.Students.EmailAddress AS StudentEmail, Students.Students.HomePhoneNumber As StudentsHomePhoneNumber, Students.Students.MobilePhoneNumber  As StudentMobilePhoneNumber,Students.StudentMentors.AssignedDate, Lookups.MentorStatuses.MentorStatusID, 
					  Mentors.Mentors.AmericorMentor, Mentors.Mentors.AmericorpsCountyID, os.LastName + ', ' + os.FirstName AS AdvocateName, Students.Students.Affiliation
FROM Mentors.Mentors
LEFT JOIN Lookups.Salutations Sal On Mentors.Mentors.SalutationID = Sal.SalutationID
LEFT JOIN Students.StudentMentors ON Students.StudentMentors.MentorID = Mentors.Mentors.MentorID
LEFT JOIN Students.Students ON Students.StudentMentors.StudentID = Students.Students.StudentID
LEFT JOIN Offices.Staff os ON Students.Students.AdvocateID = os.StaffID
INNER JOIN Schools.Schools ON Students.Students.SchoolID = Schools.Schools.SchoolID
INNER JOIN Lookups.MentorStatuses ON Mentors.Mentors.MentorStatusID = Lookups.MentorStatuses.MentorStatusID AND
              Mentors.Mentors.MentorStatusID = Lookups.MentorStatuses.MentorStatusID AND
              Mentors.Mentors.MentorStatusID = Lookups.MentorStatuses.MentorStatusID
LEFT JOIN Common.Addresses ON Mentors.Mentors.AddressID = Common.Addresses.AddressID
INNER JOIN Lookups.States ON Common.Addresses.StateID = Lookups.States.StateID
INNER JOIN Lookups.StudentStatuses ON Students.Students.StudentStatusID = Lookups.StudentStatuses.StudentStatusID
LEFT JOIN Lookups.Counties ON Mentors.Mentors.CountyID = Lookups.Counties.CountyID
LEFT JOIN offices.offices offices ON mentors.mentors.officeid=offices.officeid
WHERE   --(Mentors.Mentors.MentorStatusID = 1) --AND (Students.Students.StudentStatusID = 1 OR
        -- Students.Students.StudentStatusID = 2 OR
        -- Students.Students.StudentStatusID = 3 OR
        -- Students.Students.StudentStatusID = 4 OR
        -- Students.Students.StudentStatusID = 5)
        -- AND
          (Students.Students.StudentStatusID in (1,3,4,5,11,12,13,15,19,20,21,22,23,24,25,26,27,28))
          --AND (Students.StudentMentors.UnassignedDate IS NULL)
          AND Students.Students.IsDeleted = 0
          AND Mentors.Mentors.IsDeleted = 0
--					  and Mentors.Mentors.OfficeID = 14
--ORDER BY Lookups.Counties.CountyName, Mentors.Mentors.LastName, FirstName
