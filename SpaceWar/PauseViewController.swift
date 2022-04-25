//
//  PauseViewController.swift
//  SpaceWar
//
//  Created by Vitaly Khryapin on 03.04.2022.
//

import UIKit

protocol PauseVCDelegate {
    func pauseViewControllerPlayButton(_ viewController: PauseViewController)
    func pauseViewControllerSoundButton(_ viewController: PauseViewController)
    func pauseViewControllerMusicButton(_ viewController: PauseViewController)
}

class PauseViewController: UIViewController {

    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    var delegate: PauseVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func playButtonPress(_ sender: UIButton) {
        delegate.pauseViewControllerPlayButton(self)
    }
    
    @IBAction func storeButtonPress(_ sender: UIButton) {
    }
    
    @IBAction func menuButtonPress(_ sender: UIButton) {
    }
    @IBAction func soundButtonPress(_ sender: UIButton) {
        delegate.pauseViewControllerSoundButton(self)
    }
    
    @IBAction func musicButtonPress(_ sender: UIButton) {
        delegate.pauseViewControllerMusicButton(self)
    }
    
}
