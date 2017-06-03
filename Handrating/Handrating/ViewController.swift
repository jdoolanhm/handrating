//
//  ViewController.swift
//  Handrating
//
//  Created by Michael Doolan on 6/3/17.
//  Copyright © 2017 Michael Doolan. All rights reserved.
//

import UIKit
import AVFoundation
import TesseractOCR
class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    let session = AVCaptureSession()
    let output = AVCapturePhotoOutput()
    let preview = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.frame = self.view.frame
        // Do any additional setup after loading the view, typically from a nib.
        session.addOutput(output)
        let input = try! AVCaptureDeviceInput.init(device: AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).first as! AVCaptureDevice) 
        session.sessionPreset = AVCaptureSessionPresetHigh
        session.addInput(input)
        let layer = AVCaptureVideoPreviewLayer(session: session)
        preview.layer.addSublayer(layer!)
        layer?.frame = preview.layer.bounds
        self.view.addSubview(preview)
        session.startRunning()
        
        let button = UIButton()
        button.frame = CGRect(x: view.frame.maxX/2 - 30, y: view.frame.maxY - 100, width: 60, height: 60)
        button.layer.cornerRadius = 30
        view.addSubview(button)
        button.backgroundColor = UIColor(white: 1, alpha: 0.2)
        button.layer.borderColor = UIColor(white: 1, alpha: 0.6).cgColor
        button.layer.borderWidth = 0.6
        button.addTarget(self, action: #selector(click), for: UIControlEvents.touchUpInside)
    }

    func click(){
        print(output.availablePhotoCodecTypes)
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,

                             ]
        settings.previewPhotoFormat = previewFormat
        self.output.capturePhoto(with: settings, delegate: self)
    }
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let prev = previewPhotoSampleBuffer {
            if let buff = CMSampleBufferGetImageBuffer(prev) {
                let cim = CIImage(cvPixelBuffer: buff)
                let im = UIImage(ciImage: cim)
                var g = UIImageView(image: im)
                
                g.frame = self.view.bounds
                g.contentMode = .scaleAspectFit
                g.transform = g.transform.rotated(by: CGFloat(M_PI_2) )
                print(performImageRecognition(image: im))
                self.view.addSubview(g)
            }
        }
    }
    func performImageRecognition(image: UIImage) ->String{
        // 1
        let tesseract = G8Tesseract(language: "eng")!
        // 2
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
        return tesseract.recognizedText
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

