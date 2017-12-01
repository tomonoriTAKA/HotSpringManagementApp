//
//  QRCodeViewController.swift
//  HachimantaiHotSpringAppSample
//
//  Created by 高橋知憲 on 2017/11/19.
//  Copyright © 2017年 高橋知憲. All rights reserved.
//

import UIKit
import AVFoundation
class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var previewView: UIView!
    var checkValue:String = ""
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //session
        captureSession = AVCaptureSession()
        
        //device
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        //input
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        
        //output
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        //preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = previewView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewView.layer.addSublayer(previewLayer)
        
        // どの範囲を解析するか設定する
        metadataOutput.rectOfInterest = previewView.layer.bounds
        
        //start
        captureSession.startRunning()
        
        //setup sound
        setupSE()
    }
    
    //failed alert
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    
    //メタデータをキャプチャーしたときのメソッド
    func metadataOutput(_ output: AVCaptureMetadataOutput,didOutput metadataObjects: [AVMetadataObject],from connection: AVCaptureConnection){
//        captureSession.stopRunning()
        
        
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            //同じQRが連続で読まれてもデータを送信しないようにする
            
            if stringValue != checkValue {
                checkValue = stringValue
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                audioPlayer.play()
                found(code: stringValue)
                resultLabel.text = stringValue
            }
            
        }
    }
    
    
    func found(code: String) {
        print(code)
    }
    
    
    //AVAudioPlayerに音楽ファイルを読み込ませるメソッド
    func setupSE() {
        if let path = Bundle.main.path(forResource: "se_maoudamashii_system23", ofType: ".mp3") {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try! AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
        }
        
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


