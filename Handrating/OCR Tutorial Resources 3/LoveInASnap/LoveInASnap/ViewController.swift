//
//  ViewController.swift
//  LoveInASnap
//
//  Created by Lyndsey Scott on 1/11/15
//  for http://www.raywenderlich.com/
//  Copyright (c) 2015 Lyndsey Scott. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var InputField: UITextField!
 //       @IBOutlet weak var Input: UIButton!
  @IBOutlet weak var GO: UIButton!

  @IBAction func Go(_ sender: UIButton) {
  }
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var findTextField: UITextField!
  @IBOutlet weak var replaceTextField: UITextField!
  @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    ans = InputField.text!
    print(ans)
    
  }
  
  var ans:String = "y"
  var activityIndicator:UIActivityIndicatorView!
  var originalTopMargin:CGFloat!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    InputField.delegate=self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    originalTopMargin = topMarginConstraint.constant
  }
  
  func performImageRecognition(_ image: UIImage) {
    

    
    // 1
    let tesseract = G8Tesseract()
    // 2
    tesseract.language = "eng+fra"
    // 3
    tesseract.engineMode = .tesseractCubeCombined
    // 4
    tesseract.pageSegmentationMode = .auto
    // 5
    tesseract.maximumRecognitionTime = 60.0
    // 6
    tesseract.image = image.g8_blackAndWhite()
       tesseract.recognize()
    
    // 7
     // print(tesseract.recognizedText)
    //print(tesseract.recognizedText.characters.count)
    
    removeActivityIndicator()
    
    /*do{
    try tesseract.recognizedText
    } catch {
      
    }*/

    if(tesseract.recognizedText! != ""){
 
    print(tesseract.recognizedText)
    let index = tesseract.recognizedText.index(tesseract.recognizedText.startIndex, offsetBy: tesseract.recognizedText.characters.count-2)
    print(tesseract.recognizedText.substring(to: index))


   print(ans)
      if(tesseract.recognizedText.substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""){
   let t = tesseract.recognizedText.substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).getLevenshtein(ans)
   //   let t = tesseract.recognizedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).getLevenshtein(ans)
        
        
      var p = Double (tesseract.recognizedText.substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count - t) / Double (tesseract.recognizedText.substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count)
        if(tesseract.recognizedText.substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count - t<0){
          p = 0;
        }
      let s = tesseract.recognizedText.substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      textView.text = "You wrote: "
        textView.text! +=  s
      textView.text! += "\n"
        textView.text! += "You were "
          textView.text! += String(t) + " letter(s) off." + "\n"
      textView.text! += "You were " + String (Int (100*p)) + "% correct"
      textView.font = UIFont(name: "Cochin", size: 18)

       textView.isEditable = true
    // 8
    }
      else{
        textView.text = "Please retake the photo!"
      }
    }
    else{
      textView.text = "Please retake the photo!"
    }
    
  }
  /*
  @IBAction func inputButtonAction(_ sender: UIButton) {
    // 1
    view.endEditing(true)
    moveViewDown()
    // 2
    let imagePickerActionSheet = UIAlertController(title: "Input the Correct Answer!",
                                                   message: nil, preferredStyle: .actionSheet)
    // 3
    // 5
    
    // 6
    
  
    present(imagePickerActionSheet, animated: true,
            completion: nil)
    ans = askForCorrectAnswer()
    print("Buttonn")
    print(ans)
    
  }
*/
  
  @IBAction func takePhoto(_ sender: AnyObject) {
    
    
    // 1
    view.endEditing(true)
    moveViewDown()
    // 2
    let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
      message: nil, preferredStyle: .actionSheet)
    // 3
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let cameraButton = UIAlertAction(title: "Take Photo",
        style: .default) { (alert) -> Void in
          let imagePicker = UIImagePickerController()
          imagePicker.delegate = self
          imagePicker.sourceType = .camera
          self.present(imagePicker,
            animated: true,
            completion: nil)
      }
      imagePickerActionSheet.addAction(cameraButton)
    }
   /* // 4
    let libraryButton = UIAlertAction(title: "Choose Existing",
      style: .default) { (alert) -> Void in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker,
          animated: true,
          completion: nil)
    }
    imagePickerActionSheet.addAction(libraryButton)*/
    // 5
    let cancelButton = UIAlertAction(title: "Cancel",
      style: .cancel) { (alert) -> Void in
    }
    imagePickerActionSheet.addAction(cancelButton)
    // 6

    
    present(imagePickerActionSheet, animated: true,
      completion: nil)
  }
  
  @IBAction func swapText(_ sender: AnyObject) {
    
  }
  
  @IBAction func sharePoem(_ sender: AnyObject) {
  }
  
 
  //PROMPT FOR CORRECT STRING
  func askForCorrectAnswer() -> String {
    var alertController:UIAlertController?
    
    
    var answer:String = "some crap"
    
    alertController = UIAlertController(title: "Enter Text",
                                        message: "Enter some text below",
                                        preferredStyle: .alert)
    
    
    alertController!.addTextField(
      configurationHandler: {(textField: UITextField!) in
        textField.placeholder = "Enter something"
    })
    
    let action = UIAlertAction(title: "Submit",
                               style: UIAlertActionStyle.default,
                               handler: {
                                [weak self]
                                (paramAction:UIAlertAction!) in
                                if let textFields = alertController?.textFields{
                                  let theTextFields = textFields as [UITextField]
                                  let enteredText = theTextFields[0].text
                                  answer = enteredText!
                                                               //self!.displayLabel.text = enteredText
                                }
    })
    
    alertController?.addAction(action)
    self.present(alertController!, animated: true, completion: nil)
    return answer
    

  }//askforcorrectAnswer()
  
  
  // Activity Indicator methods
  
  func addActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(frame: view.bounds)
    activityIndicator.activityIndicatorViewStyle = .whiteLarge
    activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
  }
  
  func removeActivityIndicator() {
    activityIndicator.removeFromSuperview()
    activityIndicator = nil
  }
  
  
  // The remaining methods handle the keyboard resignation/
  // move the view so that the first responders aren't hidden
  
  func moveViewUp() {
    if topMarginConstraint.constant != originalTopMargin {
      return
    }
    
    topMarginConstraint.constant -= 135
    UIView.animate(withDuration: 0.3, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func moveViewDown() {
    if topMarginConstraint.constant == originalTopMargin {
      return
    }

    topMarginConstraint.constant = originalTopMargin
    UIView.animate(withDuration: 0.3, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })

  }
  
  @IBAction func backgroundTapped(_ sender: AnyObject) {
    view.endEditing(true)
    moveViewDown()
  }
}

extension ViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    moveViewUp()
  }
  
  @IBAction func textFieldEndEditing(_ sender: AnyObject) {
    view.endEditing(true)
    moveViewDown()
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    moveViewDown()
  }
}



func scaleImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
  
  var scaledSize = CGSize(width: maxDimension, height: maxDimension)
  var scaleFactor: CGFloat
  
  if image.size.width > image.size.height {
    scaleFactor = image.size.height / image.size.width
    scaledSize.width = maxDimension
    scaledSize.height = scaledSize.width * scaleFactor
  } else {
    scaleFactor = image.size.width / image.size.height
    scaledSize.height = maxDimension
    scaledSize.width = scaledSize.height * scaleFactor
  }
  
  UIGraphicsBeginImageContext(scaledSize)
  image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
  let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  
  return scaledImage!
}



extension ViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [String : Any]) {
      let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
      let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
      
      addActivityIndicator()
      
      dismiss(animated: true, completion: {
        
                self.performImageRecognition(scaledImage)
      })
  }


  
}
