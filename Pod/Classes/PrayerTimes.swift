//
//  main.swift
//  PrayerTimes
//
//  Created by Abdullah Alhazmy on 1/26/16.
//  Copyright © 2016 Abdullah Alhazmy. All rights reserved.
//

import Foundation

public class PrayerTimes{
    
    
    
    // ---------------------- Global Variables --------------------
    public var caculationMethod : CalculationMethods = .Makkah // CalculationMethods(rawValue:  4)! // caculation method
    public var asrJuristic : AsrJuristicMethods = .Shafii // Juristic method for Asr
    var dhuhrMinutes: Int = 0 // minutes after mid-day for Dhuhr
    public var adjustHighLats : AdjustingMethods = .None // adjusting method for higher latitudes
    public var timeFormat : TimeForamts = .Time24 // time format
    var prayerTimesCurrent: [Double] = []
    var offsets = [Double](repeating: 0.0, count: 7)
    var lat: Double = Double() // latitude
    var lng: Double = Double() // longitude
    var timeZone: Double = Double() // time-zone
    var JDate: Double = Double() //0.0 // Julian date
    
    
    internal enum PrayerName : String {
        case Fajr = "Fajr"
        case Sunrise = "Sunrise"
        case Dhuhr = "Dhuhr"
        case Asr = "Asr"
        case Sunset = "Sunset"
        case Maghrib = "Maghrib"
        case Isha = "Isha"
        case InvalidTime =  " ---- "
    }
    
    
    // ------------------------------------------------------------
    // Calculation Methods
    public enum CalculationMethods: Int {
        case Jafari = 0  // Ithna Ashari
        case Karachi // University of Islamic Sciences, Karachi
        case Isna  // Islamic Society of North America (ISNA)
        case Mwl // Muslim World League (MWL)
        case Makkah // Umm al-Qura, Makkah
        case Egypt // Egyptian General Authority of Survey
        case Custom  // Custom Setting
        case Tehran  // Institute of Geophysics, University of Tehran
    }
    
    // ------------------------------------------------------------
    // Juristic Methods
    public enum AsrJuristicMethods: Int {
        case Shafii // Shafii (standard)
        case Hanafi // Hanafi
    }
    
    // ------------------------------------------------------------
    // Adjusting Methods for Higher Latitudes
    public enum AdjustingMethods: Int {
        case None // No adjustment
        case MidNight  // middle of night
        case OneSeventh // 1/7th of night
        case AngleBased // floating point number
    }
    
    // ------------------------------------------------------------
    // Time Formats
    public enum TimeForamts: Int {
        case Time24 // 24-hour format
        case Time12 // 12-hour format
        case Time12NS // 12-hour format with no suffix
        case Floating // angle/60th of night
    }
    
    // ------------------------------------------------------------
    // Time Names
    let prayerTimeNames : [PrayerName] = [.Fajr, .Sunrise, .Dhuhr, .Asr , .Sunset, .Maghrib, .Isha]
    // ------------------------------------------------------------
    // Time Names
    let numIterations: Int = 1// number of iterations needed to compute times
    var methodParams: [CalculationMethods: [Double]] = [
        .Jafari: [16,0,4,0,14],
        .Karachi: [18,1,0,0,18],
        .Isna: [15,1,0,0,15],
        .Mwl: [18,1,0,0,17],
        .Makkah: [18.5,1,0,1,90],
        .Egypt: [18,1,0,0,17],
        .Custom: [19.5,1,0,0,17.5],
        .Tehran: [17.7,0,4.5,0,14]
        
    ]
    
