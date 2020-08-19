SELECT       
	s.LastName + ', ' + s.FirstName AS StudentName, 
	s.MiddleName, 
	s.StudentStatusID, 
	s.OfficeID, 
	s.CurrentGradeLevelID, 
	s.ContractSignedDate, 
	ss.StudentStatusName, 
    sch.SchoolName, 
	c.CountyName, 
	s.StudentReferenceID, 
	s.StudentID--sm.AssignedDate, sm.MentorID, 
	-- sm.UnassignedDate, sm.IsPrimary, m.LastName + ', ' + m.FirstName As MentorName,
	, (
		SELECT TOP(1) case when d.IsTransfer = 0 then smm.AssignedDate
						when d.IsTransfer = 1 then (SELECT TOP(1)smm.AssignedDate
													FROM Students.StudentMentors smm
													left join Reports.BSC_Dates d on d.StudentID = smm.StudentID
													Where smm.StudentID = s.StudentID and smm.AssignedDate>= d.tdate
													ORDER BY smm.AssignedDate ASC)
					else ''
					end
		FROM Students.StudentMentors smm
		left join Reports.BSC_Dates d on d.StudentID = smm.StudentID
		Where smm.StudentID = s.StudentID
		ORDER BY smm.AssignedDate ASC
	) As AssignedDate,
	(SELECT TOP(1) 
		CASE
		WHEN sm2.AssignedDate IS NULL Then 0
		when d.IsTransfer = 0 then  DateDiff(Day, IsNull(s.ContractSignedDate, '1900-01-01'),  IsNull( sm2.AssignedDate, '1900-01-01'))
		when d.IsTransfer = 1 then DateDiff(Day, IsNull(d.tdate, '1900-01-01'), (SELECT TOP(1)smm.AssignedDate
																						FROM Students.StudentMentors smm
																						left join Reports.BSC_Dates d on d.StudentID = smm.StudentID
																						Where smm.StudentID = s.StudentID and smm.AssignedDate>= d.tdate
																						ORDER BY smm.AssignedDate ASC))
			else ''
		END
		FROM Students.StudentMentors sm2
		left join Reports.BSC_Dates d on d.StudentID = sm2.StudentID
		WHERE s.StudentID = sm2.StudentID
		ORDER BY sm2.AssignedDate ASC
	) As NumberOfDaysToMatch,
