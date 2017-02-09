//
//  Me.swift
//  curriculumvitae
//
//  Created by Nejc on 9.2.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation

protocol NSDictionaryRepresentable {
    init(dictionary: Dictionary<String, Any>) throws
}

protocol DictionaryReport: NSDictionaryRepresentable, CustomStringConvertible {
}

func unwrap<T>(from: Dictionary<String, Any>, name: String, error: Error) throws -> T {
    guard let rval = from[name] as? T else {
        throw error
    }
    return rval
}

//class, because I prefer to be referenced instead of copied around
class Applicant: DictionaryReport {
    enum ApplicantError: Error {
        case noName
        case noSurname
        case noAboutMe
        case noEducation
        case noPreviousWork
    }
    
    let name: String
    let surname: String
    let aboutMe: String
    let education: [DictionaryReport]
    let previousWork: [DictionaryReport]
    
    required init(dictionary: Dictionary<String, Any>) throws {
        name = try unwrap(from: dictionary, name: "name", error: ApplicantError.noName)
        surname = try unwrap(from: dictionary, name: "surname", error: ApplicantError.noSurname)
        aboutMe = try unwrap(from: dictionary, name: "aboutme", error: ApplicantError.noAboutMe)
        
        education = try (unwrap(from: dictionary, name: "education", error: ApplicantError.noEducation) as [[String: Any]]).map {
            try Education(dictionary: $0)
        }
        previousWork = try (unwrap(from: dictionary, name: "work", error: ApplicantError.noPreviousWork) as [[String: Any]]).map {
            try Work(dictionary: $0)
        }
    }
    
    var description: String {
        var rval = "\(name) \(surname)\n\n"
        rval += "\(aboutMe)\n\n"
        rval += "Education:\n"
        education.forEach {
            rval += "\($0)\n\n"
        }
        rval += "Previous work:\n"
        previousWork.forEach {
            rval += "\($0)\n\n"
        }
        
        return rval
    }
}

enum Graduated: CustomStringConvertible {
    case yes
    case no
    
    init(bool: Bool) {
        if bool {
            self = .yes
        } else {
            self = .no
        }
    }
    
    var description: String {
        switch self {
        case .no:
            return "no"
        default:
            return "yes"
        }
    }
}

struct Education: DictionaryReport {
    enum EducationError: Error {
        case noFacility
        case noProgram
        case noGraduated
        case noStartYear
        case noEndYear
    }
    
    let facility: String
    let program: String
    let graduated: Graduated
    let startYear: Int
    let endYear: Int
    
    init(dictionary: Dictionary<String, Any>) throws {
        facility = try unwrap(from: dictionary, name: "facility", error: EducationError.noFacility)
        program = try unwrap(from: dictionary, name: "program", error: EducationError.noProgram)
        graduated = Graduated(bool: try unwrap(from: dictionary, name: "graduated", error: EducationError.noGraduated))
        startYear = try unwrap(from: dictionary, name: "startYear", error: EducationError.noStartYear)
        endYear = try unwrap(from: dictionary, name: "endYear", error: EducationError.noEndYear)
    }
    
    var description: String {
        return "Studied \(program) at \(facility)\nfrom: \(startYear) to: \(endYear)\ngraduated: \(graduated)"
    }
}

typealias WorkExample = (String, String)

struct Work: DictionaryReport {
    enum WorkError: Error {
        case noCompanyTitle
        case noJobTitle
        case noJobDescription
        case noStartYear
        case noEndYear
        case noExamples
    }
    enum ExampleError: Error {
        case noTitle
        case noUrl
    }
    
    let company: String
    let jobTitle: String
    let jobDescription: String
    let startYear: Int
    let endYear: Int
    let examples: [WorkExample]?
    
    init(dictionary: Dictionary<String, Any>) throws {
        company = try unwrap(from: dictionary, name: "company", error: WorkError.noCompanyTitle)
        jobTitle = try unwrap(from: dictionary, name: "jobTitle", error: WorkError.noJobTitle)
        jobDescription = try unwrap(from: dictionary, name: "jobDescription", error: WorkError.noJobDescription)
        startYear = try unwrap(from: dictionary, name: "startYear", error: WorkError.noStartYear)
        endYear = try unwrap(from: dictionary, name: "endYear", error: WorkError.noEndYear)
        
        do {
            examples = try (unwrap(from: dictionary, name: "examples", error: WorkError.noExamples) as [[String: Any]]).map {
                let title: String = try unwrap(from: $0, name: "title", error: ExampleError.noTitle)
                let url: String = try unwrap(from: $0, name: "url", error: ExampleError.noUrl)
                return (title, url)
            }
        } catch WorkError.noExamples {
            examples = nil
        }
    }
    
    var description: String {
        var rval = "Worked as an \(jobTitle) at \(company) from \(startYear) to \(endYear)\n\(jobDescription)"
        if let examples = examples {
            rval += "\nHere are the examples of my work there:\n"
            examples.forEach {
                rval += "\($0.0): \($0.1)\n"
            }
        }
        return rval
    }
}
