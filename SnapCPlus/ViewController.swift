//
//  ViewController.swift
//  SnapCPlus
//
//  Created by vikas.jangir on 08/07/20.
//  Copyright © 2020 vikas.jangir. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var camPreView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var captureImageThumbnailButton: UIButton!
    
    let captureSesion = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    
    
    var isSessionSetUp = false
    var activeDeviceInput : AVCaptureDeviceInput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var capturedImageData : Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isSessionSetUp {
            if setUpSession() {
                setUpPreview()
                startSession()
            }
        } else {
            if !captureSesion.isRunning {
                startSession()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSesion.isRunning {
            stopSession()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        captureButton.layer.cornerRadius = captureButton.frame.width/2
        
    }
    
    func startSession() {
        DispatchQueue.main.async {
            self.captureSesion.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.main.async {
            self.captureSesion.stopRunning()
        }
    }
    
    func setUpSession() -> Bool{
        /*
         1. Begin the session using beginConfiguration
         2. Set the preset to photo
         3. Open the front camera using the AVCaptureDevice with media type video
         4. Add the AVCaptureDevice to AVCaptureDeviceInpute and then add to session
         5. Always begin and commit the session.
         6. Check for canAddOutput else return false
         */
        captureSesion.beginConfiguration()
        captureSesion.sessionPreset = AVCaptureSession.Preset.photo
        
        let camera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera!)
            if captureSesion.canAddInput(input) {
                captureSesion.addInput(input)
                activeDeviceInput = input
            } else {
                print("Setup session fail due to some error")
                captureSesion.commitConfiguration()
                return false
            }
        } catch {
            print("Setup session fail due to some error")
            captureSesion.commitConfiguration()
            return false
        }
        
        if captureSesion.canAddOutput(photoOutput) {
            captureSesion.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        } else {
            print("Setup session fail due to some error")
            captureSesion.commitConfiguration()
            return false
        }
        
        captureSesion.commitConfiguration()
        isSessionSetUp = true
        return true
    }
    
    func setUpPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSesion)
        previewLayer.frame = camPreView.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreView.layer.addSublayer(previewLayer)
    }
    
    @IBAction func capturedImagethumbnailButtonTouch(_ sender: Any) {
        guard let imageData = capturedImageData else {
            return
        }
        performSegue(withIdentifier: "CapturedImageSegue", sender:imageData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CapturedImageSegue" {
            let destinationVC = segue.destination as! CapturedImageViewController
            destinationVC.capturedImage = capturedImageData
        }
    }
    @IBAction func captureButtonDidTouch(_ sender: Any) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = AVCaptureDevice.FlashMode.auto
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
}

extension ViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error in capturing \(String(describing: error))")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Unable to create image data")
            return
        }
        
        capturedImageData = imageData
        captureImageThumbnailButton.setBackgroundImage(UIImage(data: capturedImageData), for: .normal)
        
    }
}

