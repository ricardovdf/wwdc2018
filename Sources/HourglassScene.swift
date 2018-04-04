//  HourglassScene.swift
//  WWDC18
//
//  Created by Ricardo V Del Frari on 20/03/2018.
//  Copyright © 2018 Ricardo V Del Frari. All rights reserved.
//

import SpriteKit

public class HourglassScene: SKScene {
    
    //MARK: Properties
    //Singleton to share the time between classes
    public static let shared = HourglassScene()
    
    //The mode that the playground will run
    public var timeMode: TimeMode = .realTime
    
    //To count the amount of time between each 'update()' call
    private var lastUpdateTime: TimeInterval = 0
    private var updateTimeValue: TimeInterval = 0
    
    //To store one real second, based on the 'update()' time
    private var oneSecond: TimeInterval = 0
    
    //Time to share between classes, this property will be used to update all hourglass. It is always in seconds
    public var timeToShare : Int = 0
    
    //The amount of time in seconds to update the labels and hourglasses
    private var secondsInHourglass = 0
    
    //The node that represents seconds and minutes and is add on the .tapToAdd mode
    private var secondsAndMinutesNode: SKShapeNode?
    
    //Create a size mesure based on the view size. To be used as the size of the Hourglass Box
    private var defaultSize : CGFloat = 0.0
    
    //The amount of seconds of each update second. If timeMode is .byMonths add 2628000 seconds every update.
    private var updateSecondsRate: Int = 0
    
    //SKShapeNode to create the Hourglass Boxes. Those are the rounded squares that hold the time node for all the kind os times in the project.
    private var secondsHBox: SKShapeNode?
    private var minutesHBox: SKShapeNode?
    private var hoursHBox: SKShapeNode?
    private var daysHBox: SKShapeNode?
    private var monthsHBox: SKShapeNode?
    private var yearsHBox: SKShapeNode?
    
    //Labels for the names and amount of time of each hourglass
    var secondsLabel: SKLabelNode?
    var secondsCounterLabel: SKLabelNode?
    var minutesLabel: SKLabelNode?
    var minutesCounterLabel: SKLabelNode?
    var hoursLabel: SKLabelNode?
    var hoursCounterLabel: SKLabelNode?
    var daysLabel: SKLabelNode?
    var daysCounterLabel: SKLabelNode?
    var monthsLabel: SKLabelNode?
    var monthsCounterLabel: SKLabelNode?
    var yearsLabel: SKLabelNode?
    var yearsCounterLabel: SKLabelNode?
    
    //The properties to instanciate the Model
    var secondsHourglass: HourglassBrain?
    var minutesHourglass: HourglassBrain?
    var hoursHourglass: HourglassBrain?
    var daysHourglass: HourglassBrain?
    var monthsHourglass: HourglassBrain?
    var yearsHourglass: HourglassBrain?
    
    //All variables related to the '.tapToAdd' more about them on 'touchDown(_:)'
    private var shouldStartCountdown = false
    private var lastAddNodeTime = 2.0
    private var secondsToCalculate = 0
    private var shouldUpdate = true
    
    //A number formatter that converts between numeric values and their textual representations
    private let formatter = NumberFormatter()
    
    //MARK: didMove()
    public override func didMove(to view: SKView) {
        
        //Set the backgroundColor of the view to black
        backgroundColor = SKColor.black
        
        //Set the number formatter to format numbers to show the decimal separator. A number like 100000 will be shown as 100,000 or 100.000 dependending on the region of the device (locale = .current).
        formatter.numberStyle = .decimal
        formatter.locale = NSLocale.current
        
        //Set the default size to be 10% of the view size width plus height, this way the size of hourglasses will adapt accordantly with the view size
        defaultSize = (self.size.width + self.size.height) * 0.1
        
        setupHourglassesBoxesAndTimeNodes()
        setupLabels()
        setupTimeMode()
    }
    
