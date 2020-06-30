//
//  ViewController.swift
//  Birdie-Final
//
//  Created by Jay Strawn on 6/18/20.
//  Copyright © 2020 Jay Strawn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateStyle = .short
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MediaPostsHandler.shared.getPosts()
        setUpTableView()
       
        
        
    }

   func setUpTableView() {
    tableview.delegate = self
    tableview.dataSource = self
        // Set delegates, register custom cells, set up datasource, etc.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MediaPostsHandler.shared.mediaPosts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = MediaPostsHandler.shared.mediaPosts[indexPath.row]
        
        switch post {

        case let imagePost as ImagePost:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImagePostCell", for: indexPath) as! ImageTableViewCell
             
            cell.usernameLabel?.text = imagePost.userName
            cell.dateLabel?.text = Self.dateFormatter.string(from: imagePost.timestamp)
            cell.messageLabel?.text = imagePost.textBody
            cell.postImageView.image = imagePost.image
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextPostCell", for: indexPath) as! TextPostTableViewCell
            cell.usernameLabel?.text = post.userName
            cell.dateLabel?.text = Self.dateFormatter.string(from: post.timestamp)
            cell.messageLabel?.text = post.textBody
            return cell
        }
    }

    @IBAction func didPressCreateTextPostButton(_ sender: Any) {
        let alert = UIAlertController(title: "Post", message: "", preferredStyle: .alert)
        alert.addTextField { config in
            config.placeholder = "Username"
        }
        alert.addTextField { config in
            config.placeholder = "Message"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okay = UIAlertAction(title: "OK", style: .default) { [weak self, unowned alert] _ in
            let username = alert.textFields![0].text ?? "default username"
            let message = alert.textFields![1].text ?? "No message"
            
            let post = TextPost(textBody: message, userName: username, timestamp: Date())
            MediaPostsHandler.shared.addTextPost(textPost: post)
            self?.tableview.reloadData()
            self?.tableview.scrollToRow(at: IndexPath(item: 0, section: 0),
                                        at: .top, animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(okay)
        
        present(alert, animated: true) {
            print("complete")
        }
    }

    @IBAction func didPressCreateImagePostButton(_ sender: Any) {
        let alert = UIAlertController(title: "Post Image", message: "This is too hard.", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true) {
            print("complete")
        }
    }

}



