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
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var findTextField: UITextField!
  @IBOutlet weak var replaceTextField: UITextField!
  @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
  
  var activityIndicator:UIActivityIndicatorView!
  var originalTopMargin:CGFloat!
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
    let index = tesseract.recognizedText.index(tesseract.recognizedText.startIndex, offsetBy: tesseract.recognizedText.characters.count-2)
   
    let t = tesseract.recognizedText.substring(to: index).getLevenshtein("Hello")
    textView.text = String(t)

       textView.isEditable = true
    // 8
    removeActivityIndicator()
  }
  
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
    // 4
    let libraryButton = UIAlertAction(title: "Choose Existing",
      style: .default) { (alert) -> Void in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker,
          animated: true,
          completion: nil)
    }
    imagePickerActionSheet.addAction(libraryButton)
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
