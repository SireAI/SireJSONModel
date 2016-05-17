//
//  ViewController.swift
//  SireJSONModel
//
//  Created by Sire on 05/17/2016.
//  Copyright (c) 2016 Sire. All rights reserved.
//

import UIKit
import SireJSONModel
class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		let path = NSBundle.mainBundle().pathForResource("data", ofType: "json")
		let data = NSData(contentsOfFile: path!)
		let jsonData = MallInfor(jsonNSData: data!)
		print("\(jsonData.toDictionary())")
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

