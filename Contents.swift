import PlaygroundSupport
import SpriteKit

let view = SKView(frame: CGRect(x:0 , y:0, width: 380, height: 640))
let hourglass = HourglassScene(size: view.frame.size)
hourglass.scaleMode = .aspectFit
/*:
 ## The Hourglass ⏳ and Time Converter ⏱
 On this playground, you can have fun with **Time**! It works in two ways, as an **Hourglass** where you can see the time passing by and understand how seconds, minutes, hours, days, months and years are related, and as a **Time Converter** where you can tap inside any hourglass to add time and get to know how many seconds are in one year for example.
 */
/*:
 ### Behavior
 - Hourglass⏳: Adjust the time mode and choose: `.realTime` to see how time really works and how slow it can be. Choose between `.byMinutes`, `.byHours`, `.byDays`, `.byMonths` and `.byYears` to see time in another perspective (and if you cannot wait for a whole year to see all the hourglasses full).
 
 - Time Converter⏱: Change the time mode to `.tapToAdd` and tap inside any hourglass to add time and see how many time will be added to the others hourglasses. You can see how many minutes are in one month or try to tap your age and get to know how many hours have you lived so far 😱. (The Hourglasses are automatically refreshed once you add time again)

 */

hourglass.timeMode = .realTime

/*:
 ### Footnotes
 All hourglasses get full with a certain amount of time inside it, this amount is related with the next hourglass in time.
 - Seconds Hourglass: 60 (1 minute)
 - Minutes Hourglass: 60 (1 hour)
 - Hours Hourglass: 24 (1 day)
 - Days Hourglass: 30 (1 month = 30.4166666667 days)
 - Months Hourglass: 12 (1 year)
 - Year Hourglass: 1
 * * * * *
 All values of time are shown as an integer so on the Time Converter if you add 16 months it will be shown as 1 year, not 1.33 years.
 */

view.presentScene(hourglass)
PlaygroundSupport.PlaygroundPage.current.liveView = view
