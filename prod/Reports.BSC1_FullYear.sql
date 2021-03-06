
With totalRecruitedStudentsCte (TotalRecruitedStudents, OfficeName, OfficeID) As
	(
		Select Count(ss.CountyID) As TotalRecruitedStudents,
			o.OfficeName,
			ss.OfficeID
		From Students.Students ss
			Join Offices.Offices o
				On ss.OfficeID = o.OfficeID
		WHERE ss.StudentStatusID
				In (1, 3, 4, 5)
			And ss.ContractSignedDate Between '2020-06-04' And '2021-06-03'
			And ss.IsDeleted = 0
			and o.OfficeID not in (18,19,20)
		Group By o.OfficeName, ss.OfficeID
	),

	Data1totalRecruitedStudentsCTE (TotalRecruitedStudents, OfficeName, OfficeID) AS
	/* Special Case table for Datapoint 1 Denominator */
	(
		SELECT
			Count(ss.countyid) As totalrecruitedstudents,
			o.officename,
			ss.officeidZZ
		FROM students.students ss
		INNER JOIN offices.offices o ON ss.officeid = o.officeid
		WHERE 1=1
			AND ss.studentstatusid IN (1, 3, 4, 5)
			AND ss.contractsigneddate BETWEEN '2020-06-04' And '2021-06-03'
			AND ss.isdeleted = 0
			AND NOT ( (ss.enrollmentvariance = 1) OR (ss.wfieligible = 1) AND ss.EntryGradeLevelID IN (10,11) )
			AND o.officeid NOT IN (18,19,20)
		GROUP BY o.officename, ss.officeid
	)



	, totalActiveStudentsformeasuresCte (TotalActiveStudents, OfficeName, OfficeID) As
	(
		Select Count(ss.CountyID) As TotalActiveStudents,
			o.OfficeName,
			ss.OfficeID
		From Students.Students ss
        Join Offices.Offices o On ss.OfficeID = o.OfficeID
		WHERE
            ss.StudentStatusID In (1, 3, 4, 5)
			And ss.ContractSignedDate < '2020-11-01'
			And ss.IsDeleted = 0
			and o.OfficeID not in (18,19,20)
			AND SS.isdeleted = 0
		Group By  o.OfficeName, ss.OfficeID

	)

	, totalActiveStudentsByEntryGradeCte (TotalActiveStudents, OfficeName, EntryGrade,  OfficeID) As
	(
		Select isnull(Count(ss.CountyID),0) As TotalActiveStudents,
			o.OfficeName,
			ss.EntryGradeLevelID  AS EntryGrade,
			ss.OfficeID
		From Students.Students ss
		Join Offices.Offices o On ss.OfficeID = o.OfficeID
		WHERE ss.StudentStatusID In (1, 3, 4, 5)
			And ss.ContractSignedDate  Between '2020-06-04' And '2021-06-03'
			and ss.EntryGradeLevelID in (6,7,8,9)
			and o.OfficeID not in (18,19,20)
			AND SS.isdeleted = 0
		Group By ss.EntryGradeLevelID, o.OfficeName, ss.OfficeID

	)

	, totalActiveStudentsBytypeCte (TotalActiveStudents, OfficeName, StudentType,  OfficeID) As
	(
		Select Count(ss.CountyID) As TotalActiveStudents,
			o.OfficeName,
			case when sap.PriorityType is null then ss.PriorityType
			else sap.PriorityType  end AS studenttype,
			ss.OfficeID
		From Students.Students ss
        Join Offices.Offices o On ss.OfficeID = o.OfficeID
        left join students.Applications sap on sap.StudentID = ss.StudentID
		WHERE ss.StudentStatusID In (1, 3, 4, 5)
				And ss.ContractSignedDate Between '2020-06-04' And '2021-06-03'
				and COALESCE(ss.PriorityType ,sap.PriorityType) = 2
				and o.OfficeID not in (18,19,20)
		Group By sap.PriorityType, ss.PriorityType, o.OfficeName, ss.OfficeID

	)

	, totalActiveStudentsByGPACte (TotalActiveStudents, OfficeName, EntryGPA,  OfficeID) As
	(
		Select Count(ss.CountyID) As TotalActiveStudents,
			o.OfficeName,
			case when sap.GPA = 0.00  then ss.EntryGPA
				when sap.GPA is null then ss.EntryGPA
			else sap.GPA  end AS EntryGPA,
			ss.OfficeID
		From Students.Students ss
			Join Offices.Offices o
				On ss.OfficeID = o.OfficeID
				left join students.Applications sap on sap.StudentID = ss.StudentID
		WHERE ss.StudentStatusID In (1, 3, 4, 5)
			And ss.ContractSignedDate
				Between '2020-06-04' And '2021-06-03'
				and COALESCE(ss.EntryGPA,sap.GPA) >= 2.0
				and o.OfficeID not in (18,19,20)
				AND sap.isdeleted = 0
				AND SS.isdeleted = 0
		Group By sap.GPA, ss.EntryGPA, o.OfficeName, ss.OfficeID

),
 totalEventsCte ( OfficeName, AllEvents, Totalevents, FAFSA, SeniorCollegePrep, NSO, CRE, OfficeID) As
	(
		Select
			o.OfficeName,
			ws.TotalCollegeReadiessWorkshops
			,case when ws.[FAFSA/FinancialAidEvents] = 0 or ws.SeniorCollegePrepEvents = 0 or ws.NewStudentOrientationEvents = 0 or ws.CollegeReadinessEvents < 2 then 0
					else ws.TotalCollegeReadiessWorkshops
					end AS total
				,ws.[FAFSA/FinancialAidEvents]
				,ws.SeniorCollegePrepEvents
				,ws.NewStudentOrientationEvents
				,ws.CollegeReadinessEvents
			,ws.OfficeID
		From reports.BSC__nCRWorkshops ws
			left join Offices.offices o on o.OfficeID = ws.OfficeID
			WHERE o.OfficeID not in (18,19,20)
		Group By   o.OfficeName, ws.OfficeID, ws.CollegeReadinessEvents,
		ws.[FAFSA/FinancialAidEvents], ws.NewStudentOrientationEvents, ws.TotalCollegeReadiessWorkshops, ws.SeniorCollegePrepEvents, ws.CollegeReadinessEvents



	),

	totalStudentsWithGPACte (TotalStudentsWithGPA, OfficeName, OfficeID) As
	(
		Select Count(distinct(sg.StudentID)) As TotalStudentsWithGPA,
			o.OfficeName
			,ss.OfficeID
		From Students.Students ss
        left Join Students.GPA sg On ss.StudentID = sg.StudentID
		Join Offices.Offices o On ss.OfficeID = o.OfficeID
		Where
          ss.StudentStatusID In (1, 3, 4, 5)
			And ss.CurrentGradeLevelID  IS NOT NULL
			And sg.SemesterEndDate Between '2020-11-01' And '2021-03-31'
			And sg.SchoolTermTypeID in (17, 30, 0)
			And (sg.SemesterUnweighted > 0 Or sg.CumulativeUnweighted > 0)
			And sg.IsDeleted = 0
			And ss.ContractSignedDate  < '2020-11-01'
			and o.OfficeID not in (18,19,20)
			AND SS.isdeleted = 0
		Group By o.OfficeName, ss.OfficeID

	),

	 CollegeSuccessCoachVisits (OfficeName, TotalVisit, ccu, StudentID, Grade, OfficeID) as

	(Select
			o.officename
			,(
			    Select Count(sc.StudentID)
			    From Students.Communications sc
				left join reports.BSC_Dates b on ss.StudentID = b.studentid
		        Where ss.StudentStatusID In (1, 3, 4, 5)
                And  ((b.IsTransfer = 0 and  sc.NoteDate Between '2020-07-01' AND '2021-06-30') or (b.IsTransfer = 1 and  sc.NoteDate Between b.MMCSCDate AND '2021-06-30'))
                and b.MMCSCDate <= '2021-03-31'
                And sc.StudentCommunicationTypeID = 1
                And sc.IsDeleted = 0
                and ss.StudentID = sc.StudentID
                --and
			) as TotalVisits
			, 1 as 'ccu'
			,ss.StudentID
			,ss.CurrentGradeLevelID
			,ss.OfficeID
		From Students.Students ss
        left Join Offices.Offices o On ss.OfficeID = o.OfficeID
		left Join Students.Communications sc On ss.StudentID = sc.StudentID
		left join reports.BSC_Dates bd on ss.StudentID = bd.studentid
		WHERE ss.StudentStatusID
			In (1, 3, 4, 5)
			--And ss.ContractSignedDate < '2018-11-01'
			and ss.IsDeleted = 0
			and bd.MMCSCDate <= '2021-03-31'
			and o.IsDeleted = 0
			and o.OfficeID not in (18,19,20)
		Group By ss.StudentID, ss.StudentStatusID, o.officename, CurrentGradeLevelID, ss.OfficeID
    ),

	CVKPI (KPI, OfficeName, TotalSVisit, OfficeID) as

