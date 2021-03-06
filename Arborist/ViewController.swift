//
//  ViewController.swift
//  Arborist
//
//  Created by Vijay Murugappan Subbiah on 9/22/18.
//  Copyright © 2018 VMS. All rights reserved.
//

/* THANKS TO PLANET NATURAL.COM FOR ALL THE DATA PROVIDED TO SAVE THE PLANTS */

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    let dataOutput = AVCaptureVideoDataOutput()
    let observationView = UIView()
    let recentObject = String()
    let resultLabel = UILabel()
    let objectLabel = UILabel()
    let confidenceLabel = UILabel()
    let confidenceLevelLabel = UILabel()
    var objectName = String()
    let cureButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        captureSession.startRunning()
        let previewCaptureLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewCaptureLayer)
        previewCaptureLayer.frame = CGRect(x: 0, y:0, width: view.frame.width, height: view.frame.height - 128)
        observationView.frame = CGRect(x: 0, y: 540, width: view.frame.width, height: 128)
        setLabel(label: resultLabel, x: 30, y: 20, width: 80, height: 30, text: "Object :")
        setLabel(label: confidenceLabel, x: 30, y: 60, width: 120, height: 30, text: "Confidence :")
        setButton(button: cureButton, x: 270, y: 15, width: 80, height: 80, text: "CURE")
        view.addSubview(observationView)
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        guard let model = try? VNCoreMLModel(for: PlantDiseaseClassifier().model) else {return}
        let vnRequest = VNCoreMLRequest(model: model) { (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            guard let recentObservation = results.first else {return}
            var confidence = (recentObservation.confidence * 100).rounded(.awayFromZero)
            confidence = ((confidence/50) * 100).rounded(.awayFromZero)
            if(confidence > 80) {
                DispatchQueue.main.async {
                    self.objectName = recentObservation.identifier
                    self.setLabel(label: self.objectLabel, x: 120, y: 20, width: 140, height: 30, text: self.objectName)
                    self.setLabel(label: self.confidenceLevelLabel, x: 160, y: 60, width: 100, height: 30, text: "\(confidence)%")
                }
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([vnRequest])
    }
    
    func setLabel(label: UILabel, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String) {
        label.frame = CGRect(x: x, y: y, width: width, height: height)
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.black
        observationView.addSubview(label)
    }
    
    func setButton(button: UIButton, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String) {
        button.frame = CGRect(x: x, y: y, width: width, height: height)
        button.setTitle(text, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor.green
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(showCure), for: .touchUpInside)
        observationView.addSubview(button)
    }
    
    @objc func showCure() {
        performSegue(withIdentifier: "help", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "help" {// if destination id is help
            let vc = segue.destination as! WebViewController
            vc.navigationItem.title = objectName
            if objectName == "Black Knot" {
                objectName = objectName.replacingOccurrences(of: "Black Knot", with: "black-knot-fungus")
                vc.urlString = "https://www.planetnatural.com/pest-problem-solver/plant-disease/\(objectName)/"
            }
            else if objectName == "Leaf Spot" {
                objectName = objectName.replacingOccurrences(of: "Leaf Spot", with: "bacterial-leaf-spot")
                vc.urlString = "https://www.planetnatural.com/pest-problem-solver/plant-disease/\(objectName)/"
            }
            else if objectName == "Rust" {
                objectName = objectName.replacingOccurrences(of: "Rust", with: "common-rust")
                vc.urlString = "https://www.planetnatural.com/pest-problem-solver/plant-disease/\(objectName)/"
            }
            else {
                vc.urlString = "https://www.planetnatural.com/pest-problem-solver/plant-disease/\(objectName)/"
            }
        }
    }


}

