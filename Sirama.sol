// 
// This project was a thesis project for PP2712801
// at Sebelas Maret University
//
// The copyright holder grant the freedom to copy, modify, 
// convey, adapt, and/or redistribute this work
// under the terms of the GNU General Public License v3.0.
//
// Palguno Wicaksono <hello@icaksh.my.id>
//
//

// SPDX-License-Identifier: GNU GPLv3

pragma solidity ^0.8.0;

struct StudentAcademicReputation {
    StudentInformation studentInfo;
    CourseReport[] courseReports;
    InternshipExperience[] internshipExperiences;
    Project[] projects;
}

struct StudentInformation {
    address studentAddress;
    string studentNumber;
    string studentName;
    string faculty;
    string program;
    uint32 yearAdmitted;
}

struct CourseReport {
    string studentNumber;
    uint8 semester;
    string courseCode;
    string courseName;
    uint8 credit;
    uint32 score;
    string grade;
    uint8 presence;
    uint8 absence;
}

struct InternshipExperience {
    string studentNumber;
    string company;
    string position;
    uint256 startDate;
    uint256 endDate;
    uint32 score;
}

struct Project {
    string studentNumber;
    string name;
    uint256 date;
}

contract SebelasMaretAcademicReputationTest {
    mapping(uint256 => string[]) private studentsByYearAdmitted;

    mapping(string => StudentInformation) private studentInfo;

    mapping(string => StudentAcademicReputation)
        private studentAcademicReputation;

    mapping(string => InternshipExperience[]) private internshipExperiences;

    mapping(string => CourseReport[]) private courseReports;

    mapping(string => Project[]) private projects;

    address public owner;

    event StudentRegistered(string studentNumber, address createdBy);
    event InternshipExperienceAdded(
        string studentNumber,
        string company,
        address createdBy
    );
    event CourseReportsAdded(
        string studentNumber,
        uint8 semester,
        string courseCode,
        address createdBy
    );
    event ProjectAdded(string studentNumber, string name, address createdBy);

    event StudentUpdated(string studentNumber, address updatedBy);

    event CourseReportUpdated(
        string studentNumber,
        uint8 semester,
        string courseCode,
        address updatedBy
    );

    event ProjectUpdated(
        string studentNumber,
        uint index,
        address updatedBy
    );
    event InternshipExperienceUpdated(
        string studentNumber,
        uint index,
        address updatedBy
    );

    event StudentLocked(
        string studentNumber,
        address updatedBy
    );

    modifier onlyAdmin() {
        // require(
        //     keccak256(bytes(studentInfo[_studentNumber].studentNumber)) ==
        //         keccak256(bytes(_studentNumber)),
        //     "___404___"
        // );
        // require(
        //     (msg.sender == studentInfo[_studentNumber].createdBy) ||
        //         msg.sender == owner,
        //     "___403___"
        // );
        // _;

        require(msg.sender == owner, "___403___ NOT OWNER");
        _;
    }

    // modifier notLocked(string memory _studentNumber){
    //     require(studentInfo[_studentNumber].isLocked == false, string.concat("___403___ STUDENT LOCKED: ",_studentNumber));
    //     _;
    // }

    constructor(){
        owner = msg.sender;
    }

    function addStudent(
        string memory _studentName,
        string memory _studentNumber,
        string memory _faculty,
        string memory _program,
        uint32 _yearAdmitted
    ) public onlyAdmin {
        require(
            keccak256(bytes(studentInfo[_studentNumber].studentNumber)) !=
                keccak256(bytes(_studentNumber)),
                string.concat("___409___ STUDENT EXIST: ",_studentNumber)
        );

        StudentInformation storage newStudent = studentInfo[_studentNumber];
        bytes32 hash = keccak256(
            abi.encodePacked(msg.sender, _studentName, block.timestamp)
        );
        newStudent.studentAddress = address(uint160(uint256(hash)));
        newStudent.studentName = _studentName;
        newStudent.studentNumber = _studentNumber;
        newStudent.faculty  = _faculty;
        newStudent.program = _program;
        newStudent.yearAdmitted = _yearAdmitted;
        studentsByYearAdmitted[_yearAdmitted].push(_studentNumber);
        emit StudentRegistered(_studentNumber, msg.sender);
    }

    function addInternshipExperience(
        string memory _studentNumber,
        string memory _company,
        string memory _position,
        uint32 _startDate,
        uint32 _endDate,
        uint32 _score
    ) public onlyAdmin {
        require(
            keccak256(bytes(studentInfo[_studentNumber].studentNumber)) ==
                keccak256(bytes(_studentNumber)),
            string.concat("___404___ STUDENT NOT FOUND: ", _studentNumber)
        );
        InternshipExperience memory newIntern = InternshipExperience({
            studentNumber: _studentNumber,
            company: _company,
            position: _position,
            startDate: _startDate,
            endDate: _endDate,
            score: _score
        });

        internshipExperiences[_studentNumber].push(newIntern);
        emit InternshipExperienceAdded(_studentNumber, _company, msg.sender);
    }

    function addCourseReports(
        string memory _studentNumber,
        uint8 _semester,
        string memory _courseCode,
        string memory _courseName,
        uint8 _credit,
        uint32 _score,
        string memory _grade,
        uint8 _presence,
        uint8 _absence
    ) public onlyAdmin {
        require(
            keccak256(bytes(studentInfo[_studentNumber].studentNumber)) ==
                keccak256(bytes(_studentNumber)),
            string.concat("___404___ STUDENT NOT FOUND: ", _studentNumber)
        );
        CourseReport memory newCourseReport = CourseReport({
            studentNumber: _studentNumber,
            semester: _semester,
            courseCode: _courseCode,
            courseName: _courseName,
            credit: _credit,
            score: _score,
            grade: _grade,
            presence: _presence,
            absence: _absence
        });

        courseReports[_studentNumber].push(newCourseReport);
        emit CourseReportsAdded(
            _studentNumber,
            _semester,
            _courseCode,
            msg.sender
        );
    }

    function addProject(
        string memory _studentNumber,
        string memory _name,
        uint256 _date
    ) public onlyAdmin {
        Project memory newProject = Project({
            studentNumber: _studentNumber,
            name: _name,
            date: _date
        });
        projects[_studentNumber].push(newProject);
        emit ProjectAdded(_studentNumber, _name, msg.sender);
    }

    function getStudentAcademicReputation(
        string memory _studentNumber
    ) public onlyAdmin view returns (StudentAcademicReputation memory) {
        require(
            keccak256(bytes(studentInfo[_studentNumber].studentNumber)) ==
                keccak256(bytes(_studentNumber)),
            string.concat("___404___ STUDENT NOT FOUND: ", _studentNumber)
        );
        StudentAcademicReputation memory student = StudentAcademicReputation({
            studentInfo: studentInfo[_studentNumber],
            internshipExperiences: internshipExperiences[_studentNumber],
            projects: projects[_studentNumber],
            courseReports: courseReports[_studentNumber]
        });
        return (student);
    }

    function getStudentAcademicReputationForPublic(
        string memory _studentNumber,
        address _studentAddress
    ) public view returns (StudentAcademicReputation memory) {
        require(
            keccak256(bytes(studentInfo[_studentNumber].studentNumber)) ==
                keccak256(bytes(_studentNumber)) &&
                studentInfo[_studentNumber].studentAddress == _studentAddress,
            string.concat("___404___ STUDENT NOT FOUND")
        );
        StudentAcademicReputation memory student = StudentAcademicReputation({
            studentInfo: studentInfo[_studentNumber],
            internshipExperiences: internshipExperiences[_studentNumber],
            projects: projects[_studentNumber],
            courseReports: courseReports[_studentNumber]
        });
        return (student);
    }

    function getAllStudentByYearAdmitted(
        uint32 _yearAdmitted,
        uint256 _page,
        uint256 _resultsPerPage
    ) public onlyAdmin view returns (StudentInformation[] memory, uint256 totalStudent) {
        uint256 _studentIndex = _resultsPerPage * _page - _resultsPerPage;

        if (
        studentsByYearAdmitted[_yearAdmitted].length == 0 || 
        _studentIndex > studentsByYearAdmitted[_yearAdmitted].length - 1
        ) {
        return (new StudentInformation[](0),0);
        }

        StudentInformation[] memory students = new StudentInformation[](
            _resultsPerPage
        );

        uint256 _returnCounter = 0;

        for (
            _studentIndex; 
            _studentIndex < _resultsPerPage * _page; 
            _studentIndex++
        ) {
            if (_studentIndex < studentsByYearAdmitted[_yearAdmitted].length) {
                students[_returnCounter] = studentInfo[studentsByYearAdmitted[_yearAdmitted][_studentIndex]];
            } else {
                students[_returnCounter] = studentInfo[""];
            }

            _returnCounter++;
        }
        return (students,studentsByYearAdmitted[_yearAdmitted].length);
    }

    function setStudent(
        string memory _studentNumber,
        string memory _newStudentName,
        string memory _program,
        string memory _faculty
    ) public onlyAdmin {
        require(
            keccak256(bytes(studentInfo[_studentNumber].studentNumber)) ==
                keccak256(bytes(_studentNumber)),
            string.concat("___404___ STUDENT NOT FOUND: ", _studentNumber)
        );
        
        StudentInformation storage student = studentInfo[_studentNumber];

        student.studentName = _newStudentName;
        student.program = _program;
        student.faculty = _faculty;

        emit StudentUpdated(_studentNumber, msg.sender);
    }

    function setCourseReport(
        string memory _studentNumber,
        uint8 _semester,
        string memory _oldCourseCode,
        string memory _newCourseCode,
        string memory _newCourseName,
        uint8 _newCredit,
        uint32 _newScore,
        string memory _newGrade,
        uint8 _newPresence,
        uint8 _newAbsence
    ) public onlyAdmin {
        CourseReport[] storage reports = courseReports[_studentNumber];
        for (uint i = 0; i < reports.length; i++) {
            if (
                reports[i].semester == _semester &&
                keccak256(bytes(reports[i].courseCode)) ==
                keccak256(bytes(_oldCourseCode))
            ) {
                reports[i].courseCode = _newCourseCode;
                reports[i].courseName = _newCourseName;
                reports[i].credit = _newCredit;
                reports[i].score = _newScore;
                reports[i].grade = _newGrade;
                reports[i].presence = _newPresence;
                reports[i].absence = _newAbsence;

                emit CourseReportUpdated(
                    _studentNumber,
                    _semester,
                    _oldCourseCode,
                    msg.sender
                );
                return;
            }
        }

        revert("___404___ COURSE REPORT NOT FOUND");
    }

    function setProject(
        string memory _studentNumber,
        uint _index,
        string memory _newName,
        uint256 _newDate
    ) public onlyAdmin {
        require(
            _index < projects[_studentNumber].length,
            string.concat("___404___ PROJECT NOT FOUND")
        );

        Project storage project = projects[_studentNumber][_index];
        project.name = _newName;
        project.date = _newDate;
        emit ProjectUpdated(_studentNumber, _index, msg.sender);
    }

    function setInternshipExperience(
        string memory _studentNumber,
        uint _index,
        string memory _newCompany,
        string memory _newPosition,
        uint256 _newStartDate,
        uint256 _newEndDate,
        uint32 _newScore
    ) public onlyAdmin{
        require(
            _index < internshipExperiences[_studentNumber].length,
            string.concat("___404___ INTERNSHIP EXPERIENCE NOT FOUND")
        );

        InternshipExperience storage internship = internshipExperiences[
            _studentNumber
        ][_index];
        internship.company = _newCompany;
        internship.position = _newPosition;
        internship.startDate = _newStartDate;
        internship.endDate = _newEndDate;
        internship.score = _newScore;

        emit InternshipExperienceUpdated(
            _studentNumber,
            _index,
            msg.sender
        );
    }
}
