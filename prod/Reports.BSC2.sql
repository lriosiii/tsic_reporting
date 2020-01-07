WITH -- Common CTE for total active students for the time period (for mentor match rates, etc)
	 totalMentorSessionsCte (TotalMentorSessions, StudentID,IsTransfer) As
	(
		select t.Totalsessions
			,s.studentid
			,t.IsTransfer
			from students.students s
			left join reports.BSC_Dates t on t.Studentid = s.StudentID
			where s.StudentStatusID in (1,3,4,5)
	),

	-- CTE for last mentor/student session date
	--LastMentorSessionDate (LastSessionDate, StudentID) As
	--(
	--	select t.Lastsession
	--		,s.studentid
	--		from students.students s
	--		left join Reports.BSC_Dates t on t.Studentid = s.StudentID
	--		where s.StudentStatusID in (1,3,4,5)
	--),

	---- CTE for last mentor/student session date
	--FirstMentorSessionDate (FirstSessionDate, StudentID) As
	--(
	--	Select t.Firstsession
	--		,s.studentid
	--		from students.students s
	--		left join Reports.BSC_Dates t on t.Studentid = s.StudentID
	--		where s.StudentStatusID in (1,3,4,5)

	--),


	Dates (StartDate, EndDate, StudentID) as
	(
	/*Started with Tranfsers First and then regular students */


		Select case
					WHEN d.IsTransfer = 1 and d.Firstsession is null and d.TstartDates > d.EndDate then Null
					WHEN d.IsTransfer = 1 and d.Firstsession is null and d.TstartDates < d.EndDate then d.TstartDates
					WHEN d.istransfer = 1 and d.tdate < '2019-09-16' THEN '2019-10-15'
					WHEN d.istransfer = 1 and d.tdate > '2019-09-15' AND Convert(date,DATEADD(Day,30,d.tdate)) <= d.firstsession THEN Convert(date,DATEADD(Day,30,d.tdate))
					WHEN d.istransfer = 1 and d.tdate > '2019-09-15' AND Convert(date,DATEADD(Day,30,d.tdate)) > d.firstsession AND d.firstsession <= '2019-10-15' THEN '2019-10-15'
					WHEN d.istransfer = 1 and d.tdate > '2019-09-15' AND Convert(date,DATEADD(Day,30,d.tdate)) > d.firstsession THEN d.firstsession

				    --when ss.ContractSignedDate < '2017-09-16' then Convert (date, '2017-10-15')
					when d.IsTransfer = 0 and d.ContractSignedDate < '2019-09-16' then d.TstartDates
					when d.IsTransfer = 0 and d.ContractSignedDate >= '2019-09-16' and d.FirstSession is null and Convert (date, DATEADD(Day,30,d.ContractSignedDate)) >= d.EndDate then null
					when d.IsTransfer = 0 and d.ContractSignedDate >= '2019-09-16' and d.FirstSession is null and Convert (date, DATEADD(Day,30,d.ContractSignedDate)) < d.EndDate then Convert (date, DATEADD(Day,30,d.ContractSignedDate))
					when d.IsTransfer = 0 and d.ContractSignedDate >= '2019-09-16' and d.FirstSession < '2019-10-15' then Convert (date,'2019-10-15')
				    --when ss.ContractSignedDate >= '2017-09-16' and fmsd.FirstSessionDate > '2017-10-15' then Convert (date,fmsd.FirstSessionDate) took out and split into 2 categories below -DR
					when d.IsTransfer = 0 and d.ContractSignedDate >= '2019-09-16' and d.FirstSession > Convert (date, DATEADD(Day,30,d.ContractSignedDate)) then Convert (date, DATEADD(Day,30,d.ContractSignedDate))
					when d.IsTransfer = 0 and d.ContractSignedDate >= '2019-09-16' and d.FirstSession <= Convert (date, DATEADD(Day,30,d.ContractSignedDate)) then Convert (date,d.FirstSession)


					else ''
				end as StartDate
		,d.EndDate
		,d.StudentID
		--,ss.OfficeID
		from reports.BSC_Dates d--students.Students ss
		--left join FirstMentorSessionDate fmsd on d.StudentID = fmsd.StudentID
		--Where ss.StudentStatusID
		--		In (1, 3, 4, 5)
			--and ss.IsDeleted = 0
		),

	TotalMonths	(TotalMonths, StudentID, OfficeID) as
	(
		Select case when DATEDIFF(DAY,d.StartDate, d.EndDate) <=0 then null
					when Round((DATEDIFF(DAY,d.StartDate, d.EndDate)) /30.0,2) >7.50 then 7.50
					else Round((DATEDIFF(DAY,d.StartDate, d.EndDate)) /30.0,2)

		end as TotalMonths
		,ss.StudentID
		,ss.OfficeID
		from Students.Students ss
		left join Dates d on ss.StudentID = d.StudentID
		Where ss.StudentStatusID
				In (1, 3, 4, 5)
			and ss.IsDeleted = 0

	),

	-- CTE for mentor/student assigned date
	MentorAssignedDate (AssignedDate, DTU, StudentID, OfficeID) As
	(
		Select MIN(sms.AssignedDate) As AssignedDate,
			Case when Convert (date, GETDATE()) > '2020-06-01'
		Then '2020-06-01'
		Else
		CONVERT(date, GetDate())
		End As DateTU
			,ss.StudentID,
			ss.OfficeID
		From Students.StudentMentors sms
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where ss.StudentStatusID
				In (1, 3, 4, 5) -- All active except "On Hold"
			--And ss.ContractSignedDate
			--	< '2014-06-30'
			--And (sms.UnassignedDate > '2013-08-01' OR SMS.UnassignedDate IS NULL)
			And (SMS.UnassignedDate IS NULL)
			AND SMS.MentorAssignmentTypeID = 1
			--AND SMS.IsPrimary = 1
						And SMS.IsDeleted = 0
		Group By ss.StudentID, ss.OfficeID
		--Order By ss.StudentID --for testing
	),

	-- CTE for mentor names
	--MentorNamesCte (StudentID, Mentors) As
	--(
	--   Select Main.StudentID,
 --      Left(Main.Mentors,Len(Main.Mentors)-1) As "Mentors"
	--   From(Select distinct ST2.StudentID,
 --          (Select ST1.FirstName + ' ' + ST1.LastName + ', ' AS [text()]
 --           From Mentors.Mentors ST1
	--			Left Outer Join Students.StudentMentors SMS ON ST1.MentorID = SMS.MentorID
 --           Where SMS.StudentID = ST2.StudentID
	--			--AND (SMS.UnassignedDate > '2013-08-01' OR SMS.UnassignedDate IS NULL)
	--			AND SMS.AssignedDate <= CONVERT (date, GETDATE())
	--			AND (SMS.UnassignedDate IS NULL)
	--			AND (SMS.MentorAssignmentTypeID = 1)
 --           For XML PATH ('')) [Mentors]
 --    From Students.Students ST2) [Main]
	-- --ORDER BY Main.StudentID
	--),

	Final (StudentId, TotalMonths, Average, Officeid, OfficeName) as


	(Select	ss.StudentID

			,tmcte.TotalMonths
			,case when convert(date, getdate()) < '2019-10-16' then null
					else floor(tmscte.TotalMentorSessions/tmcte.TotalMonths)
					end as 'AvgSession/Month'

			,ss.OfficeID
			,o.OfficeName
	from students.Students ss
	--left join Dates d on d.StudentID = ss.StudentID
	left join TotalMonths tmcte on ss.StudentID = tmcte.StudentID
	left join totalMentorSessionsCte tmscte on tmscte.StudentID = ss.StudentID
	left join offices.Offices o on o.OfficeID = ss.OfficeID
	--left join MentorNamesCte mncte on ss.StudentID = mncte.StudentID
	--INNER JOIN Schools.Schools SCH ON SCH.SchoolID = ss.SchoolID
	--left join FirstMentorSessionDate fmsdcte on ss.StudentID = fmsdcte.StudentID
	--left join LastMentorSessionDate lmsdcte on ss.StudentID = lmsdcte.StudentID
	--left join reports.BSC_Dates bd on bd.StudentID = ss.StudentID
--	left join lookups.Counties c on c.CountyID = ss.CountyID
	Where ss.StudentStatusID
				In (1, 3, 4, 5)

			and ss.IsDeleted = 0
			group by OfficeName, ss.StudentID,tmcte.TotalMonths, TotalMentorSessions, ss.OfficeID
)
	,

	TMonths (OfficeId, TotalMts, OfficeName) as

