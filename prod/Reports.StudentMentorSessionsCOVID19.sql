SELECT S.firstname                       AS menteeFirstName,
       s.LastName                        AS menteeLastName,
       m.FirstName                       AS mentorFirstName,
       m.LastName                        AS mentorLastName,
       st.LastName + ', ' + st.FirstName as AdvocateName,
       --sm.MentorAssignmentTypeID,
       s.StudentStatusID,
       s.StudentReferenceID,
       s.OfficeID,
       s.CurrentGradeLevelID,
       s.ContractSignedDate,
       ss.StudentStatusName,
       sch.SchoolName,
       c.CountyName,
       sms.SessionDate,
       mentorsessiontypename             AS SessionType,
       sms.SessionNote,
       sms.SessionDuration,
       s.Affiliation,
       s.i3ControlGroup,
       i3StudyGroupMember,
       MentorStatusName,
       --sm.assigneddate,
       o.officename
       --, os.Donor
       --( Select Top (1) Donor
       --  From Offices.Scholarships
       --  Where Offices.Scholarships.StudentID = s.StudentID and Offices.Scholarships.isdeleted = 0) As DonorName
        ,
       CASE
           WHEN sessionsourceid = 0 THEN 'STAR'
           WHEN sessionsourceid = 1 THEN 'MobileApp'
           WHEN sessionsourceid = 2 THEN 'MentorWebPortal'
           ELSE ''
           END                           AS SessionSource
FROM Students.MentoringSessions AS sms
         INNER JOIN Students.Students AS s ON s.StudentID = sms.StudentID
         INNER JOIN Lookups.StudentStatuses AS ss ON s.StudentStatusID = ss.StudentStatusID
         INNER JOIN Schools.Schools AS sch ON s.SchoolID = sch.SchoolID
         INNER JOIN offices.offices o ON o.officeid = s.officeid
         INNER JOIN Lookups.Counties AS c ON s.CountyID = c.CountyID
         LEFT OUTER JOIN offices.Staff ST on s.AdvocateID = st.StaffID
    --Left outer Join-- Offices.Scholarships os ON s.StudentID = os.StudentID
--LEFT OUTER JOIN Students.StudentMentors AS sm ON s.StudentID = sm.StudentID --AND (sm.UnassignedDate < '2017-08-01' OR sm.UnassignedDate IS NULL) --AND sm.MentorAssignmentTypeID = 1
         INNER JOIN Mentors.Mentors AS m ON sms.MentorID = m.MentorID
         LEFT JOIN lookups.mentorsessiontypes ON sms.sessiontypeid = mentorsessiontypes.mentorsessiontypeid
         INNER JOIN Lookups.MentorStatuses ms ON m.MentorStatusID = ms.MentorStatusID
WHERE 1 = 1
  AND s.StudentStatusID IN (1, 3, 4, 5, 19, 20, 21, 22, 23, 24)
  AND s.IsDeleted = 0
  AND m.IsDeleted = 0
  --AND sm.IsDeleted = 0
  AND sms.IsDeleted = 0
