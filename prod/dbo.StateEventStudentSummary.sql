SELECT
	officename,
	eventname,
	SUM(CASE WHEN attended = 'Y' THEN 1 ELSE 0 END) AS attendees,
	SUM(CASE WHEN invited = 'Y' THEN 1 ELSE 0 END) AS invitees,
	(SELECT COUNT(*) FROM students.students s
		INNER JOIN Lookups.StudentStatuses SS ON S.StudentStatusID = SS.StudentStatusID
		WHERE s.IsDeleted = 0 and s.officeid=seslv.officeid and s.currentgradelevelid = 12 and ss.StatusGroupID = 1 ) AS activeseniorcount
FROM dbo.StateEventStudentListView seslv
GROUP BY officeid, officename, eventname