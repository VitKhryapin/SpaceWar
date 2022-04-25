//
//  GameScene.swift
//  SpaceWar
//
//  Created by Vitaly Khryapin on 02.04.2022.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let spaceShipCategory: UInt32 = 0x1 << 0
    let asteroidCategory: UInt32 = 0x1 << 1
    
    //1  Создаем node
    var spaceShip: SKSpriteNode!
    var score = 0
    var scoreLabel: SKLabelNode!
    var spaceBackground: SKSpriteNode!
    var asteroidLayer: SKNode!
    var starsLayer: SKNode!
    var gameIsPause: Bool = false
    var spaceShipLayer: SKNode!
    var musicPlayer: AVAudioPlayer!
    var damagePlayer: AVAudioPlayer!
    var musicOn = true
    var soundOn = true
    //let hitSoundAction = SKAction.playSoundFileNamed("damage", waitForCompletion: true)
    
    func musicOnOrOff() {
        if musicOn {
            musicPlayer.play()
        } else {
            musicPlayer.stop()
        }
    }
    
    func soundOnOrOff() {
        if soundOn {
            damagePlayer.play()
        } else {
            damagePlayer.stop()
        }
    }
    
   
    
    func pauseTheGame() {
        gameIsPause = true
        self.asteroidLayer.isPaused = true
        physicsWorld.speed = 0
        starsLayer.isPaused = true
        musicOnOrOff()
        soundOnOrOff()
    }
    
    func unpausedTheGame() {
        gameIsPause = false
        self.asteroidLayer.isPaused = false
        physicsWorld.speed = 1
        starsLayer.isPaused = false
        musicOnOrOff()
        soundOnOrOff()
    }
    
    func resetTheGame() {
        score = 0
        scoreLabel.text = "Score: \(score)"
        gameIsPause = false
        self.asteroidLayer.isPaused = false
        physicsWorld.speed = 1
        
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8)
        
        scene?.size = UIScreen.main.bounds.size
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        spaceBackground = SKSpriteNode(imageNamed: "spaceBackground")
        spaceBackground.size = CGSize(width: width + 50, height: height + 50)
        addChild(spaceBackground)
        
        //stars
        let starPath = Bundle.main.path(forResource: "Stars", ofType: "sks")
        let starsEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: starPath!) as? SKEmitterNode
        starsEmitter?.position = CGPoint(x: frame.midX, y: frame.height / 2)
        starsEmitter?.particlePositionRange.dx = frame.width
        starsEmitter?.advanceSimulationTime(10)
        starsLayer = SKNode()
        starsEmitter?.zPosition = 1
        addChild(starsLayer)
        starsLayer.addChild(starsEmitter!)
        //2 init node
        spaceShip = SKSpriteNode(imageNamed: "spaceShip")
        spaceShip.xScale = 0.25
        spaceShip.yScale = 0.25
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false
        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory
        
        let colorAction1 = SKAction.colorize(with: .systemBlue, colorBlendFactor: 1, duration: 1)
        let colorAction2 = SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 1)
        
        let colorSequenceAnimatotion = SKAction.sequence([colorAction1, colorAction2])
        let colorActionRepeate = SKAction.repeatForever(colorSequenceAnimatotion)
        spaceShip.run(colorActionRepeate)
        //addChild(spaceShip)
        
        //создаем слой для корабля и огня
        spaceShipLayer = SKNode()
        spaceShipLayer.addChild(spaceShip)
        spaceShipLayer.zPosition = 3
        spaceShip.zPosition = 1
        spaceShipLayer.position = CGPoint(x: frame.midX, y: -frame.height / 4)
        addChild(spaceShipLayer)
        //создаем огонь
        let firePath = Bundle.main.path(forResource: "Fire", ofType: "sks")
        let fireEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: firePath!) as? SKEmitterNode
        fireEmitter?.zPosition = 0
        fireEmitter?.position.y = -40
        fireEmitter?.targetNode = self
        spaceShipLayer.addChild(fireEmitter!)
        
        //create asteroid
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 2
        addChild(asteroidLayer)
        
        let asteroidCreate = SKAction.run {
            let asteroid = self.createAsteroid()
            self.asteroidLayer.addChild(asteroid)
            asteroid.zPosition = 2
        }
        let asteroidPerSecond: Double = 2
        let asteriodCreationDelay = SKAction.wait(forDuration: 1.0 / asteroidPerSecond, withRange: 0.5)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreate, asteriodCreationDelay])
        let asteroidRunAction = SKAction.repeatForever(asteroidSequenceAction)
        self.asteroidLayer.run(asteroidRunAction)
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: frame.size.width  / scoreLabel.frame.size.width, y: scoreLabel.frame.size.height + 180)
        addChild(scoreLabel)
        spaceBackground.zPosition = 0
        scoreLabel.zPosition = 3
        
        playMusic()
        playSound()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameIsPause {
            if let touch = touches.first {
                //3 определяем точку прикосновения
                let touchLocation = touch.location(in: self)
                let distance = distanceCalc(a: spaceShip.position, b: touchLocation)
                let speed: CGFloat = 500
                let time = timeToInterval(distance: distance, speed: speed)
                let moveAction = SKAction.move(to: touchLocation, duration: time)
                moveAction.timingMode = SKActionTimingMode.easeInEaseOut
                spaceShipLayer.run(moveAction)
                let bgMoveAction = SKAction.move(to: CGPoint(x: -touchLocation.x / 100, y: -touchLocation.y / 100), duration: time)
                spaceBackground.run(bgMoveAction)

            }
        }
    }
    
    func distanceCalc(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x-a.x)*(b.x-a.x)+(b.y-a.y)*(b.y-a.y))
    }
    
    func timeToInterval(distance: CGFloat, speed: CGFloat) -> TimeInterval {
        let time = distance / speed
        return TimeInterval(time)
    }
    
    func  createAsteroid() -> SKSpriteNode {
        let asteriod = SKSpriteNode(imageNamed: "asteroid")
        asteriod.position.x = CGFloat.random(in: -(view?.bounds.width)!/2...(view?.bounds.width)!/2)
        asteriod.position.y = frame.size.height - asteriod.frame.size.height + 100
        let sizeAsteroid = CGFloat.random(in: 10...50)
        asteriod.size = CGSize(width: sizeAsteroid, height: sizeAsteroid)
        asteriod.physicsBody = SKPhysicsBody(texture: asteriod.texture!, size: asteriod.size)
        asteriod.name = "asteriod"
        asteriod.physicsBody?.categoryBitMask = asteroidCategory
        asteriod.physicsBody?.collisionBitMask = spaceShipCategory | asteroidCategory
        asteriod.physicsBody?.contactTestBitMask = spaceShipCategory
        
        let asteroidSpeedX: CGFloat = 100
        asteriod.physicsBody?.angularVelocity = CGFloat(drand48() * 2 - 1) * 3
        asteriod.physicsBody?.velocity.dx = CGFloat(drand48() * 2 - 1) * asteroidSpeedX
        return asteriod
    }
    
    override func update(_ currentTime: TimeInterval) {
//        let asteroid = createAsteroid()
//        addChild(asteroid)
    }
    
    override func didSimulatePhysics() {
        asteroidLayer.enumerateChildNodes(withName: "asteriod") { asteroid, stop in
            let heightUIScreen = UIScreen.main.bounds.height + 100
            if asteroid.position.y < -heightUIScreen {
                asteroid.removeFromParent()
                self.score += 1
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
    }
    
    func playMusic() {
        if let musicPath = Bundle.main.url(forResource: "titlesound", withExtension: "mp3") {
            musicPlayer = try! AVAudioPlayer(contentsOf: musicPath, fileTypeHint: nil)
            musicOnOrOff()
        }
        musicPlayer.numberOfLoops = -1
        musicPlayer.volume = 0.2
    }
    
    func playSound() {
        if let soundPath = Bundle.main.url(forResource: "damage", withExtension: "mp3") {
            damagePlayer = try! AVAudioPlayer(contentsOf: soundPath, fileTypeHint: nil)
            soundOnOrOff()
        }
        damagePlayer.numberOfLoops = 1
        damagePlayer.volume = 0.2
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyB.categoryBitMask == spaceShipCategory && contact.bodyA.categoryBitMask == asteroidCategory {
            self.score = 0
            self.scoreLabel.text = "Score: \(self.score)"
        }
        soundOnOrOff()
    }
    
    
    
}
