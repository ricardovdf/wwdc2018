//  HourglassBrain.swift
//  WWDC18
//  Created by Ricardo V Del Frari
//
//  This class is the Model of our project is responsable for the setup and update of the hourglass. The instances of this class will be seconds, minutes, hours, days, months and years hourglass.

import SpriteKit

public class HourglassBrain: SKNode {
    
    //MARK: Properties
    //timeNode is the node that goes inside the hourglass
    private var timeNode : SKShapeNode?
    private var boxOfHourglass : SKShapeNode?
    private var nodeName: TimeNames!
    
    //The quantity of nodes that fit inside the hourglass
    private var numberOfNodes: Int = 0
    //The seconds that represent the time value of the hourglass. Ex. 1 minute = 60 seconds.
    private var secondsInTime: Int = 0
    //The seconds of the next hourglass. Ex. On the minute hourglass, next hourglass will be hours.
    private var secondsInNextTime: Int = 0
    
    private var nodeColor: UIColor!
    //Color to blink when the hourglass is full of nodes, representing the next hourglass time.
    private var colorToAnimate: UIColor!
    
    //An array to keep the time nodes that have been added to the hourglass
    private var nodesArray = [SKNode]()
    
    //MARK: Init
    init(_ nodeName: TimeNames, withBody body: SKShapeNode, andTimeNode timeNode: SKShapeNode) {
        super.init()
        
        self.timeNode = timeNode
        self.boxOfHourglass = body
        self.nodeName = nodeName
        
        setupConstants()
        self.addChild(boxOfHourglass!)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Update
    public func update() {
        //If the time in seconds is equal the value of time in seconds of this hourglass and the mode is not .tapToAdd a node of time should be added to the hourglass.
        if HourglassScene.shared.timeToShare == secondsInTime && HourglassScene.shared.timeMode != TimeMode.tapToAdd{
            
            //Call the function that add a node inside the hourglass
            self.addNode(self.timeNode!, withName: nodeName.rawValue, andColor: self.nodeColor , at: (self.boxOfHourglass?.position)!)
            
            //If the number of nodes inside the hourglass is equal the number of nodes that fit inside it, the hourglass is consider as full and some actions should be trigger
            if nodesArray.count == numberOfNodes {
                
                //Animate the hourglass box to blink with the color of the next hourglass in time
                self.boxOfHourglass?.run(SKAction.customAction(withDuration: 0.5, actionBlock: { (node, elapsedTime) in
                    (node as! SKShapeNode).strokeColor = self.colorToAnimate
                    if elapsedTime > 0.4 {
                        (node as! SKShapeNode).strokeColor = self.nodeColor
                    }
                }))
                
                //Change the 'timeToShare' to update the next hourglass in time.
                HourglassScene.shared.timeToShare = self.secondsInNextTime
                
            }else if nodesArray.count > numberOfNodes {
                //If the number of time nodes of the hourglass is bigger that the nodes that fit inside it, all nodes should be removed and a new node add. This happens when the hourglass get full and the next hourglass is not. So when minutes get to 60, we add 1 to hour, remove all from minutes and keep counting minutes.
                
                self.removeChildren(in: self.nodesArray)
                self.nodesArray.removeAll()
                
                self.addNode(self.timeNode!, withName: nodeName.rawValue, andColor: self.nodeColor , at: (self.boxOfHourglass?.position)!)
            }
        }
    }
    
    //MARK: Update to Animate
    //The updateToAnimate() method makes the hourglass get full when the time in seconds is bigger than the sum time of all nodes that could go inside of this hourglass.
    public func updateToAnimate() {
        
        if HourglassScene.shared.timeMode == TimeMode.tapToAdd {
            
            //When time mode is '.tapToAdd' check if the time is smaller or equal than the full time of the hourglass. Ex. The full time of the seconds hourglass is 60 seconds. 1 second x 60 nodes.
            if HourglassScene.shared.timeToShare <= secondsInTime * numberOfNodes {
                
                //Calculate the number of nodes to add inside the hourglass based on the total time. Ex. if the total time is 120 seconds, we need to add 2 nodes of time inside the seconds hourglass.
                let numberOfNodesToAdd = HourglassScene.shared.timeToShare/secondsInTime
                
                //Add one node of time on each update cycle, to create an animation of filling up the hourglass.
                if nodesArray.count < numberOfNodesToAdd {
                    self.addNode(self.timeNode!, withName: nodeName.rawValue, andColor: self.nodeColor , at: (self.boxOfHourglass?.position)!)
                }
                
                //Get out of the updateToAnimate, on the contrary the next 'if' will fill up the hourglass
                return
            }
        }
        
        //Add nodes to fill up the hourglass when the 'timeToShare' is bigger than the time in seconds of this hourglass.
        //Add one node of time on each update cycle, to create an animation of filling up the hourglass.
        if HourglassScene.shared.timeToShare > secondsInTime {
            if nodesArray.count < numberOfNodes {
                self.addNode(self.timeNode!, withName: nodeName.rawValue, andColor: self.nodeColor , at: (self.boxOfHourglass?.position)!)
            }
        }
    }
    
    func removeAllTimeNodes() {
        self.removeChildren(in: self.nodesArray)
        nodesArray.removeAll()
    }
    
    //MARK: Add Nodes
    //Add a node inside the hourglass
    public func addNode(_ node: SKShapeNode, withName name: String, andColor color: UIColor, at position: CGPoint) {
        let nodeToAdd = node.copy() as! SKShapeNode
        nodeToAdd.name = name
        nodeToAdd.strokeColor = color
        nodeToAdd.position = position
        nodesArray.append(nodeToAdd)
        self.addChild(nodeToAdd)
        //Animate the node of time with a impulse to make it "jump"
        nodeToAdd.physicsBody?.applyImpulse(CGVector(dx: 0.01, dy: 1.0))
    }
    
    //MARK: Setup
    // Setup all the values for the time to be used in the Brain Timer
    func setupConstants() {
        //Check the node name in order to setup properly
        switch nodeName {
        case .second:
            //NumberOfNodes is the number of nodes that will be added inside the time body. Ex: 60 nodes inside the second body, 12 nodes inside the month body...
            numberOfNodes = Int(NumberOfNodes.secondsAndMinutes.rawValue)
            
            //secondsInTime is the amount of seconds that the time have. Ex. One hour is made of 3600 seconds
            secondsInTime = SecondsIn.second.rawValue
            
            //secondsInNextTime is the amount of seconds that the next mesure of time have. In the case of seconds the next time is minutes, in case of month the next time is year
            secondsInNextTime = SecondsIn.minute.rawValue
            
            nodeColor = .secondsColor
            
            //The color of the next mesure of time, to blink and animate the case of time.
            colorToAnimate = .minutesColor
        case .minute:
            numberOfNodes = NumberOfNodes.secondsAndMinutes.rawValue
            secondsInTime = SecondsIn.minute.rawValue
            secondsInNextTime = SecondsIn.hour.rawValue
            nodeColor = .minutesColor
            colorToAnimate = .hoursColor
        case .hour:
            numberOfNodes = NumberOfNodes.hours.rawValue
            secondsInTime = SecondsIn.hour.rawValue
            secondsInNextTime = SecondsIn.day.rawValue
            nodeColor = .hoursColor
            colorToAnimate = .daysColor
        case .day:
            numberOfNodes = NumberOfNodes.days.rawValue
            secondsInTime = SecondsIn.day.rawValue
            secondsInNextTime = SecondsIn.month.rawValue
            nodeColor = .daysColor
            colorToAnimate = .monthsColor
        case .month:
            numberOfNodes = NumberOfNodes.months.rawValue
            secondsInTime = SecondsIn.month.rawValue
            secondsInNextTime = SecondsIn.year.rawValue
            nodeColor = .monthsColor
            colorToAnimate = .yearColor
        case .year:
            numberOfNodes = NumberOfNodes.years.rawValue
            secondsInTime = SecondsIn.year.rawValue
            secondsInNextTime = SecondsIn.year.rawValue
            nodeColor = .yearColor
            colorToAnimate = .yearColor
        default:
            fatalError("Attempt to add a node that does not exist")
        }
    }
    
}