(Select Officeid, count(TotalMonths)as Totalmts, OfficeName
from Final
where TotalMonths is not null
group by Officeid, OfficeName
)

,taverage (OfficeId, Totalav, OfficeName) as

(Select Officeid, count(Average)as Totalaverage, OfficeName
from Final
where Average >=2
group by Officeid, OfficeName)

, timelymatchesCTE (officeid, officename, true_total, false_total, null_total, all_total) as
	(SELECT
		bsc_tmm.officeid,
		offic.officename,
		sum(case when timelymatch = 'True' then 1 else 0 end) AS trueCount,
		sum(case when timelymatch = 'False' then 1 else 0 end) AS falseCount,
		sum(case when timelymatch IS NULL then 1 else 0 end) AS nullCount,
		count(*) AS total
	FROM Reports.BSC__nTimelyMentorMatch bsc_tmm
	LEFT JOIN offices.offices offic ON bsc_tmm.officeid=offic.officeid
	GROUP BY bsc_tmm.officeid, offic.officename
	)

Select
		8 As DataPointNumber,
		'No. of Students averaging 2 sessions/month' as 'Metric', -- DataPointDescription
		--tss.CountyID,
		Tmon.OfficeName,
		IsNull(SUM(tav.Totalav), 0)  As KPI, --ValueMatch
		IsNull(SUM(Tmon.TotalMts), 0)  As Total, -- Total
		CONVERT(INT,ROUND((IsNull(SUM(tav.totalav), 0) / CAST(Tmon.TotalMts As Decimal)) * 100,0)) As Result, -- percent
		CASE
			when CONVERT(INT,ROUND((IsNull(SUM(tav.totalav), 0) / CAST(Tmon.TotalMts As Decimal)) * 100,0)) between 85 and 100 then 20
			when CONVERT(INT,ROUND((IsNull(SUM(tav.totalav), 0) / CAST(Tmon.TotalMts As Decimal)) * 100,0)) between 70 and 84 then 9
			when CONVERT(INT,ROUND((IsNull(SUM(tav.totalav), 0) / CAST(Tmon.TotalMts As Decimal)) * 100,0)) < 70 then 0
			else ''
			end as Score,
		'' as Comments,
		Tmon.OfficeID
	From TMonths Tmon
		left join taverage tav  on Tmon.OfficeID = tav.OfficeID
	group by Tmon.OfficeName, tmon.OfficeID, Tmon.TotalMts

				UNION