    // ------------------------------------------------------------
    // Init
    public init(caculationmethod: CalculationMethods, asrJuristic: AsrJuristicMethods, adjustHighLats:AdjustingMethods , timeFormat:TimeForamts){
        self.caculationMethod = caculationmethod
        self.asrJuristic = asrJuristic
        self.adjustHighLats = adjustHighLats
        self.timeFormat = timeFormat
        
    }
    public init(caculationmethod: CalculationMethods, asrJuristic: AsrJuristicMethods, adjustHighLats:AdjustingMethods , timeFormat:TimeForamts, offsets:[Double]){
        self.offsets = offsets
    }
    
    
    
    
    
    
    // ---------------------- Julian Date Functions -----------------------
    // calculate julian date from a calendar date
    func julianDate(year: Int, month: Int, day: Int) -> Double {
        
        var adujestedYear = year
        var adujestedMonth = month
        
        if (adujestedMonth <= 2) {
            adujestedYear = adujestedYear - 1
            adujestedMonth = adujestedMonth + 12
        }
        
        let a = floor(Double(adujestedYear) / 100.0)
        let b = 2 - a + floor(a / 4.0)
        let jd1 = floor(365.25 * Double(adujestedYear + 4716))
        let jd2 = floor(30.6001 * Double(adujestedMonth + 1))
        let jd = jd1 + jd2 + Double(day) + b - 1524.5
        
        return jd
    }
    
    // convert a calendar date to julian date (second method)
    func calcJD(year: Int,month: Int,day: Int) ->Double {
        let J1970 = 2440588.0
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        let calendar = NSCalendar.current.date(from: dateComponents)
        let ms = (calendar?.timeIntervalSince1970)!*1000 // # of milliseconds since midnight Jan 1,
        // 1970
        let days = floor(ms / (1000.0 * 60.0 * 60.0 * 24.0))
        return J1970 + days - 0.5
        
    }
    // ---------------------- Calculation Functions -----------------------
    // References:
    // http://www.ummah.net/astronomy/saltime
    // http://aa.usno.navy.mil/faq/docs/SunApprox.html
    // compute declination angle of sun and equation of time
    func sunPosition(jd: Double) -> [Double] {
        
        let D = jd - 2451545
        let g = Double.fixAngle(a: 357.529 + 0.98560028 * D)
        let q = Double.fixAngle(a: 280.459 + 0.98564736 * D)
        let L = Double.fixAngle(a: q + (1.915 * Double.dSin(d: g)) + (0.020 * Double.dSin(d: 2 * g)))
        
        // double R = 1.00014 - 0.01671 * [self dCos:g] - 0.00014 * [self dCos:
        // (2*g)]
        let e = 23.439 - (0.00000036 * D)
        let d = Double.dArcSin(x: Double.dSin(d: e) * Double.dSin(d: L))
        var RA = Double.dArcTan2(y: (Double.dCos(d: e) * Double.dSin(d: L)), x: Double.dCos(d: L))/15.0
        RA = Double.fixHour(a: RA)
        let EqT = q/15.0 - RA
        let sPosition: [Double] = [d,EqT]
        return sPosition
    }
    
    // compute equation of time
    func equationOfTime(jd: Double) -> Double {
        return sunPosition(jd: jd)[1]
    }
    
    // compute declination angle of sun
    func sunDeclination(jd: Double) -> Double {
        return sunPosition(jd: jd)[0]
    }
    
    // compute mid-day (Dhuhr, Zawal) time
    func computeMidDay(t: Double) -> Double {
        let T = equationOfTime(jd: JDate + t)
        let Z = Double.fixHour(a: 12 - T)
        return Z
    }
    
    // compute time for a given angle G
    func computeTime(G: Double, t: Double) -> Double {
        let D = sunDeclination(jd: JDate + t)
        let Z = computeMidDay(t: t)
        let Beg = -Double.dSin(d: G) - Double.dSin(d: D) * Double.dSin(d: lat)
        let Mid = Double.dCos(d: D) * Double.dCos(d: lat)
        let V = Double.dArcCos(x: Beg/Mid)/15.0
        return Z + (G > 90 ? -V : V)
    }
    
    // compute the time of Asr
    // Shafii: step=1, Hanafi: step=2
    func computeAsr(step: Double, t: Double) -> Double {
        let D = sunDeclination(jd: JDate + t)
        let G = -Double.dArcCot(x: step + Double.dTan(d: abs(lat - D)))
        return computeTime(G: G, t: t)
    }
    
    
    // ---------------------- Misc Functions -----------------------
    // compute the difference between two times
    func timeDiff(time1: Double, time2: Double) -> Double {
        return Double.fixHour(a: time2 - time1)
    }
    
