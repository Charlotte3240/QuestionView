//
//  RiskAssessmentController.swift
//  Charlotte question view
//
//  Created by Charlotte on 2019/4/12.
//  Copyright © 2019 develop. All rights reserved.
//风险评测

import UIKit
import SnapKit

class RiskAssessmentController: UIViewController {
    
    var tableView : UITableView?
    
    var headerView : RiskHeaderView?
    
    var footerView : RiskFooterView?
    
    var currentPage : Int = 1
    
    var pageCount : Int = 12
    
    var dataList = [QuestionList](){
        didSet{
            self.pageCount = dataList.count
            self.tableView?.reloadData()
        }
    }
    
    var resultArray = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init question view
        self.initTableView()
        
        // fetch answers
        self.getAnswers()
        
    }
    
    
    
    
    
    func getAnswers(){
        self.dataList =  [QuestionList] ()

        
    }
    
    
    func initTableView(){
        
        let list = UITableView.init(frame: self.view.bounds, style: .plain)
        list.rowHeight = UITableView.automaticDimension
        list.sectionHeaderHeight = UITableView.automaticDimension
        list.estimatedSectionHeaderHeight = 90
        list.register(UITableViewCell.self, forCellReuseIdentifier: "riskCell")
        list.delegate = self
        list.dataSource = self
        self.view.addSubview(list)
        list.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        self.tableView = list
        
    }
    
    @objc func nextAction(){
        if self.currentPage+1 > self.pageCount{
            //超过题目数量
            return
        }
        self.currentPage += 1
        self.tableView?.reloadData()
        self.tableView?.reloadSections([0], with: .left)
    }
    
    @objc func previousAction(){
        if self.currentPage-1 < 1{
            //超过题目数量
            return
        }
        self.currentPage -= 1
        self.tableView?.reloadData()
        self.tableView?.reloadSections([0], with: .right)
    }
    
    
    func userEvaluate(){
       // send result
        print("result is send server")
    }
    
    
}

extension RiskAssessmentController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataList.isEmpty { return 0 }
        
        let currentPageQuestions = self.dataList[self.currentPage-1]
        let currentChoices = currentPageQuestions.choices
        return currentChoices?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "riskCell", for: indexPath)
        cell.selectionStyle = .none
        
        let currentPageQuestions = self.dataList[self.currentPage-1]
        let choice = currentPageQuestions.choices?[indexPath.row]
        
        cell.textLabel?.text = "\(choice?.title ?? "")"
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentPageQuestions = self.dataList[self.currentPage-1]
        guard let choice = currentPageQuestions.choices?[indexPath.row] else {
            return
        }
        
        if self.resultArray.count >= self.currentPage {
            //替换已经回答过的答案
            self.resultArray[self.currentPage-1] = ["choices":choice.label ?? "","questionId":currentPageQuestions.id ?? ""]
            
        }else{
            self.resultArray.append(["choices":choice.label ?? "","questionId":currentPageQuestions.id ?? ""])
            
            print(choice.title ?? "")
            
            //问题全部答完
            if self.resultArray.count == pageCount{
                //问题全部答完 获取风险等级并显示结果
                self.userEvaluate()
                
                return
            }
            
        }
        
        self.nextAction()
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = RiskFooterView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 30))
        footerView.nextBtn?.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        footerView.previousBtn?.addTarget(self, action: #selector(previousAction), for: .touchUpInside)
        if currentPage == 1{
            footerView.previousBtn?.isHidden = true
        }else{
            footerView.previousBtn?.isHidden = false
        }
        
        if currentPage == self.pageCount{
            footerView.nextBtn?.isHidden = true
        }else if self.resultArray.count > self.currentPage-1{
            footerView.nextBtn?.isHidden = false
        }else{
            footerView.nextBtn?.isHidden = true
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.dataList.isEmpty {return UIView.init()}
        
        let headerView = RiskHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 90))
        let pageString = "\(self.currentPage)/\(self.pageCount)"
        let cuurentPageString = "\(self.currentPage)"
        let attributedString = NSMutableAttributedString.init(string: pageString)
        
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.blue,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 35)], range: NSRange.init(location: 0, length: cuurentPageString.count))
        
        headerView.indexTitle?.attributedText = attributedString
        
        let currentPageRes = self.dataList[self.currentPage-1]
        
        headerView.topicTitle?.text = "\(currentPageRes.title ?? "")"
        return headerView
    }
    
    
}

class RiskHeaderView: UIView {
    
    var indexTitle : UILabel?
    
    var topicTitle : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        indexTitle = UILabel.init()
        self.addSubview(indexTitle!)
        indexTitle?.snp.makeConstraints({ (m) in
            m.top.right.equalToSuperview()
            m.left.equalToSuperview().offset(15)
            m.height.equalTo(45)
        })
        
        topicTitle = UILabel.init()
        topicTitle?.numberOfLines = 0
        topicTitle?.textColor = UIColor.blue
        topicTitle?.textAlignment = .left
        self.addSubview(topicTitle!)
        topicTitle?.snp.makeConstraints({ (m) in
            m.top.equalTo((indexTitle?.snp.bottom)!)
            m.bottom.equalToSuperview().offset(-10)
            m.left.equalToSuperview().offset(15)
            m.right.equalToSuperview().offset(-15)
        })
        
        let grayView = UIView.init()
        grayView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
        self.addSubview(grayView)
        grayView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.height.equalTo(10)
            m.top.equalTo((topicTitle?.snp.bottom)!)
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class RiskFooterView : UIView {
    
    var nextBtn : UIButton?
    var previousBtn : UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let previousButton = UIButton.init(type: .system)
        previousButton.setTitle("上一题", for: .normal)
        previousButton.setTitleColor(UIColor.blue, for: .normal)
        self.addSubview(previousButton)
        previousButton.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(35)
            m.centerY.equalToSuperview()
        }
        self.previousBtn = previousButton
        
        
        let nextPageButton = UIButton.init(type: .system)
        nextPageButton.setTitle("下一题", for: .normal)
        nextPageButton.setTitleColor(UIColor.blue, for: .normal)
        self.addSubview(nextPageButton)
        nextPageButton.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-35)
            m.centerY.equalToSuperview()
        }
        self.nextBtn = nextPageButton
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
}
