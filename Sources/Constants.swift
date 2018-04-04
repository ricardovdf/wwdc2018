//  Constants.swift
//  WWDC18
//  Created by Ricardo V Del Frari
//

import SpriteKit

//TimeMode enum to specify the different ways to interact with the hourglass
public enum TimeMode {
    case realTime, byMinutes, byHours, byDays, byMonths, byYears, tapToAdd
}

//SecondsIn enum to specify the values of Seconds in all time modes of the hourglass
public enum SecondsIn: Int {
    case second = 1
    case minute = 60
    case hour = 3600
    case day = 86400
    //One month = 30.4166666667 days
    case month = 2628000
    //One year = 365 days = 12 Months of 30.4166666667 days
    case year = 31536000
}

//NumberOfNodes enum specify the number of nodes that go inside every hourglass box
public enum NumberOfNodes: Int {
    case secondsAndMinutes = 60
    case hours = 24
    case days = 30
    case months = 12
    case years = 1
}

//TimeNames is an enum of all the times name strings, to use on the nodes names during instantiation
public enum TimeNames: String {
    case second = "second"
    case minute = "minute"
    case hour = "hour"
    case day = "day"
    case month = "month"
    case year = "year"
}

//Extension of UIColor specify the main color for all the different time nodes
extension UIColor {
    static var secondsColor: UIColor  { return #colorLiteral(red: 0.3215686275, green: 0.6156862745, blue: 0.2274509804, alpha: 1) }
    static var minutesColor: UIColor { return #colorLiteral(red: 0.8352941176, green: 0.6039215686, blue: 0.137254902, alpha: 1) }
    static var hoursColor: UIColor { return #colorLiteral(red: 0.8274509804, green: 0.4235294118, blue: 0.09019607843, alpha: 1) }
    static var daysColor: UIColor { return #colorLiteral(red: 0.7647058824, green: 0.1843137255, blue: 0.2078431373, alpha: 1) }
    static var monthsColor: UIColor { return #colorLiteral(red: 0.5058823529, green: 0.2, blue: 0.5176470588, alpha: 1) }
    static var yearColor: UIColor { return #colorLiteral(red: 0.02352941176, green: 0.5411764706, blue: 0.7764705882, alpha: 1) }
}
