//
//  ViewController.swift
//  Todoey
//
//  Created by Khalil panahi
//

import CoreData
import UIKit

class TodoListViewController: UITableViewController {
    var itemArray = [Todo]()

    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    @IBOutlet var searchBar: UISearchBar!

    // to access context of "saveContext" method in AppDelegate file
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        searchBar.delegate = self

        // to retrieve data
//        loadItems()
    }

    // MARK: - DATASOURCE

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)

        let item = itemArray[indexPath.row]

        cell.textLabel?.text = item.title

        // to add and remove selected mark after selecting a row
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }

    // MARK: TebleView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // to update done property of element
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

//        to remove the item from context
//        context.delete(itemArray[indexPath.row])

//        to remove the item from local array variable
//        itemArray.remove(at: indexPath.row)

//        save the changes
        saveItems()

        // to return the color of selected row to default after selecting the row
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - ADD NEW ITEM

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            // what will happen once the user clicks the add item on UIAlert

            // create an object of Entity using context of "persistentContainer"
            var newTodo = Todo(context: self.context)

            newTodo.title = textField.text!
            newTodo.done = false
            newTodo.parentCategory = self.selectedCategory

            self.itemArray.append(newTodo)

            self.saveItems()
        }

        // adding a textfield into alert
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context : ", error)
        }

        tableView.reloadData()
    }

    // this method has external(with:) and internal(request) parameters
    // and it has a default value for request(Todo.fetchRequest()), if we do not specify any request when we call this method, the default value will be set to request parameter
    func loadItems(with request: NSFetchRequest<Todo> = Todo.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name as! CVarArg)

        if let aditionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, aditionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        // run the fetch request
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data : ", error)
        }

        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // create an fetchrequest object for Todo Entity
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()

        // creating query
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        // add query to request
//        request.predicate = predicate

        // create a sort descriptor rule
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)

        // set the sortDescriptor rule into request.(we can use multiple sort rules in the array)
        request.sortDescriptors = [sortDescriptor]

        loadItems(with: request, predicate: predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        to load all items when searchbar does not have any text
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
//                to hide keyboard when clear the search bar
                searchBar.resignFirstResponder()
            }
        }
    }
}
