OPEN SYMMETRIC KEY SymmetricKey1
DECRYPTION BY CERTIFICATE Certificate1;

SELECT    sal.SalutationName, m.LastName + ', ' + m.FirstName AS MentorName, a.Address1, a.City, a.StateID, a.ZipCode, CONVERT(varchar, DecryptByKey(M.EncryptedBirthDate)) AS BirthDate, m.Gender, m.HomePhoneNumber, m.EmailAddress,
                      ms.MentorStatusName, m.OfficeID, m.MentorID, m.MobilePhoneNumber, m.WorkPhoneNumber, o.OfficeName,
					  m.CountyID, m.RaceID, m.JoinReasonID, case when mapp.BackgroundCheckPassed = 1 then 'Yes' else 'No' end as BackgroundCheckPassed
					  , mapp.BackgroundCheckReceivedDate, case when mapp.TrainingCompleted = 1 then 'Yes' else 'No' end as TrainingCompleted, m.TrainingCompletedDate, m.FingerPrintDate
FROM         Mentors.Mentors AS m LEFT OUTER JOIN
						mentors.Applications mapp on mapp.MentorID = m.MentorID LEFT OUTER JOIN
						lookups.Salutations sal on sal.SalutationID = m.SalutationID LEFT OUTER JOIN
                      Common.Addresses AS a ON m.AddressID = a.AddressID INNER JOIN
                      Lookups.MentorStatuses AS ms ON m.MentorStatusID = ms.MentorStatusID INNER JOIN
					  Offices.Offices o ON m.officeID = o.OfficeID
WHERE     ((a.Address1 IS NULL AND m.MentorStatusID in (1)) OR
                      (m.MentorStatusID in (1) AND a.City IS NULL) OR
                      (m.MentorStatusID in (1) AND a.StateID IS NULL) OR
                      (m.MentorStatusID in (1) AND a.ZipCode IS NULL) OR
                      (m.MentorStatusID in (1) AND  DecryptByKey(M.EncryptedBirthDate) IS NULL) OR
                      (m.MentorStatusID in (1) AND m.HomePhoneNumber IS NULL AND m.MobilePhoneNumber IS NULL AND m.WorkPhoneNumber IS NULL) OR
                      (m.MentorStatusID in (1) AND m.EmailAddress IS NULL) OR
					  (m.MentorStatusID in (1) AND m.firstname IS NULL) OR
					  (m.MentorStatusID in (1) AND m.LastName IS NULL) OR
					  (m.MentorStatusID in (1) AND m.Gender IS NULL) OR
					  (m.MentorStatusID in (1) AND m.SalutationID IS NULL) OR
					  (m.MentorStatusID in (1) AND m.CountyID IS NULL) OR
					  (m.MentorStatusID in (1) AND m.RaceID IS NULL) OR
					  (m.MentorStatusID in (1) AND m.JoinReasonID IS NULL) OR
					 -- (m.MentorStatusID in (1,6)) AND (mAPP.BackgroundCheckPassed IS NULL) OR
					  (m.MentorStatusID in (1) AND mapp.BackgroundCheckReceivedDate IS NULL) OR
					  --(m.MentorStatusID in (1,6)) AND (mapp.TrainingCompleted IS NULL) OR
					  (m.MentorStatusID in (1) AND m.TrainingCompletedDate IS NULL) OR
					  (m.MentorStatusID in (1) AND m.FingerPrintDate IS NULL))
					  And m.IsDeleted = 0 and mapp.ApplicationStartDate > '2013-12-31'
--AND m.OfficeID = 52



CLOSE SYMMETRIC KEY SymmetricKey1;