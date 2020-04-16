SELECT m1.lastname, m1.firstname, m1.emailaddress, o.officename, mentorstatusname
FROM mentors.mentors m1
JOIN (SELECT  m2.emailaddress, COUNT(*) AS m2Count FROM mentors.mentors m2 GROUP BY m2.emailaddress HAVING count(*) > 1 ) m2 ON m1.emailaddress = m2.emailaddress
JOIN offices.offices o ON m1.officeid=o.officeid
JOIN lookups.mentorstatuses mstat ON mstat.mentorstatusid=m1.mentorstatusid
WHERE m1.isdeleted = 0 and m1.mentorstatusid = 1
