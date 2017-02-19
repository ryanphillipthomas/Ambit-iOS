//
//  EventOptionsViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 2/19/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit
import CoreData
import RTCoreData
import UserNotifications
import EventKit

class EventOptionsViewController: UIViewController, ManagedObjectContextSettable {
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var containerView: UIView!
    weak var tableViewController:UITableViewController!
    weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        self.tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        self.tableView.backgroundView = blurEffectView
        self.navigationController?.navigationBar.addSubview(blurEffectView)
        
        self.tableView.allowsSelection = true;


        loadEvents()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerSegue", let tableVC = segue.destination as? UITableViewController {
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = UIColor.white
            refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh), for: UIControlEvents.valueChanged)
            tableVC.refreshControl = refreshControl
            self.tableView = tableVC.tableView
            self.tableViewController = tableVC
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    
    
    func handleRefresh() {
        loadFutureEvents()
        
        fetch()
        self.tableView.reloadData()
        self.tableViewController.refreshControl?.endRefreshing()
    }
    
    // MARK - Load Events
    func loadEvents() {
        fetch()
        self.tableView.reloadData()
        //        updateView()
        loadFutureEvents()
    }
    
    func loadFutureEvents() {
        Event.allUpcoming(moc: managedObjectContext) { (events) in
            //print(events)
            self.tableViewController.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: -fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController<Event> = {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        
        // Configure Fetch Request
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 100
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    func fetch () {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    
    @IBAction func didSelectDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"didToggleStatusBar"), object: false)
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EventOptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let count = fetchedResultsController.fetchedObjects?.count
        
        var cell:UITableViewCell
        
        let event = fetchedResultsController.object(at:indexPath)
        cell = tableView.dequeueReusableCell(withIdentifier: "eventTableViewCell", for: indexPath)
        
        // Configure Cell
        configure(cell as! EventTableViewCell, at: indexPath)
        return cell
    }
    
    func configure(_ cell: EventTableViewCell, at indexPath: IndexPath) {
        let row = indexPath.row
        let count = fetchedResultsController.fetchedObjects?.count
        let event = fetchedResultsController.object(at: indexPath)
        cell.configureWith(eventIndex: Int(row), numberOfItems: Int(count!), event:event)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let event = fetchedResultsController.object(at: indexPath)
    }
}

extension EventOptionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let events = fetchedResultsController.fetchedObjects else { return 0 }
        return events.count
    }
}

extension EventOptionsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        //        updateView()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell {
                configure(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
}

extension EventOptionsViewController: EventManagerDelegate {
    func needPermissionToCalendar() {
        //Display alert that we need the users calendar permission
    }
    func loadCalendars() {
        self.loadEvents()
    }
    func requestAccessToCalendar() {
        EKEventStore().requestAccess(to: .event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.loadCalendars()
                    self.tableView.reloadData()
                })
            } else {
                //Display alert that we need the users calendar permission
            }
        })
    }
}


