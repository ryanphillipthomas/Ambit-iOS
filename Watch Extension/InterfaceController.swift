//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Ryan Phillip Thomas on 2/3/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController,  DataSourceChangedDelegate{
    
    @IBOutlet var foodLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(self)
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        WatchSessionManager.sharedManager.removeDataSourceChangedDelegate(self)
        super.didDeactivate()
    }
    
    @IBAction func start() {
        startAlarm()
    }

    func startAlarm() {
        //DEV TODO Replace with Handoff
        WKInterfaceDevice.current().play(.success)
//        let parentValues = ["command" : "start"]
//        WKInterfaceController.openParentApplication(parentValues, reply: { (parentValues, error) -> Void in
//            
//        })
    }
    
    //MARK: - DataSourceChangedDelegate
    func dataSourceDidUpdate(_ dataSource: DataSource) {
        switch dataSource.item {
        case .food(let foodItem):
            foodLabel.setText(foodItem)
            WKInterfaceDevice.current().play(.success)
        case .unknown:
            foodLabel.setText("¯\\_(ツ)_/¯")
            break
        }
    }
}

