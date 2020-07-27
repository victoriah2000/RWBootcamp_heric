//
//  ViewController.swift
//  jQuiz
//
//  Created by Jay Strawn on 7/17/20.
//  Copyright © 2020 Jay Strawn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var soundButton: UIButton!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var clueLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var scoreLabel: UILabel!

  var clue: Clue?
  var answers: [String] = []
  
  var points: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
    
    self.clueLabel.text = ""
    self.categoryLabel.text = ""
    self.scoreLabel.text = "\(self.points)"
    
    if SoundManager.shared.isSoundEnabled == false {
      soundButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
    } else {
      soundButton.setImage(UIImage(systemName: "speaker"), for: .normal)
    }
    
    SoundManager.shared.playSound()
    
    populateClues()
  }
  
  @IBAction func didPressVolumeButton(_ sender: Any) {
    SoundManager.shared.toggleSoundPreference()
    if SoundManager.shared.isSoundEnabled == false {
      soundButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
    } else {
      soundButton.setImage(UIImage(systemName: "speaker"), for: .normal)
    }
  }
  
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return answers.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text = answers[indexPath.row]
    cell.backgroundColor = view.backgroundColor
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if answers[indexPath.row] == clue?.answer {
      // Right
      points += 10
      self.scoreLabel.text = "\(self.points)"
    }
    populateClues()
  }
}

extension ViewController {
  
  func populateClues() {
    Networking.sharedInstance.getRandomCategory { [weak self] category in
      Networking.sharedInstance.getCluesInCategory(category) { clues in
        DispatchQueue.main.async {
          guard let self = self else { return }
          
          let shuffledClues = clues.shuffled()
          self.clue = shuffledClues.first
          self.answers = Array(shuffledClues.prefix(4).map(\.answer)).shuffled()
          self.categoryLabel.text = category.title
          self.clueLabel.text = self.clue?.question ?? "---"
          self.tableView.reloadData()
        }
      }
    }
  }
  
}