    // -------------------- Interface Functions --------------------
    // return prayer times for a given date
    func getDatePrayerTimes(year: Int, month: Int, day: Int, latitude: Double, longitude: Double, tZone: Double) -> Set<String> {
        lat = latitude
        lng = longitude
        timeZone = tZone
        JDate = julianDate(year: year, month: month, day: day)
        let lonDiff = longitude / (15.0 * 24.0)
        JDate = JDate - lonDiff
        return computeDayTimes()
    }
    
    // return prayer times for a given date
    public func getPrayerTimes(date: NSCalendar, latitude: Double, longitude: Double, tZone: Double) -> Set<String> {
        
        let year = (date.component(NSCalendar.Unit.year, from: Date()))
        let month = (date.component(NSCalendar.Unit.month, from: Date()))
        let day = (date.component(NSCalendar.Unit.day, from: Date()))
        
        return getDatePrayerTimes(year: year, month: month, day: day, latitude: latitude, longitude: longitude, tZone: tZone)
    }
    
    // set custom values for calculation parameters
    public func setCustomParams( params: [Double]) {
        
        var newCustomeParms: [Double] = []
        for i in 1...5 {
            if (params[i] == -1) {
                let parm = methodParams[caculationMethod]
                newCustomeParms.append(parm![i])
            } else {
                newCustomeParms.append(params[i])
            }
        }
        methodParams[.Custom] = newCustomeParms
        caculationMethod = .Custom
    }
    
    // set the angle for calculating Fajr
    func setFajrAngle(angle: Double) {
        let params = [angle, -1, -1, -1, -1]
        setCustomParams(params: params)
    }
    
    // set the angle for calculating Maghrib
    func setMaghribAngle(angle: Double) {
        let params = [-1, 0, angle, -1, -1]
        setCustomParams(params: params)
        
    }
    
    // set the angle for calculating Isha
    func setIshaAngle(angle: Double) {
        let params = [-1, -1, -1, 0, angle]
        setCustomParams(params: params)
        
    }
    
