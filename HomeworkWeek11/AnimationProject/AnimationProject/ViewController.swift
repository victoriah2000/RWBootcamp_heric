//
//  ViewController.swift
//  AnimationProject
//
//  Created by Victoria Heric on 8/9/20.
//  Copyright © 2020 Victoria Heric. All rights reserved.
//

import UIKit


enum TargetAnimation {
  case color(UIColor)
  case size(CGFloat)
  case move(CGPoint)
  
  static func makeRandomColor() -> Self {
    let color: UIColor
    switch Int.random(in: 1...5) {
    case 1:
      color = .blue
    case 2:
      color = .yellow
    case 3:
      color = .red
    case 4:
      color = .green
    case 5:
      color = .purple
    default:
      fatalError()
    }
    return .color(color)
  }
  
  static func makeRandomSize() -> Self {
    .size(CGFloat.random(in: 30...200))
  }
  
  static func makeRandomMove() -> Self {
    .move(CGPoint(x: CGFloat.random(in: -100...100),
                  y:  CGFloat.random(in: -100...100) + 145))
  }
  
}


class ViewController: UIViewController {

  var isMenuCollapsed = true
  var animations: [TargetAnimation] = []
  let buttonDistance: CGFloat = 80
  
  func updateMenu() {
    if isMenuCollapsed {
      colorButtonConstraint.constant = 0
      sizeButtonContraint.constant = 0
      moveButtonConstraint.constant = 0
    } else {
      colorButtonConstraint.constant = buttonDistance
      sizeButtonContraint.constant = buttonDistance
      moveButtonConstraint.constant = buttonDistance
    }
  }
  
  func applyAnimations() {
    
    for animation in animations {
      switch animation {
        
      case .color(let color):
        targetView.backgroundColor = color
      case .size(let size):
        targetSizeConstraint.constant = size
      case .move(let point):
        targetXContraint.constant = point.x
        targetYConstraint.constant = point.y
      }
    }
    
    animations = []
  }
  
  func runAnimation() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
      self.updateMenu()
      self.view.layoutIfNeeded()
    }, completion: { finished in
      if self.isMenuCollapsed {
        UIView.animate(withDuration: 1) {
          self.applyAnimations()
          self.patternView.transform = self.patternView.transform.rotated(by: .pi)
          self.view.layoutIfNeeded()
        }
      }
    })
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    updateMenu()
    targetView.layer.borderColor = UIColor.orange.cgColor
    targetView.layer.borderWidth = 4    
  }

  @IBOutlet weak var targetView: UIView!
  @IBOutlet weak var targetSizeConstraint: NSLayoutConstraint!
  @IBOutlet weak var targetXContraint: NSLayoutConstraint!
  @IBOutlet weak var targetYConstraint: NSLayoutConstraint!
  
  @IBAction func colorTapped(_ sender: Any) {
    animations.append(.makeRandomColor())
  }
  
  @IBAction func sizeTapped(_ sender: Any) {
    animations.append(.makeRandomSize())
  }
  
  @IBAction func moveTapped(_ sender: Any) {
    animations.append(.makeRandomMove())
  }
  
  @IBAction func playTapped(_ sender: Any) {
    isMenuCollapsed.toggle()
    runAnimation()
  }
  
  
  @IBOutlet weak var sizeButtonContraint: NSLayoutConstraint!
  @IBOutlet weak var colorButtonConstraint: NSLayoutConstraint!
  @IBOutlet weak var moveButtonConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var patternView: UIImageView!
}

