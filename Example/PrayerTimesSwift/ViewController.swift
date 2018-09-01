//
//  ViewController.swift
//  PrayerTimesSwift
//
//  Created by Abdullah Alhazmy on 01/31/2016.
//  Copyright (c) 2016 Abdullah Alhazmy. All rights reserved.
//

import UIKit
import PrayerTimesSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let myPrayerTime = PrayerTimes(caculationmethod: .Karachi, asrJuristic: .Hanafi, adjustHighLats: .None, timeFormat: .Time12)
        
        // EXAMPLE : PAKISTAN LAHORE PRAYER TIMES
        // note: change latitude and longitude and timezone if you want to test your location results
        let prayerTimes = myPrayerTime.getPrayerTimes(date: Date(), latitude: 24.7253981, longitude: 46.2620579, tZone: 3)
        print(prayerTimes)
        print(prayerTimes)
        
        //["Fajr": "04:38 am", "Sunrise": "05:57 am", "Dhuhr": "11:39 am", "Asr": "02:55 pm", "Sunset": "05:21 pm", "Maghrib": "05:21 pm", "Isha": "06:51 pm"]
  
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

