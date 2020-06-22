//
//  ViewController.swift
//  CompatibilitySlider-Start
//
//  Created by Jay Strawn on 6/16/20.
//  Copyright © 2020 Jay Strawn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var compatibilityItemLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var questionLabel: UILabel!
    
    var compatibilityItems = ["Pug", "Labrador", "Bulldog", "Mutt", "Dalmatian"] // Add more!
    var currentItemIndex = 0
    
    var person1 = Person(id: 1, items: [:])
    var person2 = Person(id: 2, items: [:])
    var currentPerson: Person?
    var isPersonOneDone = false
    var isPersonTwoDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startNewGame()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        //print(sender.value)
    }
    
    @IBAction func didPressNextItemButton(_ sender: Any) {
    saveScore()
    }
    
    func calculateCompatibility() -> String {
        // If diff 0.0 is 100% and 5.0 is 0%, calculate match percentage
        var percentagesForAllItems: [Double] = []
        
        for (key, person1Rating) in person1.items {
            let person2Rating = person2.items[key] ?? 0
            let difference = abs(person1Rating - person2Rating)/5.0
            percentagesForAllItems.append(Double(difference))
        }
        
        let sumOfAllPercentages = percentagesForAllItems.reduce(0, +)
        let matchPercentage = sumOfAllPercentages/Double(compatibilityItems.count)
        print(matchPercentage, "%")
        let matchString = 100 - (matchPercentage * 100).rounded()
        return "\(matchString)%"
    }
    
    func startNewGame(){
        currentItemIndex = 0
        isPersonOneDone = false
        isPersonTwoDone = false
        startNewRound()
        
        
    }
    func startNewRound(){
        if !isPersonOneDone {
             currentPerson = person1
        } else {
            currentPerson = person2
        }
        
        if currentItemIndex < compatibilityItems.count {
            updateLabel()}
        else
        {
            saveScore()
        }
    }
    
    func updateLabel() {
        if !isPersonOneDone {
                   questionLabel.text = "Lover 1, what do you think about..."
                 
               } else {
                   questionLabel.text = "Lover 2, what do you think about..."
            
               }
        if currentItemIndex < compatibilityItems.count {
               compatibilityItemLabel.text = compatibilityItems[currentItemIndex]
           }
    }
    
    func saveScore() {
        if currentItemIndex < compatibilityItems.count {
                 let currentItem = compatibilityItems[currentItemIndex]
                 currentPerson?.items.updateValue(slider.value, forKey: currentItem)
                 currentItemIndex += 1
                 startNewRound()
        } else {
            if isPersonOneDone == false && isPersonTwoDone == false {
                isPersonOneDone = true
                currentItemIndex = 0
                startNewRound()
            } else if isPersonOneDone == true && isPersonTwoDone == false {
                isPersonTwoDone = true
                currentItemIndex = 0
                print(calculateCompatibility())
                showAlert(title: "Results", message: "You have \(calculateCompatibility()) chance of winding up in the dog house together" )
            }
            
        }
        
    }
    
    func showAlert (title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true) {
            self.startNewGame()
        }
        
              
    }
    
}