(

	select
			(Select cast(count(csce.StudentID) as int)
				from CollegeSuccessCoachVisits csce
				left join reports.BSC_Dates bdi on bdi.studentid = csce.StudentID
				 WHERE (
                        (csce.Grade between 11 and 12 and csce.TotalVisit >=4 and bdi.MMCSCDate <= '2020-10-31')
                       or (csce.Grade between 5 and 10 and csce.TotalVisit >=2 and bdi.mmcscdate <= '2020-10-31')
                       or (csce.grade between 11 and 12 and csce.TotalVisit >=2 and bdi.MMCSCDate between '2020-11-01' and '2021-03-31')
                       or (csce.Grade between 5 and 10 and csce.TotalVisit >=1 and bdi.mmcscdate between '2020-11-01' and '2021-03-31')
					)
				 and csce.OfficeID = ss.OfficeID
			)as KPI
			,o.OfficeName
			,(
			    Select Cast(count(csc.StudentID) as int)
				from Students.Students csc
				left join reports.BSC_Dates bdi on bdi.StudentID = csc.StudentID
                WHERE 1=1
                  and csc.OfficeID = ss.OfficeID
                  and bdi.MMCSCDate <= '2021-03-31'
                  and csc.StudentStatusID in (1,3,4,5)
                  and csc.IsDeleted = 0
			) TotalVisit
			,ss.OfficeID

	From Students.Students ss
	left join CollegeSuccessCoachVisits cscv on ss.StudentID = cscv.StudentID
	left join Offices.Offices o on o.OfficeID = ss.OfficeID
 WHERE o.IsDeleted = 0 and cscv.OfficeID not in (18,19,20) AND SS.isdeleted = 0
	group by  o.OfficeName, ss.OfficeID
	)

	, K12StudentsMissingData (studentid, officeid) AS (
	SELECT DISTINCT studentid, officeid
	FROM Reports.BSC__nStudentsMissingData bsc_stud
	)

	, MentorsMissingData (mentorid, officeid) AS (
	SELECT DISTINCT mentorid, officeid
	FROM Reports.BSC_MentorsMissingdata
	)

	, K12StudentsMissingScholarshipData (studentid, officeid) AS (
	SELECT DISTINCT studentid, officeid
	FROM Reports.BSC__nScholarshipAssignment bsc_studschol
	)

	, GradsMissingData (studentid, officeid) AS (
	SELECT DISTINCT studid, officeid
	FROM Reports.BSC_GradInfo
	WHERE Dualenrollmentcredits IS NULL OR BrightFutureName IS NULL OR APCredits IS NULL
	)

	, K12StudentsMissingTimelyMatch (studentid, officeid ) AS (
	SELECT DISTINCT studentid, officeid
	FROM Reports.BSC__nTimelyMentorMatch
	WHERE timelymatch = 'False'
	OR timelymatch IS NULL
	)

	, AllStudentsMissingData (stotal, officeid) AS (
		SELECT DISTINCT COUNT(studentid), officeid
		FROM (
			SELECT studentid, officeid FROM K12StudentsMissingData
			UNION
			SELECT studentid, officeid FROM K12StudentsMissingScholarshipData
			UNION
			SELECT studentid, officeid FROM GradsMissingData
			UNION
			SELECT studentid, officeid FROM K12StudentsMissingTimelyMatch
		) a
		GROUP BY officeid
	)

	, AllMentorsMissingData (mtotal, officeid) AS (
		SELECT DISTINCT COUNT(mentorid), officeid
		FROM (
			SELECT mentorid, officeid FROM MentorsMissingData
		)b
		GROUP BY officeid
	)

	,EveryoneMissingData (total, officeid) AS (
		SELECT ISNULL(stotal,0) + ISNULL(mtotal,0), offic.officeid
		FROM offices.offices offic
		LEFT JOIN allstudentsmissingdata studmiss ON studmiss.officeid=offic.officeid
		LEFT JOIN allmentorsmissingdata mentormiss ON offic.officeid=mentormiss.officeid
	)

	,DataDenom (OfficeName, TotalDatapoints, OfficeID) as
		(Select
			o.OfficeName,
			Cast((
					(
					select DISTINCT count(ss.StudentID)
					from students.students ss
					left join offices.offices oo on oo.OfficeID = ss.OfficeID
					where  ss.IsDeleted = 0 and o.OfficeID = ss.OfficeID and
								((ss.StudentStatusID in (1,3,4,5) and ss.CurrentGradeLevelID between 5 and 12) OR (ss.StudentStatusID in (11,12,13,14,15,28) and ss.GraduationYear = 2020))
					)
						+
					(
					select DISTINCT count(mm.MentorID)
					from Mentors.Mentors mm
					left join offices.offices oo on oo.OfficeID = mm.OfficeID
					where mm.MentorStatusID = 1  and mm.IsDeleted = 0 and o.OfficeID = mm.OfficeID
					)

				) AS INT)AS TotalDataPoints
			,o.OfficeID
		From Offices.offices o
		WHERE o.IsDeleted = 0 and o.OfficeID not in (18,19,20)
		)


	Select
		1 As DataPointNumber,
		'Percent of students recruited in grades 6-9' as 'Metric',
		--acte.CountyID,
		offic.OfficeName,
		SUM(acte.TotalActiveStudents)  As KPI, --ValueMatch, -- Count of students that match
		tr.TotalRecruitedStudents As Total, -- Total recruited students for same period
		CONVERT(Int, ROUND(ROUND((IsNull(SUM(acte.totalactivestudents), 0) / CAST(tr.TotalRecruitedStudents As Decimal)) * 100,1),0)) As Result,
		CASE
            when ROUND(ROUND((IsNull(sum(acte.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,1),0) between 95 and 100 then 10
            when ROUND(ROUND((IsNull(sum(acte.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,1),0) between 85 and 94 then 8
            when ROUND(ROUND((IsNull(sum(acte.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,1),0) < 85 then 0
            else ''
            end as Points,
		'' as Comments,
		offic.OfficeID
	From offices.offices offic
	LEFT JOIN totalActiveStudentsByEntryGradeCte acte ON offic.officeid=acte.officeid
	Left Outer Join Data1totalRecruitedStudentsCTE tr on acte.OfficeID = tr.OfficeID
	WHERE offic.officeid NOT IN (18,19,20,7,26,29,51)
	group by offic.OfficeName, tr.TotalRecruitedStudents, offic.OfficeID

Union

	Select
		2 As DataPointNumber,
		'Percent of students recruited as Type 2' as 'Metric',
		--actt.CountyID,
		office.OfficeName,
		SUM(actt.TotalActiveStudents)  As KPI, --ValueMatch, -- Count of students that match
		tr.TotalRecruitedStudents As Total, -- Total recruitedCollegeSuccessCoachVisits students for same period
		Convert(Int, ROUND((IsNull(sum(actt.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,0)) As Result,
		CASE
			when Convert(Int, ROUND((IsNull(sum(actt.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,0)) between 75 and 85 then 10
			when Convert(Int, ROUND((IsNull(sum(actt.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,0)) between 86 and 100 then 8
			when Convert(Int, ROUND((IsNull(sum(actt.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,0)) between 65 and 74 then 8
			when Convert(Int, ROUND((IsNull(sum(actt.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,0)) < 64 then 0
		else ''
		end as Points,
		'' as Comments,
		office.OfficeID
	From offices.offices office
	LEFT JOIN totalActiveStudentsBytypeCte actt ON office.officeid=actt.officeid
	Left Outer Join totalRecruitedStudentsCte tr on actt.OfficeID = tr.OfficeID
	WHERE office.officeid NOT IN (7,18,19,20,26,29,51)
	group by  office.OfficeName, tr.TotalRecruitedStudents, office.OfficeID


union

Select
		3 As DataPointNumber,
		'Percent of students recruited with >2.0 GPA' as 'Metric',
		--actg.CountyID,
		offic.OfficeName,
		SUM(actg.TotalActiveStudents)  As KPI, --ValueMatch, -- Count of students that match
		tr.TotalRecruitedStudents As Total, -- Total recruited students for same period
		Convert(Int, ROUND((IsNull(sum(actg.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,0)) As Result,
		CASE
            when Convert(Int, ROUND((IsNull(sum(actg.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,0)) = 100 then 5
            when Convert(Int, ROUND((IsNull(sum(actg.totalactivestudents), 0) / Cast(tr.TotalRecruitedStudents As Decimal)) * 100,0)) < 100 then 0
		    else ''
		end as Points,
		'' as Comments,
		offic.OfficeID
	From offices.offices offic
	LEFT JOIN totalActiveStudentsByGPACte actg ON offic.officeid=actg.officeid
	Left Outer Join totalRecruitedStudentsCte tr on actg.OfficeID = tr.OfficeID
	WHERE offic.officeid NOT IN (18,19,20,7,26,29,51)
	group by  offic.OfficeName, tr.TotalRecruitedStudents, offic.OfficeID

union

Select
		4 As DataPointNumber,
		'Meeting CR Workshop Requirement' as 'Metric',
		--te.CountyID,
		te.OfficeName,
		SUM(te.AllEvents)  As KPI, --ValueMatch
		5 As Total, -- Total
        CASE
            when te.FAFSA = 0 or te.NSO = 0 or te.SeniorCollegePrep = 0 or te.CRE = 0 then Convert(Int, ROUND((IsNull(sum(te.Totalevents), 0) / Cast(5 As Decimal)) * 100,0))
		    when te.FAFSA > 0 and te.NSO >= 0 and te.SeniorCollegePrep > 0 and te.CRE > 0 then Convert(Int, ROUND((IsNull(sum(te.AllEvents), 0) / Cast(5 As Decimal)) * 100,0))
		    else''
		    end As Result, -- percent
		CASE when sum(te.Totalevents) >=6 then 5
			when sum(te.Totalevents) =5 then 3
			when sum(te.Totalevents) <5 then 0
		else ''
		end as Points,
	CASE when te.FAFSA = 0 and te.NSO = 0 and te.SeniorCollegePrep = 0 and te.CRE < 2 then 'Missing FAFSA, New Student Orientation, College Readiness Workshops, and Senior College Prep Workshops'
	when te.FAFSA = 0 and te.NSO = 0 and te.CRE < 2 then 'Missing FAFSA, College Readiness Events, and New Student Orientation Workshops'
	when te.FAFSA = 0 and te.SeniorCollegePrep = 0 and te.CRE < 2 then 'Missing FAFSA, College Readiness Events, and Senior College Prep Workshops'
	when te.FAFSA = 0 and te.SeniorCollegePrep = 0 and te.NSO = 0 then 'Missing FAFSA, Senior College Prep Workshops, and New Student Orientation'
	when te.NSO = 0 and te.SeniorCollegePrep = 0 and te.CRE < 2 then 'Missing New Student Orientation, College Readiness Events, and Senior College Prep Workshops'
	when te.FAFSA = 0 and te.CRE < 2 then 'Missing FAFSA and College Readiness Events'
	when te.NSO = 0 and te.CRE < 2 then 'Missing New Student Orientation and College Readiness Events'
	when te.SeniorCollegePrep = 0 and te.CRE < 2 then 'Missing Senior College Prep and College Readiness Events'
	when te.FAFSA = 0 and te.NSO = 0 then 'Missing FAFSA and New Student Orientation Workshops'
	when te.FAFSA = 0 and te.SeniorCollegePrep = 0 then 'Missing FAFSA and Senior College Prep Workshops'
	when te.NSO = 0 and te.SeniorCollegePrep = 0 then 'Missing New Student Orientation and Senior College Prep Workshops'
	when te.FAFSA = 0 then 'Missing FAFSA Workshop'
	when te.NSO = 0 then 'Missing New Student Orientation Workshop'
	when te.SeniorCollegePrep = 0 then 'Missing Senior College Prep Workshop'
	when te.CRE < 2  then 'Missing College Readiness Workshop'
	else ''
	end
	as Comments,
		te.OfficeID
	From offices.offices o
	LEFT JOIN totalEventsCte te ON o.officeid=te.officeid
    	WHERE o.officeid NOT IN (18,19,20,7,26,29,51)
	group by te.OfficeName, te.OfficeID, te.NSO, te.SeniorCollegePrep, te.FAFSA, te.CRE

Union

Select
		5 As DataPointNumber,
		'Percent of Students with Semester 1 GPA' as 'Metric',
		--tacm.CountyID,
		tacm.OfficeName,
		IsNull(sum(swg.TotalStudentsWithGPA), 0)  As KPI, --ValueMatch
		tacm.TotalActiveStudents As Total, -- Total
		Convert(Int, Ceiling((IsNull(sum(swg.TotalStudentsWithGPA), 0) / Cast(tacm.TotalActiveStudents As Decimal)) * 100)) As Result,
		CASE when Convert(Int, Ceiling((IsNull(sum(swg.TotalStudentsWithGPA), 0) / Cast(tacm.TotalActiveStudents As Decimal)) * 100)) between 95 and 100 then 5
		when Convert(Int, Ceiling((IsNull(sum(swg.TotalStudentsWithGPA), 0) / Cast(tacm.TotalActiveStudents As Decimal)) * 100)) between 85 and 94 then 3
		when Convert(Int, Ceiling((IsNull(sum(swg.TotalStudentsWithGPA), 0) / Cast(tacm.TotalActiveStudents As Decimal)) * 100)) < 85 then 0
		else ''
		end as Points,
		'' as Comments,
		tacm.OfficeID
	From totalActiveStudentsformeasuresCte tacm
		left join totalStudentsWithGPACte swg  on swg.OfficeID = tacm.OfficeID
	group by  tacm.OfficeName, tacm.OfficeID, tacm.TotalActiveStudents

Union

Select
		6 As DataPointNumber,
		'Percent of students receiving college readiness contact' as 'Metric',
		--CVKPI.CountyID,
		CVKPI.OfficeName,
		CVKPI.KPI As KPI, --ValueMatch
		CVKPI.TotalSVisit As Total -- Total
		,CONVERT(INT, ROUND(ROUND((IsNull((cvkpi.kpi), 0) / CAST(cvkpi.totalSvisit As Decimal)) * 100, 1),0)) As Result,
		CASE
			WHEN CONVERT(INT, ROUND(ROUND((IsNull((cvkpi.kpi), 0) / CAST(cvkpi.totalSvisit As Decimal)) * 100, 1),0)) BETWEEN 95 AND 100 THEN 15
			WHEN CONVERT(INT, ROUND(ROUND((IsNull((cvkpi.kpi), 0) / CAST(cvkpi.totalSvisit As Decimal)) * 100, 1),0)) between 85 and 94 then 12
			WHEN CONVERT(INT, ROUND(ROUND((IsNull((cvkpi.kpi), 0) / CAST(cvkpi.totalSvisit As Decimal)) * 100, 1),0)) < 85 then 0
		else ''
		end as Points,
		'' as Comments
		,CVKPI.OfficeID
	From CollegeSuccessCoachVisits cscv
			left join CVKPI on cscv.OfficeID = CVKPI.OfficeID
	group by  CVKPI.OfficeName, CVKPI.KPI, CVKPI.TotalSVisit, CVKPI.OfficeID



Union

Select
		7 As DataPointNumber,
		'Required Data' as 'Metric',
		--CVKPI.CountyID,
		offic.OfficeName,
		(dd.TotalDatapoints - e.total) As KPI, --ValueMatch
		dd.TotalDatapoints As Total -- Total
		,Convert(Int, floor((((dd.TotalDatapoints - e.total)) / Cast(dd.TotalDatapoints As Decimal)) * 100)) As Result,
		CASE when Convert(Int, floor((((dd.TotalDatapoints - e.total)) / Cast(dd.TotalDatapoints As Decimal)) * 100)) >=95 then 12.5
		when Convert(Int, floor((((dd.TotalDatapoints - e.total)) / Cast(dd.TotalDatapoints As Decimal)) * 100)) between 90 and 94 then 7
		when Convert(Int, floor((((dd.TotalDatapoints - e.total)) / Cast(dd.TotalDatapoints As Decimal)) * 100))  < 90 then 0
		else ''
		end as Points,
		'' as Comments
		,offic.OfficeID
	From offices.offices offic
	LEFT JOIN DataDenom dd ON offic.officeid=dd.OfficeID
	LEFT JOIN everyonemissingdata e ON offic.officeid=e.officeid
	WHERE offic.officeid NOT IN (18,19,20,7,26,29,51)