    // convert double hours to 24h format
    func floatToTime24(time: Double) -> String {
        
        var result: String
        
        if (time.isNaN) {
            return PrayerName.InvalidTime.rawValue
        }
        
        let fixedTime = Double.fixHour(a: time + 0.5 / 60.0) // add 0.5 minutes to round
        let hours = Int(floor(fixedTime))
        let minutes = Int(floor((Double(fixedTime) - Double(hours)) * 60.0))
        
        if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
            result = "0\(hours):0\((minutes))"
        } else if ((hours >= 0 && hours <= 9)) {
            result = "0\(hours):\((minutes))"
        } else if ((minutes >= 0 && minutes <= 9)) {
            result = "\(hours):0\((minutes))"
        } else {
            result = "\(hours):\((minutes))"
        }
        return result
    }
    
    // convert double hours to 12h format
    func floatToTime12(time: Double,noSuffix: Bool) ->String {
        
        var adujestedTime = time
        
        if (adujestedTime.isNaN){
            return PrayerName.InvalidTime.rawValue
        }
        
        adujestedTime = Double.fixHour(a: adujestedTime + 0.5 / 60) // add 0.5 minutes to round
        
        var hours: Int = Int(floor(adujestedTime))
        let minutes = Int(floor( (Double(adujestedTime) - Double(hours)) * 60))
        var suffix: String, result: String
        if (hours >= 12) {
            suffix = "pm"
        } else {
            suffix = "am"
        }
        hours = (((hours+12)-1)%12)+1
        /*hours = (hours + 12) - 1
         int hrs = (int) hours % 12
         hrs += 1*/
        if (noSuffix == false) {
            if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
                result = "0\(hours):0\((minutes)) \(suffix)"
            } else if ((hours >= 0 && hours <= 9)) {
                result = "0\(hours):\((minutes)) \(suffix)"
            } else if ((minutes >= 0 && minutes <= 9)) {
                result = "\(hours):0\((minutes)) \(suffix)"
            } else {
                result = "\(hours):\((minutes)) \(suffix)"
            }
            
        } else {
            if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
                result = "0\(hours):0\((minutes))"
            } else if ((hours >= 0 && hours <= 9)) {
                result = "0\(hours):\((minutes))"
            } else if ((minutes >= 0 && minutes <= 9)) {
                result = "\(hours):0\((minutes))"
            } else {
                result = "\(hours):\((minutes))"
            }
        }
        return result
        
    }
    
    // convert double hours to 12h format with no suffix
    func floatToTime12NS(time: Double) -> String{
        return floatToTime12(time: time, noSuffix: true)
    }
    
    // ---------------------- Compute Prayer Times -----------------------
    // compute prayer times at given julian date
    func computeTimes(times: [Double]) -> [Double] {
        
        let t = dayPortion(times: times)
        let parm: [Double] = methodParams[caculationMethod]!
        let Fajr = computeTime(G: 180 - parm[0], t: t[0])
        
        let Sunrise = computeTime(G: 180 - 0.833, t: t[1])
        
        let Dhuhr = computeMidDay(t: t[2])
        let Asr = computeAsr(step: 1.0 + Double(asrJuristic.rawValue), t: t[3])
        let Sunset = computeTime(G: 0.833, t: t[4])
        
        let Maghrib = computeTime(G: parm[2],t: t[5])
        let Isha = computeTime(G: parm[4], t: t[6])
        
        let CTimes: [Double] = [Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha]
        
        return CTimes
        
    }
    // compute prayer times at given julian date
    func computeDayTimes() -> Set<String> {
        var times: [Double] = [5, 6, 12, 13, 18, 18, 18] // default times
        for _ in 1...numIterations{
            times = computeTimes(times: times)
        }
        times = adjustTimes(times: times)
        times = tuneTimes(times: times)
        return adjustTimesFormat(times: times)
    }
    
    // adjust times in a prayer time array
    func adjustTimes(times: [Double]) -> [Double] {
        
        var aTime : [Double] = []
        for i in 0..<times.count {
            let element = times[i] + timeZone - lng / 15
            aTime.append(element)
        }
        
        let parm = methodParams[caculationMethod]!
        
        aTime[2] = aTime[2] + Double(dhuhrMinutes) / 60 // Dhuhr
        if (parm[1] == 1) // Maghrib
        {
            aTime[5] = aTime[4] + parm[2]/60
        }
        if (parm[3] == 1) // Isha
        {
            aTime[6] = aTime[5] + parm[4]/60
        }
        
        if (adjustHighLats != .None) {
            aTime = adjustHighLatTimes(timesParamter: aTime)
        }
        
        return aTime
    }
    
    // convert times array to given time format
    func adjustTimesFormat(times: [Double]) -> Set<String> {
        
        var result = Set<String>()
        
        if (timeFormat == .Floating) {
            for time in times {
                result.insert(String(time))
            }
            return result
        }
        
        for i in 0 ... 6{
            if (timeFormat == .Time12) {
                result.insert(floatToTime12(time: times[i], noSuffix: false))
            } else if (timeFormat == .Time12NS) {
                result.insert(floatToTime12(time: times[i], noSuffix: true))
            } else {
                result.insert(floatToTime24(time: times[i]))
            }
        }
        return result
    }
    
    // adjust Fajr, Isha and Maghrib for locations in higher latitudes
    func adjustHighLatTimes(timesParamter: [Double]) -> [Double]{
        var times = timesParamter;
        let nightTime = timeDiff(time1: times[4], time2: times[1]) // sunset to sunrise
        
        // Adjust Fajr
        let parm = methodParams[caculationMethod]!
        let FajrDiff = nightPortion(angle: parm[0]) * nightTime
        
        if (times[0].isNaN || timeDiff(time1: times[0], time2: times[1]) > FajrDiff) {
            times[0] = times[1] - FajrDiff
        }
        
        // Adjust Isha
        let IshaAngle = (parm[3] == 0) ? parm[4] : 18
        let IshaDiff = nightPortion(angle: IshaAngle) * nightTime
        if (times[6].isNaN || timeDiff(time1: times[4], time2: times[6]) > IshaDiff) {
            times[6] = times[4] + IshaDiff
        }
        
        // Adjust Maghrib
        let MaghribAngle = (parm[1] == 0) ? parm[2] : 4
        let MaghribDiff = nightPortion(angle: MaghribAngle) * nightTime
        if (times[5].isNaN || timeDiff(time1: times[4], time2: times[5]) > MaghribDiff) {
            times[5] = times[4] + MaghribDiff
        }
        
        return times
    }
    // the night portion used for adjusting times in higher latitudes
    func nightPortion(angle: Double) -> Double {
        var calc : Double = 0.0
        if (adjustHighLats == .AngleBased){
            calc = (angle)/60.0
        }else if (adjustHighLats == .MidNight){
            calc = 0.5
        }else if (adjustHighLats == .OneSeventh){
            calc = 0.14286
        }
        return calc
    }
    
    // convert hours to day portions
    func dayPortion(times: [Double]) -> [Double] {
        
        var timeAdjesment : [Double] = []
        for i in 0..<times.count {
            timeAdjesment.append(times[i] / 24)
        }
        return timeAdjesment
    }
    
    // Tune timings for adjustments
    // Set time offsets
    func tune(offsetTimes: [Double]) {
        
        for i in 0...offsets.count{ // offsetTimes length
            // should be 7 in order
            // of Fajr, Sunrise,
            // Dhuhr, Asr, Sunset,
            // Maghrib, Isha
            offsets[i] = offsetTimes[i]
            
        }
        
    }
    
    public func tuneTimes(times: [Double]) -> [Double] {
        
        var aTimes : [Double] = []
        for i in 0..<times.count {
            aTimes.append(times[i]+offsets[i]/60.0)
        }
        
        return aTimes
    }
    
    
    
}







