SELECT     s.LastName + ', ' + s.FirstName AS StudentName, s.MiddleName, s.SchoolID, s.OfficeID, s.Gender, s.SSN, s.BirthDate, s.HomePhoneNumber, s.ContractSignedDate, 
                      s.EthnicityID, s.RaceID, s.EntryGPA AS EntryGPAOnFile, s.AddressID, s.EmailAddress, s.EntryGradeLevelID, sa.CurrentGradeLevelID, s.StudentTypeID, 
                      Lookups.StudentStatuses.StudentStatusName, sa.PriorityType, sa.ApplicationNotes, sa.FinanciallyQualified, sa.InterviewsConducted, sa.IsUSCitizen, 
                      sa.AdultsInHousehold, sa.EmailAddress AS ApplicantEmailAddr, sa.ApplicationStartDate, s.ExpectedGraduationDate, s.StudentStatusID, s.StudentReferenceID, 
                      sa.GPA AS EntryGPAFromApplicationInSTAR,
                          (SELECT     TOP (1) ContactID
                            FROM          Students.Contacts AS sc
                            WHERE      (sc.StudentID = s.StudentID)) AS PrimaryGuardian,
							(SELECT     TOP (1) sm.mentorid
                            FROM          Students.studentmentors AS sm
                            WHERE      (sm.StudentID = s.StudentID)) AS InitialMentorMatch,
							s.ContractID, s.WorkPhoneNumber, s.MobilePhoneNumber, cty.CountyName
FROM         Students.Students AS s 
LEFT OUTER JOIN Lookups.StudentStatuses ON s.StudentStatusID = Lookups.StudentStatuses.StudentStatusID 
LEFT OUTER JOIN Students.Applications AS sa ON s.StudentID = sa.StudentID 
INNER JOIN  Lookups.Counties AS cty ON cty.CountyID = s.CountyID
WHERE				  
					  --(s.StudentStatusID IN (1, 3, 4, 5) AND (s.IsDeleted = 0)) AND (s.SSN IS NULL) OR
       --               (s.StudentStatusID IN (1, 3, 4, 5) AND (s.IsDeleted = 0)) AND (s.BirthDate IS NULL) OR
       --               (s.StudentStatusID IN (1, 3, 4, 5) AND (s.IsDeleted = 0)) AND (s.HomePhoneNumber IS NULL) AND (s.WorkPhoneNumber IS NULL) AND (s.MobilePhoneNumber IS NULL) OR
					  --(s.StudentStatusID IN (1, 3, 4, 5) AND (s.IsDeleted = 0)) AND (sa.EmailAddress IS NULL) AND (s.EmailAddress IS NULL) OR
       --               (s.StudentStatusID IN (1, 3, 4, 5) AND (s.IsDeleted = 0)) AND (s.ContractSignedDate IS NULL) OR
       --               (s.StudentStatusID IN (1, 3, 4, 5) AND (s.IsDeleted = 0)) AND (s.RaceID IS NULL) OR
       --               (s.StudentStatusID IN (1, 3, 4, 5) AND (s.IsDeleted = 0)) AND (s.AddressID IS NULL) OR
       --               (s.StudentStatusID IN (1, 3, 4, 5) AND (s.IsDeleted = 0)) AND (s.EntryGradeLevelID IS NULL) OR --AND (sa.CurrentGradeLevelID IS NULL) OR
       --               (s.StudentStatusID IN (1, 3, 4, 5) AND (s.IsDeleted = 0)) AND (s.Gender IS NULL) OR
       --               (s.StudentStatusID IN (1, 3, 4, 5) AND (s.IsDeleted = 0)) AND (NOT EXISTS
       --                   (SELECT     TOP (1) ContactID
       --                     FROM          Students.Contacts AS sc
       --                     WHERE      (sc.StudentID = s.StudentID)))
	   s.StudentStatusID 
					In (1, 3, 4, 5) -- All active except "On Hold" 

				And s.ContractSignedDate  
					< '2020-06-30'			-- Updated Date 04/13/2015   JL    11/17   JL   // Update date 8/15/2019 - CLF
				AND s.IsDeleted = 0
				

				And (
						   s.SSN Is Null
						OR s.BirthDate Is Null
						OR NOT EXISTS (SELECT TOP (1) sm.mentorid AS InitialMentorMatch
										FROM    Students.studentmentors AS sm
										WHERE   (sm.StudentID = s.StudentID))
						OR (
							s.HomePhoneNumber Is Null 
							AND s.WorkPhoneNumber Is Null 
							AND s.MobilePhoneNumber Is Null
							) 
						OR s.ContractSignedDate Is Null
						OR s.RaceID Is Null
						OR s.AddressID Is Null
					OR (
						s.EntryGradeLevelID Is Null
						--And sa.CurrentGradeLevelID Is Null  --No longer going by application table  JL 11/27/2013
						Or s.Gender Is Null
						Or Not Exists (
							Select Top 1 ContactID
							From Students.Contacts sc
							Where s.StudentID = StudentID)
						Or Not Exists (
							Select Top 1 EmailAddress
							From Students.Contacts sc
							Where s.StudentID = StudentID)
						Or s.EmailAddress	IS NULL				
						)
				)
