//
//  ViewController.swift
//  mongokittenExample
//
//  Created by Akarsh Seggemu on 19.10.18.
//  Copyright © 2018 Akarsh Seggemu. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var tableArray = [String] ()
    
    lazy var model: ModelInput! = { [unowned self] in
        let model = Model()
        model.output = self
        return model
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        model.load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        
        cell.textLabel?.text = self.tableArray[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tableArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.tableArray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            self.tableArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print(self.tableArray)
        }
        
        let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            // share item at indexPath
            print("I want to share: \(self.tableArray[indexPath.row])")
        }
        
        share.backgroundColor = UIColor.lightGray
        
        return [delete, share]
        
    }
    
}

// MARK: - ModelOutput
extension ViewController: ModelOutput {
    
    func modelDidLoad() {
        print("modelDidLoad with items: \(model.items)")
        model.items.forEach {
            print($0)
        }

        
//        print(self.tableArray)
        
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
    }
    
    func modelDidFail(error: Error?) {
        print("modelDidFail with error: \(String(describing: error))")
    }
}

struct Data: Codable {
    let id: String
    let title: String
}

protocol ModelInput {
    var items: [Data] { get }
    func load()
}

protocol ModelOutput: class {
    func modelDidLoad()
    func modelDidFail(error: Error?)
}

final class Model: ModelInput {
    
    private (set) var items: [Data] = []
    weak var output: ModelOutput!
    
    func load() {
        let url = URL(string: "http://localhost:8080/todos")!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let data = data else {
                self?.output.modelDidFail(error: error)
                return
            }
            do {
//                self?.items = try JSONDecoder().decode([Data].self, from: data)
                self?.items = try JSONDecoder().decode(Array<Data>.self, from: data)
                self?.output.modelDidLoad()
            } catch {
                self?.output.modelDidFail(error: error)
            }
        }
        task.resume()
    }
    
}
