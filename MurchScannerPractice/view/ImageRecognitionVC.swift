//
//  ImageRecognitionVC.swift
//  MurchScannerPractice
//
//  Created by Hunter Buxton on 8/9/19.
//  Copyright © 2019 Hunter Buxton. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ImageRecognitionVC: UIViewController  {
    
    lazy var cancelBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelScannerAction))
    lazy var camBtn: UIButton = UIButton()
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // AV setup
        setupCaptureSession()
        setupDevice()
        setupInputAndOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        // UI Setup
        self.view.backgroundColor = .white
        self.navigationItem.setLeftBarButton(cancelBtn, animated: true)
        camBtnSetup()
    }
    
    private func camBtnSetup() {
        camBtn.addTarget(self, action: #selector(camButtonAction), for: .touchUpInside)
        camBtn.layer.borderColor = UIColor.white.cgColor
        camBtn.layer.borderWidth = 5
        camBtn.layer.cornerRadius = 30
        camBtn.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(camBtn)
        NSLayoutConstraint.activate([
            camBtn.widthAnchor.constraint(equalToConstant: 60),
            camBtn.heightAnchor.constraint(equalToConstant: 60),
            camBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            camBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
            ])
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentCamera =  backCamera
    }
    
    func setupInputAndOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            //photoOutput = AVCapturePhotoOutput()
            //photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            //captureSession.addOutput(photoOutput!)
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(dataOutput)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    @objc func cancelScannerAction() {
        print("called ScannerVC.cancelScannerAction()")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func camButtonAction() {
        print("called ScannerVC.camButtonAction() ")
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
}

extension ImageRecognitionVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let temp = UIImage(data: imageData)
            if currentCamera == backCamera {
                image = temp
            } else {
                self.image = UIImage(cgImage: temp!.cgImage!, scale: temp!.scale, orientation: .leftMirrored)
            }
            let vc = ShowPhotoVC()
            vc.photo = self.image
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ImageRecognitionVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("captureOutputCalled", Date())
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: Resnet50().model ) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            print(firstObservation.identifier, firstObservation.confidence)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
