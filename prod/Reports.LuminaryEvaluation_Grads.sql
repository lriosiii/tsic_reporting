SELECT
	S.FirstName,
	S.LastName,
	s.officeid,
	SS.StudentStatusName,
	S.HomePhoneNumber,
	S.MobilePhoneNumber,
	S.WorkPhoneNumber,
	S.EmailAddress,
    Gender,
	S.IsHispanic,
	R.RaceName,
	S.GraduationYear
FROM  Students.Students AS S
	LEFT OUTER JOIN Schools.Schools AS SC ON S.SchoolID = SC.SchoolID
	LEFT OUTER JOIN Lookups.StudentStatuses AS SS ON S.StudentStatusID = SS.StudentStatusID
	LEFT OUTER JOIN Lookups.Ethnicities AS E ON S.EthnicityID = E.EthnicityID
	LEFT OUTER JOIN Lookups.Races AS R ON S.RaceID = R.RaceID
	--LEFT OUTER JOIN Students.CollegeInformation AS ci ON ci.StudentID = s.StudentID
	--LEFT OUTER JOIN Lookups.Colleges AS SelCol ON SelCol.CollegeID = ci.CollegeID
WHERE
S.graduationyear IN (2014,2015,2016,2017,2018)
and s.OfficeID not in (18,19,20)
and s.isdeleted = 0
AND s.studentstatusid IN (12,13,14,15)