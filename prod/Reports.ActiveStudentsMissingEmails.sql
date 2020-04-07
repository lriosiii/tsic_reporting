SELECT  firstname, lastname, emailaddress, o.officename
FROM students.students s
JOIN offices.offices o ON s.officeid=o.officeid
WHERE s.isdeleted = 0 and studentstatusid IN (1,3,4,5) and (EmailAddress IS NULL OR emailaddress = '' OR emailaddress = ' ')
