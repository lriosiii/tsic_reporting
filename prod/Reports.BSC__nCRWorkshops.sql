SELECT    o.OfficeName
		

			,(select top (1) count(oe.EventName)
				from Offices.events oe
				--left join students.Events e on oe.OfficeEventID = e.OfficeEventID
				where oe.EventDate Between dbo.July1() and dbo.Jun30() and oe.EventCategoryID = 1 and oe.IsDeleted = 0
				and oe.OfficeID = o.OfficeID
				and oe.EventTypeID = 1 --only looking at student events CLF - added 4/15/2019
				and oe.OfficeEventID in
				(Select e.OfficeEventID
				from students.Events e 
				where e.Attended = 1)
				) as 'FAFSA/FinancialAidEvents'

				,(select top (1) count(oe.EventName)
				from Offices.events oe
				where oe.EventDate Between dbo.July1() and dbo.Jun30() and oe.EventCategoryID = 2 and oe.IsDeleted = 0
				and oe.OfficeID = o.OfficeID
				and oe.EventTypeID = 1 --only looking at student events CLF - added 4/15/2019
				and oe.OfficeEventID in
				(Select e.OfficeEventID
				from students.Events e 
				where e.Attended = 1)
				) as 'SeniorCollegePrepEvents'

				,(select top (1) count(oe.EventName)
				from Offices.events oe
				where oe.EventDate Between dbo.July1() and dbo.Jun30() and oe.EventCategoryID = 3 and oe.IsDeleted = 0
				and oe.OfficeID = o.OfficeID
				and oe.EventTypeID = 1 --only looking at student events CLF - added 4/15/2019
				and oe.OfficeEventID in
				(Select e.OfficeEventID
				from students.Events e 
				where e.Attended = 1)
				) as 'CollegeReadinessEvents'


				,(select top (1) count(oe.EventName)
				from Offices.events oe
				where oe.EventDate Between dbo.July1() and dbo.Jun30() and oe.EventCategoryID = 4 and oe.IsDeleted = 0
				and oe.OfficeID = o.OfficeID
				and oe.EventTypeID = 1 --only looking at student events CLF - added 4/15/2019
				and oe.OfficeEventID in
				(Select e.OfficeEventID
				from students.Events e 
				where e.Attended = 1)
				) as 'NewStudentOrientationEvents'

				,(select top (1) count(oe.EventName)
				from Offices.events oe
				where oe.EventDate Between dbo.July1() and dbo.Jun30() and oe.EventCategoryID in(1,2,3,4) and oe.IsDeleted = 0
				and oe.OfficeID = o.OfficeID
				and oe.EventTypeID = 1 --only looking at student events CLF - added 4/15/2019
				and oe.OfficeEventID in
				(Select e.OfficeEventID
				from students.Events e 
				where e.Attended = 1)
				) as 'TotalCollegeReadiessWorkshops'

				,o.OfficeID
			
FROM         Offices.Offices o 
--			, offices.events oe
--where		oe.OfficeID = o.OfficeID
--			and oe.EventTypeID = 1
