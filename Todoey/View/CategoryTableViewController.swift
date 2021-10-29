//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by khalil.panahi on 29/10/21.
//

import CoreData
import UIKit

class CategoryTableViewController: UITableViewController {
    var categories = [Category]()

    // to access context of "saveContext" method in AppDelegate file
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellCategory = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        let item = categories[indexPath.row]

        cellCategory.textLabel?.text = item.name
        
        return cellCategory
    }

    // MARK: - Data Manipulation Methods

    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context : ", error)
        }

        tableView.reloadData()
    }

    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        // run the fetch request
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data : ", error)
        }
        
        tableView.reloadData()
    }

    // MARK: - Add New Item

    @IBAction func addButtonpressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)

        // adding a textfield into alert
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { _ in
            // what will happen once the user clicks the add item on UIAlert

            // create an object of Entity using context of "persistentContainer"
            var newCategory = Category(context: self.context)

            newCategory.name = textField.text!

            self.categories.append(newCategory)

            self.saveItems()
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
}


