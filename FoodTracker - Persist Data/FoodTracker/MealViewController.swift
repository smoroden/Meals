//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 5/23/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//  See LICENSE.txt for this sample’s licensing information.
//

import UIKit

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    /*
        This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
        or constructed as part of adding a new meal.
    */
    var meal: Meal?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
            descriptionTextField.text = meal.userDescription
            caloriesTextField.text = "\(meal.calories)"
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidMealName()
        navigationItem.title = textField.text
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func checkValidMealName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Navigation
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            saveNewMealToServer()
//            
//            let caloriesText = caloriesTextField.text ?? "0"
//            if let calories = Int(caloriesText) {
//                let name = nameTextField.text ?? ""
//                let photo = photoImageView.image
//                let rating = ratingControl.rating
//                let description = descriptionTextField.text ?? ""

                // Set the meal to be passed to MealListTableViewController after the unwind segue.
                //meal = Meal(name: name, photo: photo, rating: rating, calories: calories, userDescription: description)
//            }
            
            
        }
    }
    
    func saveNewMealToServer() {
        let caloriesText = caloriesTextField.text ?? "0"

        let postData = [
            "title": nameTextField.text ?? "",
            "description": descriptionTextField.text ?? "",
            "calories": Int(caloriesText) ?? 0
        ]
        
        guard let postJSON = try? NSJSONSerialization.dataWithJSONObject(postData, options: []) else {
            print("could not serialize json")
            return
        }
        
        let req = NSMutableURLRequest(URL: NSURL(string:"http://159.203.243.24:8000/users/me/meals")!)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let token = defaults.stringForKey("token")
        
        req.HTTPBody = postJSON
        req.HTTPMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("\(token)", forHTTPHeaderField: "token")
        
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
            let meal = formattedJSON["meal"] as? [String:AnyObject]{
                
            }

            
        }
        
        task.resume()

    }
    
    
    
    
    // MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Could not create a new meal", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Try Again", style: .Cancel) { _ in }
        
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }


}