--Midyear Datapoint 9

SELECT
		9 AS DataPointNumber,
		'New student timely matches' AS 'Metric',
		office.officeName,
		true_total	AS KPI,
		all_total-null_total	AS TotalNew,
		CONVERT(INT,ROUND(true_total * 100/CAST(NULLIF(all_total-null_total,0) AS DECIMAL),0)) AS Result,
		CASE
			WHEN CONVERT(INT,ROUND(true_total * 100/CAST(NULLIF(all_total-null_total,0) AS DECIMAL),0)) BETWEEN 98 AND 100 THEN 5
			WHEN CONVERT(INT,ROUND(true_total * 100/CAST(NULLIF(all_total-null_total,0) AS DECIMAL),0)) BETWEEN 95 AND 97 THEN 3
			WHEN CONVERT(INT,ROUND(true_total * 100/CAST(NULLIF(all_total-null_total,0) AS DECIMAL),0)) < 95 THEN 0
			ELSE ''
			END AS Score,
		'' AS Comments,
		office.officeid
	From offices.offices office
	LEFT JOIN timelymatchesCTE ON office.officeid=timelymatchesCTE.officeid

--Full year Datapoint 9

--SELECT
--		9 AS DataPointNumber,
--		'New student timely matches' AS 'Metric',
--		office.officeName,
--		true_total  AS KPI,
--		all_total	AS TotalNew,
--		true_total * 100/all_total AS Result,
--		CASE
--			WHEN true_total * 100/all_total BETWEEN 98 AND 100 THEN 5
--			WHEN true_total * 100/all_total BETWEEN 95 AND 97 THEN 3
--			WHEN true_total * 100/all_total < 95 THEN 0
--			ELSE ''
--			END AS Score,
--		'' AS Comments,
--		office.officeid
--	From offices.offices office
--  LEFT JOIN timelymatchesCTE ON office.officeid=timelymatchesCTE.officeid