//
//  SignupViewController.swift
//  FoodTracker
//
//  Created by Zach Smoroden on 2016-06-06.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    var isLogin = false
    
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(false)
    }
    

    @IBAction func signup(sender: UIButton) {
        guard let password = passwordTextField.text,
            let username = usernameTextField.text
            else {
                return;
        }
        
        if username.isEmpty || password.characters.count < 4 {
            showAlert()
        } else {
            makeRequest(username, password: password, requestType: "signup")
            
        }
        
    }

    @IBAction func login(sender: UIButton) {
        guard let password = passwordTextField.text,
            let username = usernameTextField.text
            else {
                return;
        }
        
        if username.isEmpty || password.characters.count < 4 {
            showAlert()
        } else {
            makeRequest(username, password: password, requestType: "login")
        }

    }
    func makeRequest(username:String, password:String, requestType:String) {
        let postData = [
            "username": username,
            "password": password
        ]
        
        guard let postJSON = try? NSJSONSerialization.dataWithJSONObject(postData, options: []) else {
            print("could not serialize json")
            return
        }
        
        let req = NSMutableURLRequest(URL: NSURL(string:"http://159.203.243.24:8000/\(requestType)")!)
        
        req.HTTPBody = postJSON
        req.HTTPMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(req) { (data, resp, err) in
            
            guard let data = data else {
                print("no data returned from server \(err)")
                return
            }
            
            guard let resp = resp as? NSHTTPURLResponse else {
                print("no response returned from server \(err)")
                return
            }
            
            guard let rawJson = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else {
                print("data returned is not json, or not valid")
                return
            }
            
            guard resp.statusCode == 200 else {
                // handle error
                print("an error occurred \(rawJson["error"])")
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert()
                
                
                })
                return
            }
            
            // do something with the data returned (decode json, save to user defaults, etc.)
            
            if let json = try? NSJSONSerialization.JSONObjectWithData(data, options:[]),
                let formattedJSON = json as? [String:AnyObject],
                let user = formattedJSON["user"] as? [String:AnyObject]{
                
                let defaults = NSUserDefaults.standardUserDefaults()
                
                defaults.setObject(user["username"], forKey: "username")
                defaults.setObject(user["password"], forKey: "password")
                defaults.setObject(user["token"], forKey: "token")
                
                self.performSegueWithIdentifier("toMainSegue", sender: self)
            }
        }
        
        task.resume()
    }

    func showAlert() {
        let alert = UIAlertController(title: "Bad Username or Password", message: "Need a valid username and password that has at least 5 characters", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Try Again", style: .Cancel) { _ in }
        
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

}
