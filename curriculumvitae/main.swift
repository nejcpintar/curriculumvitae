//
//  main.swift
//  curriculumvitae
//
//  Created by Nejc on 9.2.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation

enum CVError: Error {
    case fileNotFound
}

do {
    guard let fileUrl = Bundle.main.url(forResource: "nejc", withExtension: "plist") else {
        print("file not found")
        throw CVError.fileNotFound
    }
    
    let dictionary = NSDictionary(contentsOf: fileUrl) as! Dictionary<String, Any>
    let applicant = try Applicant(dictionary: dictionary)
    print(applicant)
} catch {
    print(error)
}
