//
//  File.swift
//  
//
//  Created by Serghei Garbalinschi on 17/12/2023.
//

import Foundation
import Vapor

struct AcronymsCreateRequest: Content {
    let short: String
    let long: String
    let userID: UUID
}
