with Coll_CTE (AttendedCollege, StudentID, EntryDate, DegreeAttained)
AS
    (
    	Select 
			  Case 
				When (ci.ActualGraduationDate is not null) 
				or (CollegeDegreeTypeID > 0)
				or (s.StudentStatusID IN (11,12))
				or (ci.EntryDate is not null) then 1
				Else  0
				End as AttendedCollege
				,ci.StudentID
				,ci.EntryDate
				,Case
					when (ci.ActualGraduationDate is not null)
					or (s.StudentStatusID IN (11,12))
					or (sh.StudentStatusID IN (11,12))
					or (CollegeDegreeTypeID > 0) then 1
					else 0
					End as DegreeAttained

		From [Students].[CollegeInformation] ci
		 join Students.Students s on ci.StudentID = s.StudentID
		left join Students.StatusHistory sh on ci.StudentID = sh.StudentID
		where	 ci.IsDeleted = 0 and s.IsDeleted = 0
		
	)	
SELECT  o.OfficeName
	  ,c.CountyName
      ,s.LastName
	  ,s.firstName
	  ,s.LastName + ', ' + s.FirstName AS FullName
	  ,s.StudentReferenceID
	  ,ss.StudentStatusName
	  ,s.HighSchoolDiplomaDate
	  ,s.GraduationYear
	  ,s.OfficeID
	  ,s.Affiliation
	   ,(
			SELECT TOP (1) dt.DegreeTypeName
			From lookups.DegreeTypes dt
			inner join students.CollegeInformation cinf on dt.DegreeTypeID = cinf.CollegeDegreeTypeID
			Where cinf.StudentID = s.StudentID and cinf.CollegeDegreeTypeID is not null
			--And gpa.IsCollege = 1
			And cinf.IsDeleted = 0
			ORDER BY cinf.ActualGraduationDate DESC 
	  ) As DegreeTypeName
	
	  ,(
			SELECT TOP (1) lc.CollegeName
			From lookups.Colleges lc
			inner join students.CollegeInformation cinf on lc.CollegeID = cinf.CollegeID
			Where cinf.StudentID = s.StudentID
			--And gpa.IsCollege = 1
			And cinf.IsDeleted = 0
			ORDER BY cinf.EntryDate DESC 
	  ) As CollegeName
	
	,(
			SELECT TOP (1) DATEPART(yyyy, cinf.LastEnrolledDate)
			From students.CollegeInformation cinf
			Where cinf.StudentID = s.StudentID
			--And gpa.IsCollege = 1
			And cinf.IsDeleted = 0
			ORDER BY cinf.EntryDate DESC 
	  ) As ColLastYearAttnd
	
	 ,(
			SELECT TOP (1) CASE DATEPART(qq, cinf.LastEnrolledDate) 
			WHEN 1 THEN 'Spring'
			WHEN 2 THEN 'Summer'
			WHEN 3 THEN 'Fall'
			WHEN 4 THEN 'Winter'
			ELSE 'N/A'
		END
		 ColLastTermAttnd
			From students.CollegeInformation cinf
			Where cinf.StudentID = s.StudentID
			--And gpa.IsCollege = 1
			And cinf.IsDeleted = 0
			ORDER BY cinf.EntryDate DESC 
	  ) As ColLastTermAttnd
		,(
			SELECT TOP (1) cinf.EntryDate
			From students.CollegeInformation cinf
			Where cinf.StudentID = s.StudentID
			--And gpa.IsCollege = 1
			And cinf.IsDeleted = 0
			ORDER BY cinf.EntryDate DESC 
	  ) As EntryDate

	  ,(
			SELECT TOP (1) datepart(yyyy,cinf.EntryDate)
			From students.CollegeInformation cinf
			Where cinf.StudentID = s.StudentID
			--and cinf.EntryDate is not null
			--And gpa.IsCollege = 1
			And cinf.IsDeleted = 0
			ORDER BY cinf.EntryDate ASC 
	  ) As EarliestEnrollmentYear

	,(
			SELECT TOP (1) cinf.ActualGraduationDate
			From students.CollegeInformation cinf
			Where cinf.StudentID = s.StudentID and cinf.ActualGraduationDate is not null
			--And gpa.IsCollege = 1
			And cinf.IsDeleted = 0
			ORDER BY cinf.EntryDate DESC 
	  ) As ActualGraduationDate
	  

	 ,(
			SELECT TOP (1) case when cinf.IsEnrolled = 1 then 'Yes'
								else 'No'
								end as IsEnrolled
			From students.CollegeInformation cinf
			Where cinf.StudentID = s.StudentID
			--And gpa.IsCollege = 1
			And cinf.IsDeleted = 0
			ORDER BY cinf.EntryDate DESC 
	  ) As IsEnrolled

	  ,(
			SELECT TOP (1) Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(cinf.Notes,',',''),'-',''),'+',''),'~',''),'`',''),'%',''),'!',''),'^',''),
	  CHAR(13),' '),CHAR(10),' ')
	  As Notes
			From students.CollegeInformation cinf
			Where cinf.StudentID = s.StudentID
			--And gpa.IsCollege = 1
			And cinf.IsDeleted = 0
			ORDER BY cinf.EntryDate DESC 
	  ) As Notes
	  ,(
			SELECT TOP (1) oss.MatriculationYear
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC 
	  ) As MatriculationYear
	  --,os.MatriculationYear
	   ,(
			SELECT TOP (1) oss.Donor
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC 
	  ) As Donor
	 -- ,os.Donor
	   ,(
			SELECT TOP (1) oss.ScholarshipOwner
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC 
	  ) As ScholarshipOwner
	  --,os.ScholarshipOwner
	  ,s.EmailAddress
	  ,s.MobilePhoneNumber
	  ,s.WfiEligible
	  ,s.BirthDate
	  ,ca.Address1
	  ,ca.Address2
	  ,ca.City
	  ,CA.StateID
	  ,CA.ZipCode
	  ,sch.SchoolName
	  ,(									
			SELECT TOP (1) gpa.SemesterUnweighted 
			From Students.GPA gpa
			Where gpa.StudentID = s.StudentID
			And gpa.IsCollege = 1
			And gpa.IsDeleted = 0
			ORDER BY SemesterEndDate DESC 
	  ) As LastCollegeSemesterUnweightedGPA
	  ,(
			SELECT TOP (1) gpa.CumulativeUnweighted 
			From Students.GPA gpa
			Where gpa.StudentID = s.StudentID
			And gpa.IsCollege = 1
			And gpa.IsDeleted = 0
			ORDER BY SemesterEndDate DESC 
	  ) As LastCollegeCumulativeUnweightedGPA
	  ,(
			SELECT TOP (1) gpa.SemesterEndDate 
			From Students.GPA gpa
			Where gpa.StudentID = s.StudentID
			And gpa.IsCollege = 1
			And gpa.IsDeleted = 0
			ORDER BY SemesterEndDate DESC 
	  ) As LastCollegeSemesterEndDateGPA

	,(
		SELECT TOP (1) o.LastTerm
		From Offices.Scholarships O
		Where o.StudentID = s.StudentID
		And o.IsDeleted = 0
		--And o. = 0
		ORDER BY o.HoursAvail DESC 
	) As ScholLastTerm

	,(
		SELECT TOP (1) o.LastSchoolAttended
		From Offices.Scholarships O
		Where o.StudentID = s.StudentID
		And o.IsDeleted = 0
		--And o. = 0
		ORDER BY o.HoursAvail DESC 
	) As ScholLastSchool

	,(
		SELECT TOP (1) o.LastYearAttnd
		From Offices.Scholarships O
		Where o.StudentID = s.StudentID
		And o.IsDeleted = 0
		--And o. = 0
		ORDER BY o.HoursAvail DESC 
	) As ScholLastYear

	  ,(select top (1)
	  	case
		when Sum(AttendedCollege) Over(Partition by Coll_CTE.studentid) > 0 then 'Yes'
		Else 'No'
		End  as AttendedColleg
		FROM  Coll_CTE
		where Coll_CTE.StudentID = s.StudentID
	group by StudentID,AttendedCollege) as AttendedCollege


	,(select top (1)
	  		case
			when Sum(DegreeAttained) Over(Partition by Coll_CTE.studentid) > 0 then 'Yes'
			Else 'No'
			End  as DegreeAttained
			FROM  Coll_CTE
			where Coll_CTE.StudentID = s.StudentID
		group by StudentID,DegreeAttained) as DegreeAttained
	,os.contractnumber

  FROM [Students].[Students] s
  LEFT OUTER JOIN Common.Addresses ca On s.AddressID = ca.addressID
  --LEFT OUTER JOIN Students.CollegeInformation ci ON s.StudentID = ci.StudentID
 -- LEFT OUTER JOIN Lookups.Colleges col ON ci.CollegeID = col.CollegeID
  --LEFT OUTER JOIN Lookups.CollegeLevels cl ON ci.CollegeLevelID = cl.CollegeLevelID
  --LEFT OUTER JOIN Lookups.CollegeMajors cm ON ci.CollegeMajorID = cm.CollegeMajorID
  --LEFT OUTER JOIN Lookups.DegreeTypes dt ON ci.CollegeDegreeTypeID = dt.DegreeTypeID
  LEFT OUTER JOIN Offices.Offices o On s.OfficeID = o.OfficeID
  LEFT OUTER JOIN Lookups.Counties c on s.CountyID = c.CountyID
  LEFT OUTER JOIN Lookups.StudentStatuses ss ON s.StudentStatusID = ss.StudentStatusID
  LEFT OUTER JOIN Offices.Scholarships os ON s.StudentID = os.StudentID
  LEFT OUTER JOIN Schools.Schools sch On s.SchoolID = sch.SchoolID
 
  Where s.StudentStatusID IN (11,12,13,14,15,25,28)
  AND s.IsDeleted = 0
  --AND ci.IsDeleted = 0
  --And s.OfficeID = 13
  --And CollegeName = 'university of north florida'
  --order by s.LastName

  --Order By  ContractNumber  --OfficeName, LastName, FirstName
  --order by CollegeName
