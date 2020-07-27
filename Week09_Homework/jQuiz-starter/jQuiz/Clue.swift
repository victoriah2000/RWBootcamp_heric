//
//  QuestionCodable.swift
//  jQuiz
//
//  Created by Jay Strawn on 7/17/20.
//  Copyright © 2020 Jay Strawn. All rights reserved.
//

import Foundation

struct Clue: Codable {
  var question: String
  var answer: String
  var category: Category
}

struct Category: Codable {
  var id: Int
  var title: String
}
