//
//  ViewController.swift
//  mongokittenExample
//
//  Created by Akarsh Seggemu on 19.10.18.
//  Copyright © 2018 Akarsh Seggemu. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    // table Array for storing the JSON Output
    var tableArray = [String] ()
    
    // MARK: model is stored as lazy var
    /* Swift documentation
     * https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID257
     * for more information
     */
    lazy var model: ModelInput! = { [unowned self] in
        let model = Model()
        model.output = self
        return model
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // calling model load function
        model.load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: TableViewController
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
        for item in model.items {
            tableArray.append(item.title)
        }
        
//        print(self.tableArray)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func modelDidFail(error: Error?) {
        print("modelDidFail with error: \(String(describing: error))")
    }
}

// FIXME: Move to a new swift file
// Data structure stores the id and title
struct Data: Codable {
    let id: String
    let title: String
}

// Inputs the data into the model
protocol ModelInput {
    var items: [Data] { get }
    func load()
}

// Outputs the data from the model
protocol ModelOutput: class {
    func modelDidLoad()
    func modelDidFail(error: Error?)
}

// Model class extends ModelInput
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
/*
 * Encoding and Decoding Custom Types
 * https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
 */
                self?.items = try JSONDecoder().decode([Data].self, from: data)
                self?.output.modelDidLoad()
            } catch {
                self?.output.modelDidFail(error: error)
            }
        }
        task.resume()
    }
    
}
