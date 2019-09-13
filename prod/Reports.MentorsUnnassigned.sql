SELECT     CONVERT(varchar, DecryptByKey(Mentors.Mentors.EncryptedSSN)) AS SSN, Mentors.Mentors.FirstName, Mentors.Mentors.MiddleName, Mentors.Mentors.LastName, CONVERT(varchar, DecryptByKey(Mentors.Mentors.EncryptedBirthDate)) AS BirthDate,
                      Mentors.Mentors.HomePhoneNumber, Mentors.Mentors.MobilePhoneNumber, Mentors.Mentors.WorkPhoneNumber, Mentors.Mentors.PagerPhoneNumber,
                      Mentors.Mentors.EmailAddress, Mentors.Mentors.AdditionalEmailAddress, Mentors.Mentors.EmailPreferred, Mentors.Mentors.Gender,
                      Mentors.Mentors.EmployerName, Mentors.Mentors.PreviousEmployerName, Mentors.Mentors.JobTitle, Mentors.Mentors.CompanyName, Mentors.Mentors.Predator,
                      Mentors.Mentors.OfficeID, Mentors.Mentors.MentorAffiliationName, Mentors.Mentors.ReferredBy, Mentors.Mentors.RecruitedBy,
                      Mentors.Mentors.WelcomePacketSent, Mentors.Mentors.AmericorMentor, CONVERT(varchar, DecryptByKey(Mentors.Mentors.EncryptedDriversLicense)) AS DriversLicense, Mentors.Mentors.IDExpires,
                      Mentors.Mentors.ClearanceID, Mentors.Mentors.FingerPrintDate, Mentors.Mentors.FingerPrintExpireDate, Mentors.Mentors.GoodbyeLetterDate,
                      Mentors.Mentors.LiabilityReleaseOnFile, Mentors.Mentors.FormerStudent, Mentors.Mentors.ReferenceLetter, Mentors.Mentors.ReferenceLetterReceivedDate,
                      Mentors.Mentors.IsVIP, Mentors.Mentors.MatchLetterDate, Mentors.Mentors.MatchLetter2Date, Mentors.Mentors.MatchLetter3Date,
                      Mentors.Mentors.MatchLetter4Date, Mentors.Mentors.VolunteerApplication, Mentors.Mentors.VolunteerApplicationNumber, Mentors.Mentors.SchoolEmployee,
                      Mentors.Mentors.TrainingCompletedDate, Mentors.Mentors.IsHispanic, Mentors.Mentors.PhotoFile, Mentors.Mentors.BackgroundCheckExpirationDate,
                      Mentors.Mentors.Note, Lookups.MentorStatuses.MentorStatusName, Lookups.Counties.CountyName, Students.StudentMentors.UnassignedDate, Students.StudentMentors.AssignedDate,
					  ca.Address1, ca.Address2, ca.City, ca.StateID, ca.ZipCode, Mentors.Applications.ApplicationStartDate
FROM         Mentors.Mentors INNER JOIN
                      Lookups.MentorStatuses ON Mentors.Mentors.MentorStatusID = Lookups.MentorStatuses.MentorStatusID AND
                      Mentors.Mentors.MentorStatusID = Lookups.MentorStatuses.MentorStatusID AND Mentors.Mentors.MentorStatusID = Lookups.MentorStatuses.MentorStatusID AND
                      Mentors.Mentors.MentorStatusID = Lookups.MentorStatuses.MentorStatusID AND
                      Mentors.Mentors.MentorStatusID = Lookups.MentorStatuses.MentorStatusID INNER JOIN
                      Lookups.Counties ON Mentors.Mentors.CountyID = Lookups.Counties.CountyID LEFT OUTER JOIN
					  Mentors.Applications ON Mentors.Mentors.MentorID = Mentors.Applications.MentorID LEFT OUTER JOIN
                      Students.StudentMentors ON Students.StudentMentors.MentorID = Mentors.Mentors.MentorID LEFT OUTER JOIN
					  Common.Addresses ca ON mentors.Mentors.AddressID = ca.AddressID
WHERE     (Students.StudentMentors.MentorID IS NULL Or (Students.StudentMentors.MentorID NOT IN
			(Select MentorID From Students.StudentMentors Where AssignedDate IS NOT NULL And UnassignedDate IS NULL)
				))
			AND Mentors.Mentors.IsDeleted = 0
			--AND Students.Students.IsDeleted = 0
--ORDER BY Mentors.Mentors.LastName, Mentors.Mentors.FirstName

