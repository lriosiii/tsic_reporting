SELECT  firstname, lastname, emailaddress, o.officename
FROM mentors.mentors m
JOIN offices.offices o ON m.officeid=o.officeid
WHERE m.isdeleted = 0 and mentorstatusid = 1 and (EmailAddress IS NULL OR emailaddress = '' OR emailaddress = ' ')