    //MARK: Setup Hourglass
    func setupHourglassesBoxesAndTimeNodes() {
        
        //Define the size of all Time nodes, to be use in the creation of their SKShapeNodes. Those sizes are setup to make the hourglass full with the maximum amount of nodes of each time. The seconds and minutes hourglass will be full with 60 nodes of the 'secondsAndMinutesNodeSize' size.
        let secondsAndMinutesNodeSize = defaultSize * 0.13
        let hoursNodeSize = defaultSize * 0.2
        //Days nodes are smaller than hours nodes because the hour hourglass should be full with 24 nodes, and the day hourglass with 30. The size is not related with the value in time of the nodes.
        let daysNodeSize = defaultSize * 0.18
        let monthsNodeSize = defaultSize * 0.28
        let yearsNodeSize = defaultSize * 0.8
        
        //The next lines setup all internal nodes of the respective hourglass, based on each size and physicsBody.
        //The 'secondsAndMinutesNode' will be used also on the '.tapToAdd' mode, for this reason it is declared as a global property of this class.
        secondsAndMinutesNode = SKShapeNode.init(circleOfRadius: secondsAndMinutesNodeSize/2)
        secondsAndMinutesNode?.physicsBody = SKPhysicsBody(circleOfRadius: secondsAndMinutesNodeSize/2)
        
        let hourNode = SKShapeNode.init(circleOfRadius: hoursNodeSize/2)
        hourNode.physicsBody = SKPhysicsBody(circleOfRadius: hoursNodeSize/2)
        
        let monthNode = SKShapeNode.init(circleOfRadius: monthsNodeSize/2)
        monthNode.physicsBody = SKPhysicsBody(circleOfRadius: monthsNodeSize/2)
        
        let dayNode = SKShapeNode.init(circleOfRadius: daysNodeSize/2)
        dayNode.physicsBody = SKPhysicsBody(circleOfRadius: daysNodeSize/2)
        
        let yearNode = SKShapeNode.init(circleOfRadius: yearsNodeSize/2)
        yearNode.physicsBody = SKPhysicsBody(circleOfRadius: yearsNodeSize/2)
        
        //The 'defaultHourglassBox' is the SKShapeNode body of all hourglasses, it is a square with round corners, is is the same shape of the SKShapeNode from the default SpriteKit Xcode project
        let defaultHourglassBox = SKShapeNode.init(rectOf: CGSize.init(width: defaultSize, height: defaultSize), cornerRadius: defaultSize * 0.3)
        defaultHourglassBox.physicsBody = SKPhysicsBody(edgeLoopFrom: defaultHourglassBox.path!)
        
        //All HBox are Hourglass Box bodyes, they use the 'defaultHourglassBox' as their shape and physics body. Each one has its on position based on the others hourglass and the size of the view. A restitution of 0.5 to make the time nodes bounce a bit when in contact with the hourglass box.
        //defaultHourglassBox has to be used as a copy(), on the contrary an error will be triger
        secondsHBox = defaultHourglassBox.copy() as? SKShapeNode
        secondsHBox?.position = CGPoint(x: self.size.width/3.5, y: self.size.height/2 + defaultSize * 1.5)
        secondsHBox?.physicsBody?.isDynamic = false
        secondsHBox?.physicsBody?.restitution = 0.5
        secondsHBox?.strokeColor = .secondsColor
        
        minutesHBox = defaultHourglassBox.copy() as? SKShapeNode
        minutesHBox?.position = CGPoint(x: (secondsHBox?.position.x)!, y: self.size.height/2)
        minutesHBox?.physicsBody?.isDynamic = false
        minutesHBox?.physicsBody?.restitution = 0.5
        minutesHBox?.strokeColor = .minutesColor
        
        hoursHBox = defaultHourglassBox.copy() as? SKShapeNode
        hoursHBox?.position = CGPoint(x: (minutesHBox?.position.x)! , y: (minutesHBox?.position.y)! - defaultSize * 1.5)
        hoursHBox?.physicsBody?.isDynamic = false
        hoursHBox?.physicsBody?.restitution = 0.5
        hoursHBox?.strokeColor = .hoursColor
        
        daysHBox = defaultHourglassBox.copy() as? SKShapeNode
        daysHBox?.position = CGPoint(x: self.size.width - self.size.width/3.5, y: (secondsHBox?.position.y)!)
        hoursHBox?.physicsBody?.isDynamic = false
        daysHBox?.physicsBody?.restitution = 0.5
        daysHBox?.strokeColor = .daysColor
        
        monthsHBox = defaultHourglassBox.copy() as? SKShapeNode
        monthsHBox?.position = CGPoint(x: (daysHBox?.position.x)!, y: (minutesHBox?.position.y)!)
        monthsHBox?.physicsBody?.isDynamic = false
        monthsHBox?.physicsBody?.restitution = 0.5
        monthsHBox?.strokeColor = .monthsColor
        
        yearsHBox = defaultHourglassBox.copy() as? SKShapeNode
        yearsHBox?.position = CGPoint(x: (daysHBox?.position.x)!, y: (hoursHBox?.position.y)!)
        yearsHBox?.physicsBody?.isDynamic = false
        yearsHBox?.physicsBody?.restitution = 0.5
        yearsHBox?.strokeColor = .yearColor
        
        //Here we instanciante all the Hourglass as HourglassBrain, the class responsable for update and do all math related to the hourglasses. We initialize them with a name, a body for the houglass box and a time node to go inside the hourglass.
        secondsHourglass = HourglassBrain(.second, withBody: secondsHBox!, andTimeNode: secondsAndMinutesNode!)
        self.addChild(secondsHourglass!)
        
        minutesHourglass = HourglassBrain(.minute, withBody: minutesHBox!, andTimeNode: secondsAndMinutesNode!)
        self.addChild(minutesHourglass!)
        
        hoursHourglass = HourglassBrain(.hour, withBody: hoursHBox!, andTimeNode: hourNode)
        self.addChild(hoursHourglass!)
        
        daysHourglass = HourglassBrain(.day, withBody: daysHBox!, andTimeNode: dayNode)
        self.addChild(daysHourglass!)
        
        monthsHourglass = HourglassBrain(.month, withBody: monthsHBox!, andTimeNode: monthNode)
        self.addChild(monthsHourglass!)
        
        yearsHourglass = HourglassBrain(.year, withBody: yearsHBox!, andTimeNode: yearNode)
        self.addChild(yearsHourglass!)
    }
    
