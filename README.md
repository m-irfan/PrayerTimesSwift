<p align="center">
<img src="https://cloud.githubusercontent.com/assets/4659608/12704381/cc10b62a-c86a-11e5-9624-6cdb12ea1e74.png">
</p>
# PrayerTimesSwift

Prayer Times provides a set of handy functions to calculate prayer times for any location around the world, based on a variety of calculation methods currently used in Muslim communities.

You can report any issue on issues page. **Note: If you speak Arabic, you can submit issues with Arabic language and I will check them. :)**

## Requirements

## Installation


Just add `pod "PrayerTimesSwift", :git => 'https://github.com/m-irfan/PrayerTimesSwift'` to your Podfile and go!
PrayerTimesSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
  pod "PrayerTimesSwift", :git => 'https://github.com/m-irfan/PrayerTimesSwift'
```

Then run `pod install`


### Create an `PrayerTime`
You will need to create a new instance of `PrayerTime`. Once the instance are configured, you can call `getPrayerTimes()` and it's will return a dictionary. 

```swift
// EXAMPLE : PAKISTAN LAHORE PRAYER TIMES
// note: change latitude and longitude and timezone if you want to test your location results
let prayerTimes = myPrayerTime.getPrayerTimes(date: Calendar.current, latitude: 31.5204, longitude: 74.3587, tZone: 5)
print(prayerTimes)

//["Fajr": "04:38 am", "Sunrise": "05:57 am", "Dhuhr": "11:39 am", "Asr": "02:55 pm", "Sunset": "05:21 pm", "Maghrib": "05:21 pm", "Isha": "06:51 pm"]
```


### Configurations
* `TimeFormat` To change the time format to:
* `Time24`  24-hour format
* `Time12`  12-hour format
* `Time12NS`  12-hour format with no suffix
* `Floating`  floating point number
```swift
myPrayerTime.timeFormat = .time24
```
* `Caculationmethod` To change the Calculation Methods.
* `Karachi`  University of Islamic Sciences, Karachi
* `ISNA`  Islamic Society of North America (ISNA)
* `MWL`  Muslim World League (MWL)
* `Makkah`  Umm al-Qura, Makkah
* `Egypt`  Egyptian General Authority of Survey
* `Jafari`  Ithna Ashari
* `Tehran`  Institute of Geophysics, University of Tehran
* `Custom`  Custom Setting
```swift
myPrayerTime.Caculationmethod = .makkah
```
* `AsrJuristic` To change Juristic Method for Asr
* `Shafii`  Shafii (standard)
* `Hanafi`  Hanafi
```swift
myPrayerTime.asrJuristic = .shafii
```
* `AdjustHighLats` Adjusting Methods for Higher Latitudes
* `None`  No adjustment
* `MidNight`  middle of night
* `OneSeventh`  1/7th of night
* `AngleBased`  angle/60th of night
```swift
myPrayerTime.adjustHighLats = .none
```
* `tuneTimes` Tune timings for adjustments
```swift
myPrayerTime.tuneTimes([0,0,0,0,0,0,0])
```

## Update

Code updated for swift 4

## Author

Abdullah Alhazmy

## Contributer

Irfan Anwar

## Credits
[Praytimes](http://praytimes.org)


## License

PrayerTimesSwift is available under the MIT license. See the LICENSE file for more info.
