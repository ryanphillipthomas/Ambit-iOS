//
//  ViewController.swift
//  TV
//
//  Created by Ryan Phillip Thomas on 2/3/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var backroundAnimation = CAGradientLayer()
    @IBOutlet var clockTimeLabel:SBTimeLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        clockTimeLabel.updateText()
        clockTimeLabel.start()
        
        // Do any additional setup after loading the view, typically from a nib.
//        backroundAnimation = GradientHandler.addGradientLayer()
//        GradientViewHelper.addGradientColorsToView(view: self.view, gradientLayer: backroundAnimation)
    }
    
    override func viewDidLayoutSubviews() {
        backroundAnimation.frame = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleLights(_ sender: Any) {
        performSegue(withIdentifier: "lightOptions", sender: nil)
    }

}

