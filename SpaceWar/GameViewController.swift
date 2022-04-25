//
//  GameViewController.swift
//  SpaceWar
//
//  Created by Vitaly Khryapin on 02.04.2022.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
   

    var gameScene: GameScene!
    var pauseViewController: PauseViewController!
    var gameOverVC: GameOverViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseViewController = storyboard?.instantiateViewController(identifier: "PauseViewController") as? PauseViewController
        
        gameOverVC = storyboard?.instantiateViewController(identifier: "GameOverViewController") as? GameOverViewController
        
        pauseViewController.delegate = self
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                gameScene = scene as? GameScene
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func showPauseScreen(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        
        viewController.view.alpha = 0
        UIView.animate(withDuration: 0.5) {
            viewController.view.alpha = 1
        }
    }
    
    func hidePauseScreen(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        
        viewController.view.alpha = 1
        UIView.animate(withDuration: 0.5) {
            viewController.view.alpha = 0
        } completion: { comleted in
            viewController.view.removeFromSuperview()
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        gameScene.pauseTheGame()
        showPauseScreen(pauseViewController)
    }
}

extension GameViewController: PauseVCDelegate {
    func pauseViewControllerSoundButton(_ viewController: PauseViewController) {
        gameScene.soundOn = !gameScene.soundOn
        gameScene.soundOnOrOff()
        let image = gameScene.soundOn ? UIImage(named: "on") : UIImage(named: "off")
        viewController.soundButton.setImage(image, for: .normal)
    }
    
    func pauseViewControllerMusicButton(_ viewController: PauseViewController) {
        gameScene.musicOn = !gameScene.musicOn
        gameScene.musicOnOrOff()
        let image = gameScene.musicOn ? UIImage(named: "on") : UIImage(named: "off")
        viewController.musicButton.setImage(image, for: .normal)
    }
    
    func pauseViewControllerPlayButton(_ viewController: PauseViewController) {
        hidePauseScreen(viewController: pauseViewController)
        gameScene.unpausedTheGame()
    }
}
