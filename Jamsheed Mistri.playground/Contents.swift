import SpriteKit
import PlaygroundSupport

/* WHAT IS THIS? - This is a program that I built as a submission for scholarship to WWDC 2017. It is made for Swift playgrounds and optimized for a device being held vertically, such as an iPhone.
 
 Though it is simple, it represents the many challenges that face people in life. The square represents a person who has a lot of potential to be successful in life, and the rectangles represent obstacles in the person's life. It may seem like it may take a long time to overcome all of the obstacles -- it may even look like it will not happen at all -- but in the end, all obstacles are overcome, and it is a satisfying achievement.
 
 I relate this to my strive to get a scholarship for WWDC - hopefully the all of the struggle will be worth it.
 
 Thanks for reading! If you are here for the code, I made it open source and left comments through it so that anyone can learn from it. It's all written in Swift 3.1 and designed for Swift Playgrounds for Mac or iPad. Enjoy! */


// Variable that will later be used to check if we have completed the round
var amountOfObstacles = 0

class Scene: SKScene, SKPhysicsContactDelegate {
    
    // Basic setup
    struct bitMask {
        static let bitMaskSquare: UInt32 = 0b1 << 0
        static let bitMaskObstacle: UInt32 = 0b1 << 1
    }
    
    // Set up all of the sounds that will be played
    var halfPlayer = SKAction.playSoundFileNamed("half.wav", waitForCompletion: false)
    var fullPlayer = SKAction.playSoundFileNamed("full.wav", waitForCompletion: false)
    var textPlayer = SKAction.playSoundFileNamed("text.mp3", waitForCompletion: false)
    var wwdcPlayer = SKAction.playSoundFileNamed("wwdc.wav", waitForCompletion: false)
    var startPlayer = SKAction.playSoundFileNamed("start.wav", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        // Play beginning sound
        self.run(self.startPlayer)
        
        // Set screen dimensions
        self.size = CGSize(width: 1080, height: 1920)
        
        // Set background color
        self.backgroundColor = UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1.0)
        
        // Set up walls
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        let wall = SKPhysicsBody(edgeLoopFrom: self.frame)
        wall.friction = 0
        wall.restitution = 1
        self.physicsBody = wall
        
        // Set up square
        let square = SKSpriteNode(color: SKColor(red: 0.909, green: 0.314, blue: 0.25, alpha: 1), size: CGSize(width: 50, height: 50))
        square.physicsBody = SKPhysicsBody(rectangleOf: square.size)
        square.physicsBody!.allowsRotation = false
        square.physicsBody!.categoryBitMask = bitMask.bitMaskSquare
        square.physicsBody!.contactTestBitMask = bitMask.bitMaskObstacle
        square.physicsBody!.friction = 0
        square.physicsBody!.linearDamping = 0
        square.physicsBody!.restitution = 1
        square.physicsBody!.velocity = CGVector(dx: 1500, dy: 1500)
        square.position = CGPoint(x: 0.5 * self.size.width, y: 0.5 * self.size.height)
        self.addChild(square)
        
        // Set up obstacle
        let obstacle = SKSpriteNode(color: SKColor(red: 0.235, green: 0.235, blue: 0.235, alpha: 1), size: CGSize(width: 150, height: 50))
        obstacle.name = "obstacle"
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody!.categoryBitMask = bitMask.bitMaskObstacle
        obstacle.physicsBody!.isDynamic = false
        obstacle.physicsBody!.friction = 0
        obstacle.physicsBody!.restitution = 1
        
        // Print all the obstacles out programatically
        for rows in 1...3 {
            for columns in 1...5 {
                let i = obstacle.copy() as! SKSpriteNode
                i.position = CGPoint(x: (i.size.width + 27.5) * CGFloat(columns), y: frame.size.height - ((i.size.height + 27.5) * CGFloat(rows)))
                self.addChild(i)
                
                amountOfObstacles += 1
            }
        }
    }
    
    // Check for collision
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == bitMask.bitMaskSquare && contact.bodyB.categoryBitMask == bitMask.bitMaskObstacle {
            let obstacle = contact.bodyB.node as! SKSpriteNode
            
            if obstacle.name == "obstacle" {
                obstacle.color = SKColor(red: 0.235, green: 0.235, blue: 0.235, alpha: 0.25)
                obstacle.name = "half-obstacle"
                self.run(self.halfPlayer)
            }
                
            else {
                obstacle.removeFromParent()
                self.run(self.fullPlayer)
                amountOfObstacles -= 1
                if amountOfObstacles == 0 {
                    self.run(self.textPlayer)
                    let text = SKSpriteNode(imageNamed: "text")
                    text.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2 + 200)
                    addChild(text)
                    
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.run(self.wwdcPlayer)
                        let wwdc = SKSpriteNode(imageNamed: "wwdc")
                        wwdc.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 200)
                        self.addChild(wwdc)
                    }
                }
            }
        }
    }
}

// Start it up!
let scene = Scene()
scene.scaleMode = .aspectFit
let view = SKView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
view.presentScene(scene)
PlaygroundPage.current.liveView = view
