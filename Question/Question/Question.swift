//
//  Question.swift
//  tuss_ios
//
//  Created by admin on 2019/4/12.
//  Copyright © 2019 develop. All rights reserved.
//

import UIKit
import HandyJSON
class QuestionList : HandyJSON{

    var id, surveyID, type, title: String?
    var seq: Int?
    var choices: Array<Choice>?
    required init() {
    }



}

class Choice : HandyJSON {

    var title ,label: String?
    var seq, score: Int?
    required init() {}

}


class EvaluateResult: HandyJSON {
    var score : Double?
    var evaluationGradeCode,evaluationGradeDesc: String?
    
    
    required init() {}

}


class EvaluateBody: HandyJSON {
    
    var answers : [[String : Any]]?
    var surveyId : String = "1000"
    required init() {}

}
