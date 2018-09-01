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
        
        // LAHORE PRAYER TIMES
        let prayerTimes = myPrayerTime.getPrayerTimes(date: Calendar.current, latitude: 31.5204, longitude: 74.3587, tZone: 5)
        print(prayerTimes)
        //["Isha": "06:51 pm", "Dhuhr": "11:39 am", "Fajr": "04:38 am", "Sunrise": "05:57 am" , "Maghrib": "05:21 pm", "Asr": "02:55 pm", "Sunset": "05:21 pm"]
  
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

