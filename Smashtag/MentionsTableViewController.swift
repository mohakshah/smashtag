//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Mohak Shah on 17/09/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit
import CoreData

class MentionsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate
{
    private let fetchControllerCacheName = "search-mentions"
    
    // Model
    var searchString: String? {
        didSet {
            if searchString == nil {
                fetchedResultsController = nil
            } else {
                if let moc = TweetsDB.moc {
                    // get the search object corresponding to this search string
                    if let search = Search.searchWithTerm(searchString!, inManagedObjectContext: moc) {
                        let request = NSFetchRequest(entityName: "SearchMention")
                        
                        request.sortDescriptors = [NSSortDescriptor(key: "type", ascending: true),
                                                   NSSortDescriptor(key: "count", ascending: false),
                                                   NSSortDescriptor(key: "keyword", ascending: true,
                                                                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
                        
                        request.predicate = NSPredicate(format: "search = %@ && count > 1", search)
                        
                        
                        
                        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                              managedObjectContext: moc,
                                                                              sectionNameKeyPath: "type",
                                                                              cacheName: fetchControllerCacheName)
                    } else {
                        print("Could not get the search object")
                    }
                } else {
                    print("Could not get the moc :(")
                }
            }
        }
    }
    
    private var fetchedResultsController: NSFetchedResultsController? {
        willSet {
            NSFetchedResultsController.deleteCacheWithName(fetchControllerCacheName)
        }
        didSet {
            fetchedResultsController?.delegate = self
            do {
                try self.fetchedResultsController?.performFetch()
                
                tableView.reloadData()
            } catch let e {
                print(e)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections where sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name.stringByAppendingString("S")
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mentionCell", forIndexPath: indexPath)

        // Configure the cell...
        if let mention = fetchedResultsController?.objectAtIndexPath(indexPath) as? SearchMention {
            cell.textLabel?.text = mention.keyword
            cell.detailTextLabel?.text = (mention.count == nil ? "" : "\(mention.count!)")
        }
        
        return cell
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