CASE WHEN (
		SELECT TOP(1)
			CASE
			WHEN d.istransfer = 0 AND s.ContractSignedDate BETWEEN dbo.LastAcadYearJun6() And dbo.Jun3() AND sm2.AssignedDate <= DATEADD(day,30,s.ContractSignedDate) THEN 'True'
			WHEN d.istransfer = 1  AND (SELECT TOP(1)smm.assigneddate
										FROM students.studentmentors smm
										LEFT JOIN reports.BSC_Dates d ON d.studentid = smm.studentid
										WHERE smm.studentid = s.studentid and smm.assigneddate>= d.tdate
										ORDER BY smm.AssignedDate ASC)<= DATEADD(day,30,d.tdate) THEN 'True'
			--when s.ContractSignedDate < '2016-04-01' then ' '
		ELSE 'False'
		END
		FROM students.studentmentors sm2
		LEFT JOIN reports.bsc_dates d ON sm2.studentid = d.studentid
		WHERE s.studentid = sm2.studentid
		order by sm2.assigneddate asc
		) IS NULL AND (SELECT TOP (1) assigneddate FROM students.studentmentors sm3 WHERE s.studentid=sm3.studentid ORDER BY sm3.assigneddate ASC ) IS NULL AND (datediff(day,s.contractsigneddate, getdate()) > 30 OR datediff(day,dbo.Jun3(),getdate()) < 30 ) THEN 'False'
			ELSE (
				SELECT TOP(1)
				CASE
				WHEN d.istransfer = 0 AND s.ContractSignedDate BETWEEN dbo.LastAcadYearJun6() And dbo.Jun3() AND sm2.AssignedDate <= DATEADD(day,30,s.ContractSignedDate) THEN 'True'
				WHEN d.istransfer = 1  AND (SELECT TOP(1)smm.assigneddate
											FROM students.studentmentors smm
											LEFT JOIN reports.BSC_Dates d ON d.studentid = smm.studentid
											WHERE smm.studentid = s.studentid and smm.assigneddate>= d.tdate
											ORDER BY smm.AssignedDate ASC)<= DATEADD(day,30,d.tdate) THEN 'True'
				--when s.ContractSignedDate < '2016-04-01' then ' '
				ELSE 'False'
				END
				FROM students.studentmentors sm2
				LEFT JOIN reports.bsc_dates d ON sm2.studentid = d.studentid
				WHERE s.studentid = sm2.studentid
				order by sm2.assigneddate asc
			)
			END
					--and Exists (
				--Select Top 1 ssm.AssignedDate
				--		From Students.StudentMentors ssm
				--		Where s.StudentID = ssm.StudentID
				--			And (s.ContractSignedDate Between '2016-08-01' And '2017-03-31'
				--			And DateDiff(day, s.ContractSignedDate, IsNull(ssm.AssignedDate, '1900-01-01')) <= 60)
				--			OR (s.ContractSignedDate Between '2016-04-01' And '2016-07-31'
				--			And ssm.AssignedDate <= '2016-09-30')
					--Order By ssm.AssignedDate Asc) adding to include mentor before, if matched one than once but swapped with an ordered by clause. -DR

					-- ORDER BY s.ContractSignedDate ASC
	 As TimelyMatch,
	(
		SELECT TOP(1) case  when d.IsTransfer = 0  then  sm3.UnassignedDate
							when d.IsTransfer = 1 then (SELECT TOP(1)smm.UnassignedDate
														FROM Students.StudentMentors smm
														left join Reports.BSC_Dates d on d.StudentID = smm.StudentID
														Where smm.StudentID = s.StudentID and smm.AssignedDate>= d.tdate
														ORDER BY smm.AssignedDate ASC)
											end
		FROM Students.StudentMentors sm3
		LEFT JOIN reports.BSC_Dates d on sm3.StudentID = d.StudentID
		WHERE sm3.StudentID = s.StudentID
		ORDER BY sm3.AssignedDate ASC
	) AS UnassignedDate,
	(
	SELECT mn.LastName + ', ' + mn.FirstName As MentorN
	FROM Mentors.Mentors mn
	WHERE mn.MentorID =
		(SELECT TOP(1) case when d.IsTransfer = 0 then sm4.MentorID
							when d.IsTransfer = 1 then (SELECT TOP(1)smm.MentorID
								FROM Students.StudentMentors smm
								left join Reports.BSC_Dates d on d.StudentID = smm.StudentID
								Where smm.StudentID = s.StudentID and smm.AssignedDate>= d.tdate
								ORDER BY smm.AssignedDate ASC)
								end
			FROM Students.StudentMentors sm4
			left join reports.BSC_Dates d on sm4.StudentID = d.StudentID
			WHERE s.StudentID = sm4.StudentID
			ORDER BY sm4.AssignedDate ASC, sm4.IsPrimary DESC )
	) As CurrentMentor,
	(
		SELECT TOP(1) 
			case 
				when d.IsTransfer = 0 then sm5.IsPrimary
				when d.IsTransfer = 1 then (SELECT TOP(1)smm.IsPrimary
											FROM Students.StudentMentors smm
											left join Reports.BSC_Dates d on d.StudentID = smm.StudentID
											Where smm.StudentID = s.StudentID and smm.AssignedDate>= d.tdate
											ORDER BY smm.AssignedDate ASC
											) end
		FROM Students.StudentMentors sm5
		left join reports.BSC_Dates d on sm5.StudentID = d.StudentID
		Where sm5.StudentID = s.StudentID
		ORDER BY sm5.AssignedDate ASC
	) As IsPrimary
					  
FROM	Students.Students AS s 

--INNER JOIN Students.StudentMentors sm On s.StudentID = sm.StudentID 
--INNER JOIN Mentors.Mentors m On sm.MentorID = m.MentorID 
INNER JOIN Lookups.StudentStatuses AS ss ON s.StudentStatusID = ss.StudentStatusID 
INNER JOIN Schools.Schools AS sch ON s.SchoolID = sch.SchoolID 
INNER JOIN Lookups.Counties AS c ON s.CountyID = c.CountyID
LEFT JOIN Reports.BSC_Dates d on d.StudentID = s.StudentID
WHERE 1=1
	AND (s.StudentStatusID In (1,3,4,5))
--	and s.OfficeID =33
	And s.ContractSignedDate Between dbo.LastAcadYearJun6() And dbo.Jun3()
	and d.IsTransfer = 0
			

--and s.officeID = 3

--Order By s.LastName, s.FirstName


--add “Students enrolled between Aug. 1 and Mar. 31 must be matched within 60 days.  Students enrolled between April 1 and July 31 must be matched by Sept 30.” 
