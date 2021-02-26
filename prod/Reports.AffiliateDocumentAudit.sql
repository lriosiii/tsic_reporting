SELECT studentid as "id", firstname, lastname, officename, 'Student' as "Type"
FROM students.students s
LEFT JOIN offices.offices o ON o.officeid=s.officeid
WHERE
      s.isdeleted = 0
     AND s.studentstatusid IN (1,3,4,5)

UNION

SELECT mentorid as "id", firstname, lastname, officename, 'Mentor' as "Type"
FROM mentors.mentors m
LEFT JOIN offices.offices o ON o.officeid=m.officeid
WHERE
      m.isdeleted = 0
     AND m.mentorstatusid=1

UNION

SELECT staffid as "id", firstname, lastname, officename, 'Staff' as "Type"
FROM offices.staff staff
LEFT JOIN offices.offices o ON o.officeid=staff.officeid
WHERE staff.isdeleted = 0;
