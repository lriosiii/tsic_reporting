with Coll_CTE (AttendedCollege, StudentID, EntryDate, DegreeAttained)
AS
    (
    	Select 
			  Case 
				When (ci.ActualGraduationDate is not null) 
				or (CollegeDegreeTypeID > 0)
				or (s.StudentStatusID IN (12, 13, 28))
			  	or (sh.StudentStatusID IN (12, 13, 28))
				or (ci.EntryDate is not null) then 1
				Else  0
				End as AttendedCollege
				,ci.StudentID
				,ci.EntryDate
				,Case
					when (ci.ActualGraduationDate is not null)
					or (s.StudentStatusID IN (12, 28))
                    			or (sh.StudentStatusID IN (12, 28))
					or (CollegeDegreeTypeID > 0) then 1
					else 0
					End as DegreeAttained

		From [Students].[CollegeInformation] ci
		 join Students.Students s on ci.StudentID = s.StudentID
		left  Join Students.StatusHistory sh on ci.StudentID = sh.StudentID
		where	 ci.IsDeleted = 0 and s.IsDeleted = 0
		
	)	
SELECT  o.OfficeName
	  ,c.CountyName
      ,s.LastName
	  ,s.firstName
	  ,s.MiddleName
	  ,s.LastName + ', ' + s.FirstName As FullName
	  ,s.Gender
	  ,ss.StudentStatusName
	  ,a.Address1
	  ,a.Address2
	  ,a.City
	  ,a.StateID
	  ,a.ZipCode
	  ,f.FamilySituationName
	  ,s.HighSchoolDiplomaDate
	  ,s.GraduationYear
	  ,CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) AS SSN
	  ,CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)) AS BirthDate
	  ,s.HomePhoneNumber
	  ,s.WorkPhoneNumber
	  ,s.MobilePhoneNumber
	  ,s.EmailAddress
	  ,s.IsHispanic
	  ,s.OfficeID
	  ,r.RaceName
	  ,s.Affiliation
	  ,Case when s.WfiEligible = 1 then 'Yes'
	  when s.WfiEligible = 0 then 'No'
	  else ''
	  end as 'WFI Student'
	  ,(
			Select TOP(1) col.CollegeName 
			From Students.CollegeInformation colinfo
			LEFT OUTER JOIN Lookups.Colleges col ON colinfo.CollegeID = col.CollegeID
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.EntryDate Desc
			) As SelectedCollege,
			
			(
			Select TOP(1) col.CollegeName 
			From Students.CollegeInformation colinfo
			LEFT OUTER JOIN Lookups.Colleges col ON colinfo.CollegeID = col.CollegeID
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.EntryDate Asc
			) As FirstCollegeAttended,

			(
			Select TOP(1) Colinfo.EntryDate
			From Students.CollegeInformation colinfo
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.EntryDate asc
			) As FirstCollegeEntryDate, 

			(
			Select TOP(1) Colinfo.LastEnrolledDate
			From Students.CollegeInformation colinfo
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.LastEnrolledDate asc
			) As FirstCollegeLastEnrolledDate,
			(
			Select TOP(1) colinfo.ActualGraduationDate
			From Students.CollegeInformation colinfo
			WHERE colinfo.StudentID = s.StudentID and colinfo.ActualGraduationDate is not null
			ORDER BY colinfo.EntryDate Desc
			) As CollegeGraduationDate,
			(
			Select TOP(1) Colinfo.IsEnrolled
			From Students.CollegeInformation colinfo
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.EntryDate Desc
			) As IsEnrolled, 
			(
			Select TOP(1) Colinfo.EntryDate
			From Students.CollegeInformation colinfo
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.EntryDate Desc
			) As EntryDate, 
			(
			Select TOP(1) Colinfo.RemedialCollegeRequired
			From Students.CollegeInformation colinfo
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.EntryDate Desc
			) As RemedialCollegeRequired,
			(
			Select TOP(1) Colinfo.LastUpdatedDateTime
			From Students.CollegeInformation colinfo
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.EntryDate Desc
			) As LastUpdatedDate,
			(
			Select TOP(1) cl.CollegeLevelName
			From Students.CollegeInformation colinfo
			LEFT OUTER JOIN Lookups.CollegeLevels cl ON colinfo.CollegeLevelID = cl.CollegeLevelID
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.EntryDate Desc
			) As CollegeLevel,
			(
			Select TOP(1) cl.DegreeTypeName
			From Students.CollegeInformation colinfo
			LEFT OUTER JOIN Lookups.DegreeTypes cl ON colinfo.CollegeDegreeTypeID = cl.DegreeTypeID
			WHERE (colinfo.StudentID = s.StudentID)
			ORDER BY colinfo.ActualGraduationDate Desc
			) As DegreeType,
			(
			Select TOP(1) colinfo.TranscriptReceivedDate
			From Students.CollegeInformation colinfo
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.TranscriptReceivedDate Desc
			) As LastTranscriptReceivedDate,
		 (
		    Select TOP(1) SchoolName
			From Students.Students st
			Left Outer Join Schools.Schools sch On st.SchoolID = sch.SchoolID
			Where Sch.IsDeleted = 0
			And St.StudentID = s.StudentID	
			And st.IsDeleted = 0
		 ) As HighSchoolName 
		 ,(
			Select Top(1) Mentors.LastName + ', ' + Mentors.FirstName As MentorName
			From Mentors.Mentors
			Left Outer Join Students.StudentMentors On Mentors.MentorID = StudentMentors.MentorID And StudentMentors.StudentID = s.StudentID
			Where StudentMentors.IsPrimary = 1
			AND StudentMentors.UnassignedDate IS NULL
			AND StudentMentors.MentorAssignmentTypeID = 1
			And StudentMentors.STudentID = s.StudentID
			Order By StudentMentors.AssignedDate Desc 
		  ) As MentorName
		  ,(
			Select Top(1) ContractNumber
			From Offices.Scholarships
			Where StudentID = s.StudentID
			) As ScholarshipContractNumber
		,(
			SELECT TOP (1) oss.Donor
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC 
		  ) As Donor
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
	  ) As LastCollegeSemesterEndDateGPA,
	  (
			Select TOP(1) Colinfo.LastEnrolledDate
			From Students.CollegeInformation colinfo
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.LastEnrolledDate Desc
	 ) As LastEnrolledDate,
	  (
			Select TOP(1) datepart(yyyy,Colinfo.LastEnrolledDate)
			From Students.CollegeInformation colinfo
			WHERE colinfo.StudentID = s.StudentID
			ORDER BY colinfo.LastEnrolledDate Desc
	 ) As LastEnrolledYear 

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
,con.EmailAddress as PrimaryGuardianEmail
,con.IsPrimaryGuardian



			 	 
  FROM [Students].[Students] s
  LEFT OUTER JOIN Common.Addresses a ON s.AddressID = a.AddressID
  LEFT OUTER JOIN Offices.Offices o On s.OfficeID = o.OfficeID
  LEFT OUTER JOIN Lookups.Counties c on s.CountyID = c.CountyID
  left outer join lookups.FamilySituations f on s.FamilySituationID = f.FamilySituationID
 -- left outer join students.CollegeInformation sci on sci.StudentID = s.StudentID
  LEFT OUTER JOIN Lookups.StudentStatuses ss ON s.StudentStatusID = ss.StudentStatusID
  LEFT OUTER JOIN Lookups.Races r ON s.RaceID = r.RaceID
 LEFT JOIN students.contacts con ON s.StudentID=con.StudentID and con.IsPrimaryGuardian = 1 and con.isdeleted = 0


  Where s.StudentStatusID IN (11,12,13,14,15,25,28)
  AND s.IsDeleted = 0
   

  --Order By  OfficeName, LastName, FirstName
