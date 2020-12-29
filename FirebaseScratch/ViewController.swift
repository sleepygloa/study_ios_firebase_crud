//
//  ViewController.swift
//  FirebaseScratch
//
//  Created by joonwon lee on 20/04/2019.
//  Copyright © 2019 com.joonwon. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController {
    @IBOutlet weak var firstDataLabel: UILabel!
    @IBAction func updateCustomers(_ sender: Any) {
        guard customers.isEmpty == false else { return }
        customers[0].name = "Lee"
        let dictValues = customers.map { $0.toDictionary }
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(["customers": dictValues])
    }
    
    @IBAction func deleteCustomers(_ sender: Any) {
        let rootRef = Database.database().reference()
        rootRef.child("customers").removeValue()
    }
    
    @IBAction func createCustomers(_ sender: Any) {
        saveCustomers()
    }
    
    @IBAction func fetchCustomers(_ sender: Any) {
        fetchCustomers()
    }
    
    var customers: [Customer] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        //updateLabel()
        //saveBasicType()
        //saveCustomers()
        //fetchCustomers()
        //updateBasicTypes()
        //deleteBasicTypes()
    }
    
    func deleteBasicTypes() {
        let rootRef = Database.database().reference()
        rootRef.child("int").removeValue()
        rootRef.child("double").removeValue()
        rootRef.child("str").removeValue()
    }
    
    func updateBasicTypes() {
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(["int": 6])
        rootRef.updateChildValues(["double": 5.4])
        rootRef.updateChildValues(["array": ["d", "e", "f"]])
    }
    
    func fetchCustomers() {
        let rootRef = Database.database().reference()
        rootRef.child("customers").observeSingleEvent(of: .value) { (snapshot) in
            
            do {
                let data = try JSONSerialization.data(withJSONObject: snapshot.value, options: [])
                let customers = try JSONDecoder().decode([Customer].self, from: data)
                let names = customers.map { customer in
                    return customer.name
                }
                self.customers = customers
                self.firstDataLabel.text = names.joined(separator: "--")
            } catch let error {
                print("---> err: \(error.localizedDescription)")
            }
        }
        
    }
    
    func updateLabel() {
        let rootRef = Database.database().reference()
        // ovserveSingleEvent: 서버로부터 한번만 읽을때 사용
        rootRef.child("str").observeSingleEvent(of: .value) { snapshot in
            print("---> \(snapshot)")

            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.firstDataLabel.text = "\(value)"
            }
        }
    }
    
    func saveBasicType() {
        let rootRef = Database.database().reference()
        // Firebase data saving
        // available data type
        // - number
        // - string
        // - dictionary
        // - array
        
        rootRef.child("int").setValue(3)
        rootRef.child("double").setValue(3.4)
        rootRef.child("str").setValue("string value - 여러분 안녕!")
        rootRef.child("array").setValue(["a", "b", "c"])
        rootRef.child("dict").setValue(["id": "AnyID", "age": 10, "city": "Seoul"])
    }
    
    var id = 0
    func saveCustomers() {
        // 책가게
        // 사용자를 저장하겠다(책정보 포함)
        // 모델: customer, book
        
        let books = [Book(title: "Good to Great", author: "Someone"), Book(title: "Hacking Growth", author: "Someone else")]
        let newCustomer1 = Customer(id: "\(id)", name: "Son", books: books)
        id += 1
        let newCustomer2 = Customer(id: "\(id)", name: "Dele", books: books)
        id += 1
        let newCustomer3 = Customer(id: "\(id)", name: "Kane", books: books)
        id += 1

        
        let rootRef = Database.database().reference()
        rootRef.child("customers").child(newCustomer1.id).setValue(newCustomer1.toDictionary)
        rootRef.child("customers").child(newCustomer2.id).setValue(newCustomer2.toDictionary)
        rootRef.child("customers").child(newCustomer3.id).setValue(newCustomer3.toDictionary)
    }
}

struct Customer: Codable {
    let id: String
    var name: String
    let books: [Book]
    
    var toDictionary: [String: Any] {
        let booksArray = books.map { $0.toDictionary }
        let dict: [String: Any] = ["id": id, "name": name, "books": booksArray]
        return dict
    }
}


struct Book: Codable {
    let title: String
    let author: String
    
    var toDictionary: [String: Any] {
        let dict: [String: Any] = ["title": title, "author": author]
        return dict
    }
}