    //MARK: Labels
    func setupLabels() {
        
        //Size to help on the positioning of labels
        let spaceForLabel = defaultSize * 0.12
        
        //Setup Seconds Label
        secondsLabel = createLabel(at: CGPoint(x: (secondsHBox?.position.x)! , y: (secondsHBox?.position.y)! - defaultSize/2 - spaceForLabel), withText: "SECONDS")
        self.addChild(secondsLabel!)
        
        //Setup Seconds Counter Label
        secondsCounterLabel = createLabel(at: CGPoint(x: (secondsLabel?.position.x)! , y: (secondsLabel?.position.y)! - spaceForLabel), withText: "0")
        self.addChild(secondsCounterLabel!)
        
        //Setup Minutes Label
        minutesLabel = createLabel(at: CGPoint(x: (minutesHBox?.position.x)! , y: (minutesHBox?.position.y)! - defaultSize/2 - spaceForLabel), withText: "MINUTES")
        self.addChild(minutesLabel!)
        
        //Setup Minutes Counter Label
        minutesCounterLabel = createLabel(at: CGPoint(x: (minutesLabel?.position.x)! , y: (minutesLabel?.position.y)! - spaceForLabel), withText: "0")
        self.addChild(minutesCounterLabel!)
        
        //Setup Hours Label
        hoursLabel = createLabel(at: CGPoint(x: (hoursHBox?.position.x)! , y: (hoursHBox?.position.y)! - defaultSize/2 - spaceForLabel), withText: "HOURS")
        self.addChild(hoursLabel!)
        
        //Setup Hours Counter Label
        hoursCounterLabel = createLabel(at: CGPoint(x: (hoursLabel?.position.x)! , y: (hoursLabel?.position.y)! - spaceForLabel), withText: "0")
        self.addChild(hoursCounterLabel!)
        
        //Setup Days Label
        daysLabel = createLabel(at: CGPoint(x: (daysHBox?.position.x)! , y: (daysHBox?.position.y)! - defaultSize/2 - spaceForLabel), withText: "DAYS")
        self.addChild(daysLabel!)
        
        //Setup Days Counter Label
        daysCounterLabel = createLabel(at: CGPoint(x: (daysLabel?.position.x)! , y: (daysLabel?.position.y)! - spaceForLabel), withText: "0")
        self.addChild(daysCounterLabel!)
        
        //Setup Months Label
        monthsLabel = createLabel(at: CGPoint(x: (monthsHBox?.position.x)! , y: (monthsHBox?.position.y)! - defaultSize/2 - spaceForLabel), withText: "MONTHS")
        self.addChild(monthsLabel!)
        
        //Setup Months Counter Label
        monthsCounterLabel = createLabel(at: CGPoint(x: (monthsLabel?.position.x)! , y: (monthsLabel?.position.y)! - spaceForLabel), withText: "0")
        self.addChild(monthsCounterLabel!)
        
        //Setup Years Label
        yearsLabel = createLabel(at: CGPoint(x: (yearsHBox?.position.x)! , y: (yearsHBox?.position.y)! - defaultSize/2 - spaceForLabel), withText: "YEARS")
        self.addChild(yearsLabel!)
        
        //Setup Years Counter Label
        yearsCounterLabel = createLabel(at: CGPoint(x: (yearsLabel?.position.x)! , y: (yearsLabel?.position.y)! - spaceForLabel), withText: "0")
        self.addChild(yearsCounterLabel!)
        
    }
    