extension Double {
    // ---------------------- Trigonometric Functions -----------------------
    // range reduce angle in degrees.
    static func fixAngle(a: Double) -> Double {
        
        let reduceAngle = a - (360 * (floor(a / 360.0)))
        let angle = reduceAngle < 0 ? (reduceAngle + 360) : reduceAngle
        
        return angle
    }
    
    // range reduce hours to 0..23
    static func fixHour(a: Double) -> Double {
        
        let reduceHour = a - 24.0 * floor(a / 24.0)
        let fixHour = reduceHour < 0 ? (reduceHour + 24) : reduceHour
        
        return fixHour
    }
    
    // radian to degree
    static func radiansToDegrees(alpha: Double) -> Double {
        return ((alpha * 180.0) / Double.pi)
    }
    
    // deree to radian
    static func degreesToRadians(alpha: Double) -> Double {
        return ((alpha * Double.pi) / 180.0)
    }
    
    // degree sin
    static func dSin(d: Double) -> Double {
        return (sin(degreesToRadians(alpha: d)))
    }
    
    // degree cos
    static func dCos(d: Double) -> Double {
        return (cos(degreesToRadians(alpha: d)))
    }
    
    // degree tan
    static func dTan(d:Double) -> Double {
        return (tan(degreesToRadians(alpha: d)))
    }
    
    // degree arcsin
    static func dArcSin(x: Double) -> Double {
        return radiansToDegrees(alpha: asin(x))
    }
    
    // degree arccos
    static func dArcCos(x: Double) -> Double {
        return radiansToDegrees(alpha: acos(x))
    }
    
    // degree arctan
    static func dArcTan(x: Double) -> Double {
        return radiansToDegrees(alpha: atan(x))
    }
    
    // degree arctan2
    static func dArcTan2(y: Double, x: Double) -> Double {
        return radiansToDegrees(alpha: atan2(y, x))
    }
    
    // degree arccot
    static func dArcCot(x: Double) -> Double{
        return radiansToDegrees(alpha: atan2(1.0, x))
    }
}
