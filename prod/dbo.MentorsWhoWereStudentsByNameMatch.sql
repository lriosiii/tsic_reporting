OPEN SYMMETRIC KEY SymmetricKey1
DECRYPTION BY CERTIFICATE Certificate1;

SELECT     s.LastName AS StudentLastName, s.FirstName AS StudentFirsttName, m.LastName AS MentorLastName, m.FirstName AS MentiorFirstName, CONVERT(varchar, DecryptByKey(EncryptedBirthDate)) AS 'BirthDate'
FROM         Students.Students AS s LEFT OUTER JOIN
                      Mentors.Mentors AS m ON m.LastName = s.LastName AND m.FirstName = s.FirstName
WHERE     (m.LastName IS NOT NULL) AND (CONVERT(DATETIME, DecryptByKey(EncryptedBirthDate)) > CONVERT(DATETIME, '1977-01-01 00:00:00', 102)) AND (m.MentorStatusID = 1) AND (m.FormerStudent = 1)


CLOSE SYMMETRIC KEY SymmetricKey1;