    //This function is a helper method used to create all labels without having to write all the properties for each label again
    func createLabel(at position: CGPoint, withText text: String) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Helvetica")
        label.fontSize = defaultSize * 0.10
        label.fontColor = SKColor.white
        label.position = position
        label.text = text
        return label
    }
    
    //MARK: Touches
    func touchDown(atPoint pos: CGPoint) {
        //If the Hourglass mode is not tapToAdd, Ignore all touches
        if timeMode != .tapToAdd {
            return
        }
        
        //Add a new node on the touch position, to be use to calculate the amount of time
        if let nodeToAdd = self.secondsAndMinutesNode?.copy() as! SKShapeNode? {
            
            nodeToAdd.position = pos
            nodeToAdd.name = "addedByTap"
            self.addChild(nodeToAdd)
            
            //Remove all nodes inside the Hourglass, to do a new calculation of time
            removeAllTimeNodes()
            
            //The countdown timer, the amount of time will be calculate alway after 2 seconds from the last added node
            lastAddNodeTime = 2.0
            //Set the amount of seconds to be calculate to 0, in order to perform a new calculation
            secondsToCalculate = 0
            
            //Allows the countdown (to perform the calculation of time) to start
            shouldStartCountdown = true
            //The nodes should no be added in the hourglasses before the calculation of the time
            shouldUpdate = false
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    //Start the Countdown to perform the time calculation, after the last node of the tapToAdd mode being added
    func startCountdown() {
        //Subtract the time since the last update from the amount of time
        lastAddNodeTime -= updateTimeValue
        if lastAddNodeTime < 0 {
            //Call check Collisions after the contdown time is 0, to count the number of seconds and perform the final calculation of the time
            checkCollisions()
            shouldStartCountdown = false
        }
    }
    
    //MARK: Collisions
    //Check how many nodes are inside of each Hourglass and add the specific amout of seconds to be calculate
    func checkCollisions() {
        
        //Return all the nodes with the specified name, in this case all nodes added by touch
        enumerateChildNodes(withName: "addedByTap") {
            (node, _) in
            //Check how many nodes are inside the seconds hourglass and add 1 second for each to the final time do be calculate
            if node.intersects(self.secondsHBox!) {
                self.secondsToCalculate += SecondsIn.second.rawValue
            }
            //Check how many nodes are inside the minutes hourglass and add 60 seconds for each to the final time do be calculate
            if node.intersects(self.minutesHBox!) {
                self.secondsToCalculate += SecondsIn.minute.rawValue
            }
            //Check how many nodes are inside the hours hourglass and add 3600 seconds for each to the final time do be calculate
            if node.intersects(self.hoursHBox!) {
                self.secondsToCalculate += SecondsIn.hour.rawValue
            }
            //Check how many nodes are inside the days hourglass and add 86400 seconds for each to the final time do be calculate
            if node.intersects(self.daysHBox!) {
                self.secondsToCalculate += SecondsIn.day.rawValue
            }
            //Check how many nodes are inside the months hourglass and add 2628000 seconds for each to the final time do be calculate
            if node.intersects(self.monthsHBox!) {
                self.secondsToCalculate += SecondsIn.month.rawValue
            }
            //Check how many nodes are inside the year hourglass and add 31536000 seconds for each to the final time do be calculate
            if node.intersects(self.yearsHBox!) {
                self.secondsToCalculate += SecondsIn.year.rawValue
            }
            
            //After check the nodes, remove then from the hourglasses
            node.removeFromParent()
        }
        
        HourglassScene.shared.timeToShare = self.secondsToCalculate
        //After knowing the total amount of seconds to be calculated, the hourglasses should update with the nodes
        shouldUpdate = true
    }
    
    //MARK: Update
    public override func update(_ currentTime: TimeInterval) {
        
        if shouldStartCountdown {
            startCountdown()
        }
        
        //Count the amount of time between updates
        if lastUpdateTime > 0 {
            updateTimeValue = currentTime - lastUpdateTime
        } else {
            updateTimeValue = 0
        }
        
        lastUpdateTime = currentTime
        
        //Add the amount of time of each update loop to count 1 second
        oneSecond += updateTimeValue
        
        //Every 1 second update all hourglass
        if oneSecond >= 1 {
            
            //If 'timeMode' is '.tapToAdd' use the 'secondsToCalculate' amount of time, this will update the labels based on the amount of time of all nodes that was added by the user.
            if timeMode == .tapToAdd {
                secondsInHourglass = secondsToCalculate
            } else {
                //If 'timeMode' is not '.tapToAdd' use the 'updateSecondsRate' amount of time, this will update the labels and hourglass every second based on the amount of seconds of the time mode. Ex.: if time mode is '.byYears' every update second, 31536000 seconds will be added to the hourglass.
                secondsInHourglass += updateSecondsRate
            }
            
            //'update()' method will be called every second and will call all hourglass to add time nodes based on the 'timeToShare'. Once an hourglass if full, it will change the 'timeToShare' to start filling the next hourglass. Ex.: If 'timeToShare' is 60, every second the minutes hourglass will gain one time node, and after 60 seconds it will be the time of the hours hourglass start to gain time nodes.
            //More explanations about the 'update()' on the 'HourglassBrain' class.
            secondsHourglass?.update()
            self.secondsCounterLabel?.text = formatter.string(from: NSNumber(integerLiteral: secondsInHourglass))
            
            minutesHourglass?.update()
            self.minutesCounterLabel?.text = formatter.string(from: NSNumber(integerLiteral: secondsInHourglass/SecondsIn.minute.rawValue))
            
            hoursHourglass?.update()
            self.hoursCounterLabel?.text = formatter.string(from: NSNumber(integerLiteral: secondsInHourglass/SecondsIn.hour.rawValue))
            
            daysHourglass?.update()
            self.daysCounterLabel?.text = formatter.string(from: NSNumber(integerLiteral: secondsInHourglass/SecondsIn.day.rawValue))
            
            monthsHourglass?.update()
            self.monthsCounterLabel?.text = formatter.string(from: NSNumber(integerLiteral: secondsInHourglass/SecondsIn.month.rawValue))
            
            yearsHourglass?.update()
            self.yearsCounterLabel?.text = formatter.string(from: NSNumber(integerLiteral: secondsInHourglass/SecondsIn.year.rawValue))
            
            if timeMode != .tapToAdd {
                HourglassScene.shared.timeToShare = updateSecondsRate
            }
        }
        
        //If 'shouldUpdate' is true, update all hourglass to add the time nodes inside them.
        //'updateToAnimate()' method is used to add the time nodes inside their specific hourglass on every update cycle, it is used to complete the hourglass with the right amount of nodes.
        //When 'timeToShare' is bigger than the seconds of the node type, ex.: if the 'timeMode' is '.byHours' the 'timeToShare' will be higher than 'minutes' and 'seconds' so their hourglass should be full.
        if shouldUpdate {
            secondsHourglass?.updateToAnimate()
            minutesHourglass?.updateToAnimate()
            hoursHourglass?.updateToAnimate()
            daysHourglass?.updateToAnimate()
            monthsHourglass?.updateToAnimate()
            yearsHourglass?.updateToAnimate()
        }
        
        //Reset the oneSecond counter
        if oneSecond >= 1 {
            oneSecond = 0
        }
    }
    
    //Setup the update speed of nodes spawn and labels update. Based on the 'timeMode' set the 'updateSecondsRate' and the 'timeToShare'. If '.realTime', for example, every second add one second to the houglass. If '.byMinutes' every second add 60 seconds to the hourglass.
    func setupTimeMode() {
        switch timeMode {
        case .realTime:
            updateSecondsRate = SecondsIn.second.rawValue
            //'timeToShare' is a Singleton because we need only one instance of it to be shared for all hourglasses. The same is used for the 'timeMode'.
            HourglassScene.shared.timeToShare = SecondsIn.second.rawValue
            HourglassScene.shared.timeMode = .realTime
        case .byMinutes:
            updateSecondsRate = SecondsIn.minute.rawValue
            HourglassScene.shared.timeToShare = SecondsIn.minute.rawValue
            HourglassScene.shared.timeMode = .byMinutes
        case .byHours:
            updateSecondsRate = SecondsIn.hour.rawValue
            HourglassScene.shared.timeToShare = SecondsIn.hour.rawValue
            HourglassScene.shared.timeMode = .byHours
        case .byDays:
            updateSecondsRate = SecondsIn.day.rawValue
            HourglassScene.shared.timeToShare = SecondsIn.day.rawValue
            HourglassScene.shared.timeMode = .byDays
        case .byMonths:
            updateSecondsRate = SecondsIn.month.rawValue
            HourglassScene.shared.timeToShare = SecondsIn.month.rawValue
            HourglassScene.shared.timeMode = .byMonths
        case .byYears:
            updateSecondsRate = SecondsIn.year.rawValue
            HourglassScene.shared.timeToShare = SecondsIn.year.rawValue
            HourglassScene.shared.timeMode = .byYears
        case .tapToAdd:
            //'.tapToAdd' mode does not have a default value for 'updateSecondsRate' and 'timeToShare' because the time is calculated based on the number of nodes that are added inside the hourglasses by the user.
            updateSecondsRate = 0
            HourglassScene.shared.timeToShare = 0
            HourglassScene.shared.timeMode = .tapToAdd
        }
    }
    
    //Remove all nodes inside all hourglass, used to clean the hourglasses for a new tap on the touchToCalculate mode
    func removeAllTimeNodes() {
        secondsHourglass?.removeAllTimeNodes()
        minutesHourglass?.removeAllTimeNodes()
        hoursHourglass?.removeAllTimeNodes()
        daysHourglass?.removeAllTimeNodes()
        monthsHourglass?.removeAllTimeNodes()
        yearsHourglass?.removeAllTimeNodes()
    }
}
