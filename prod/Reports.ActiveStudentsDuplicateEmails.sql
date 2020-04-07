SELECT s1.lastname, s1.firstname, s1.emailaddress, o.officename, studentstatusname
FROM students.students s1
JOIN (SELECT  s2.emailaddress, COUNT(*) AS s2Count FROM students.students s2 GROUP BY s2.emailaddress HAVING count(*) > 1 ) s2 ON s1.emailaddress = s2.emailaddress
JOIN offices.offices o ON s1.officeid=o.officeid
JOIN lookups.studentstatuses mstat ON mstat.studentstatusid=s1.studentstatusid
WHERE s1.isdeleted = 0 and s1.studentstatusid IN (1,3,4,5)
ORDER BY s1.emailaddress, s1.lastname, s1.firstname
