//
//  GameScene.swift
//  HWS_Project_20
//
//  Created by Cory Tepper on 1/4/21.
//

import SpriteKit

class GameScene: SKScene {
    // MARK: Properties
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var launchesCompleted = 0
    
    
    // Where the fireworks are launched from
    let leftEdge = -22
    let bottomeEdge = -22
    let rightEdge = 1024 + 22
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
  
    // MARK: Scene Management
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        // Timer that lauches fireworks every 6 seconds
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    // remove unexploded fireworks from scene when out of frame
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    
    // MARK: Touch Management
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
         
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
            
            }
        
        }
    
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            checkTouches(touches)
        }
    
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesMoved(touches, with: event)
            checkTouches(touches)
        }
    
    
    // MARK: Helper Methods
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        // create an SKNode as fireworks container
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        // create a rocket sprite node, set name and colorBlendFactor, add to container
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        // Give the firework color
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }
        
        // create a UIBezierPath to represent the movement of the firework
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        //set the container node to follow the path
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        
        // create particles behind the node
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        // add the firework to the array and scene
        fireworks.append(node)
        addChild(node)
    }
    
        @objc func launchFireworks() {
            // call createFirework() to launch fireworks in pattens randomly
            let movementAmount: CGFloat = 1800
            
            switch Int.random(in: 0...3) {
            case 0:
                // fire five, straight up
                createFirework(xMovement: 0, x: 512, y: bottomeEdge)
                createFirework(xMovement: 0, x: 512 - 200, y: bottomeEdge)
                createFirework(xMovement: 0, x: 512 - 100, y: bottomeEdge)
                createFirework(xMovement: 0, x: 512 + 100, y: bottomeEdge)
                createFirework(xMovement: 0, x: 512 + 200, y: bottomeEdge)
            case 1:
                // fire five, in a fan
                createFirework(xMovement: 0, x: 512, y: bottomeEdge)
                createFirework(xMovement: -200, x: 512 - 200, y: bottomeEdge)
                createFirework(xMovement: -100, x: 512 - 100, y: bottomeEdge)
                createFirework(xMovement: +100, x: 512 + 100, y: bottomeEdge)
                createFirework(xMovement: +200, x: 512 + 200, y: bottomeEdge)
            case 2:
                // fire five, from the left to the right
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomeEdge + 400)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomeEdge + 300)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomeEdge + 200)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomeEdge + 100)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomeEdge)

            case 3:
                // fire five, from the right to the left
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomeEdge + 400)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomeEdge + 300)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomeEdge + 200)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomeEdge + 100)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomeEdge)
                
            default:
                break
            }
            
            launchesCompleted += 1
            if launchesCompleted == 5 {
                gameTimer?.invalidate()
            }
            
        }
    
    
   
   
    
    // Explode a single firework
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
        }
        
        
        firework.removeFromParent()
    }
    
    // Explode multiple fireworks
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }


}
    


    
    

