//
//  ViewController.swift
//  MeetMe
//
//  Created by Bruno Cortes on 30/01/17.
//  Copyright © 2017 Change Logic. All rights reserved.
//

import UIKit
import CoreLocation

struct Question {
    var questionString: String?
    var answers: [String]?
    var selectedAnswerIndex: Int?
}

var questionsList: [Question] = [Question(questionString: "Que tipo de encontro você espera?", answers: ["Bate papo descontraído", "Almoço/Jantar romântico", "Encontro divertido", "Encontro amoroso"], selectedAnswerIndex: nil),
                                 Question(questionString: "Você quer algo ousado/sofisticado?", answers: ["Sim", "Não"], selectedAnswerIndex: nil),
                                 Question(questionString: "Dia ou noite?", answers: ["Dia", "Noite"], selectedAnswerIndex: nil)]

var respostas = [Int]()
var tipoEncontro:Int = 0
var impressionar:Int = 0
var diaNoite:Int = 0

class QuestionController: UITableViewController {
    
    let cellId = "cellId"
    let headerId = "headerId"
    var mapViewController: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Questionário"
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Voltar", style: .plain, target: nil, action: nil)
        
        tableView.register(AnswerCell.self, forCellReuseIdentifier: cellId)
        tableView.register(QuestionHeader.self, forHeaderFooterViewReuseIdentifier: headerId)
        
        tableView.sectionHeaderHeight = 50
        tableView.tableFooterView = UIView()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let index = navigationController?.viewControllers.index(of: self) {
            let question = questionsList[index]
            if let count = question.answers?.count {
                return count
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AnswerCell
        
        if let index = navigationController?.viewControllers.index(of: self) {
            let question = questionsList[index]
            cell.nameLabel.text = question.answers?[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId) as! QuestionHeader
        
        if let index = navigationController?.viewControllers.index(of: self) {
            let question = questionsList[index]
            header.nameLabel.text = question.questionString
        }
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let index = navigationController?.viewControllers.index(of: self) {
            
            respostas.insert(indexPath.item, at: index)
            
            questionsList[index].selectedAnswerIndex = indexPath.item
            if index < questionsList.count - 1 {
                let questionController = QuestionController()
                navigationController?.pushViewController(questionController, animated: true)
            } else {
                let controller = ResultsController()
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
}

class ResultsController: UIViewController {
    
    let resultsLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 3
        return label
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 1)
        button.setTitle("Confirmar", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleConfirmAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    func handleConfirmAction() {
        
        let mapController = MapViewController()
        mapController.resultsController = self
        let navController = UINavigationController(rootViewController: mapController)
        present(navController, animated: true, completion: nil)
        mapController.tipoEncontro = (questionsList[0].answers?[respostas[0]])!.lowercased()
        //         inputsContainerViewHeightAnchor?.constant = loginRegisterControl.selectedSegmentIndex == 0 ? 100 : 150
        mapController.impressionar = (questionsList[1].answers?[respostas[1]])! == "Sim" ? true : false
        mapController.day = (questionsList[2].answers?[respostas[2]])!.lowercased() == "dia" ? true : false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refazer", style: .plain, target: self, action: #selector(ResultsController.done))
        
        navigationItem.title = "Resultado"
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(resultsLabel)
        view.addSubview(confirmButton)
        
        
        setupLayout()
        
        var texto:String = ""
        
        texto += "Então você quer um " + (questionsList[0].answers?[respostas[0]])!.lowercased()
        if (questionsList[1].answers?[respostas[1]])! == "Sim" {
            texto += " que impressione"
        } else{
            texto += " que não precisa ser impressionante"
        }
        texto += " e que seja de " + (questionsList[2].answers?[respostas[2]])!.lowercased() + "?"
        
        
        resultsLabel.text = texto
    }
    
    func setupLayout() {
        
        resultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        resultsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        resultsLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmButton.topAnchor.constraint(equalTo: resultsLabel.bottomAnchor, constant: 12).isActive = true
        confirmButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func done() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
}

class QuestionHeader: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Question"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AnswerCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Answer"
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
    
}
