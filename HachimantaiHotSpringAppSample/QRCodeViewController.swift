//
//  QRCodeViewController.swift
//  HachimantaiHotSpringAppSample
//
//  Created by 高橋知憲 on 2017/11/19.
//  Copyright © 2017年 高橋知憲. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import SwiftyJSON

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var previewView: UIView!
    
    
    let facilityNum = 0 //施設番号
    var dataNum = 0 //データの番号
    var nowDate = "" //日時
    var DBRef: DatabaseReference!
    var checkValue:String = "" //重複チェック用
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBRef = Database.database().reference()
        
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
            metadataOutput.metadataObjectTypes = [.code39]
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
        let ac = UIAlertController(title: "スキャンがサポートされていません", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
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
        
        let regEx = "^[0-9]{8}$" //正規表現チェッカー(数字で7文字)
        
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            //同じQRが連続で読まれてもデータを送信しないようにする
            
            
            //直前のコードと同じでないことと、7桁の数字であることをチェック
            if stringValue != checkValue && NSPredicate(format: "SELF MATCHES %@", regEx).evaluate(with: stringValue)
 {
                //バーコードの末尾１文字(チェックデジット)切り捨て
                let convertValue = String(stringValue.prefix(stringValue.count - 1))
                checkValue = stringValue
                //バイブレーションと音を鳴らす
//                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                audioPlayer.play()
//                found(code: stringValue)
                //ラベルに読み取り結果を表示
                resultLabel.text = convertValue
                //Firebaseにpost
                postDataToFirebase(stringValue: convertValue, reference: DBRef)
            }
            
        }
    }
    
    
    func found(code: String) {
        print(code)
    }
    
    
    //AVAudioPlayerに音楽ファイルを読み込ませるメソッド
    func setupSE() {
        if let path = Bundle.main.path(forResource: "decision2", ofType: ".mp3") {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try! AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
        }
        
    }
    
    
    //Firebaseに読み込んだバーコードの値と日時と施設番号を送信するメソッド
    func postDataToFirebase(stringValue: String, reference: DatabaseReference) {
        
        let data: [String: Any] = ["PersonalID": stringValue, "Date": getShortDate() ,"Time": getTime(), "facilityNum": "\(facilityNum)"]
//        print(data)
        reference.childByAutoId().setValue(data)
    }
    
//    //Firebaseからデータを取り出す
//    func getDataFromFirebase(stringValue: String, reference: DatabaseReference) {
//        reference.child("data").observe(.value) { (snapshot: DataSnapshot) in
//            let getJSON = JSON(snapshot.value as? [String: Any] ?? [:])
//            if getJSON.count == 0 {return}
//        }
//    }
    
   
    
    /* TODO: 共通化する */
    
    //現在（バーコードを読み取った時）の日時を取得するメソッド
    
    //時刻を取る
    func getTime() -> String {
        let formatter1 = DateFormatter()
        formatter1.timeStyle = .short //何時何分まで
        formatter1.dateStyle = .none
        formatter1.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let timeString = formatter1.string(from: now)
        return timeString
    }
    
    //年月日を取る(Y/m/d)
    func getShortDate() -> String{
        let formatter2 = DateFormatter()
        formatter2.timeStyle = .none
        formatter2.dateStyle = .short
        formatter2.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let dateString = formatter2.string(from: now)
        return dateString
    }
    
    //年月日を取る(Y年m月d日)
    func getLongDate() -> String{
        let formatter2 = DateFormatter()
        formatter2.timeStyle = .none
        formatter2.dateStyle = .long
        formatter2.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let dateString = formatter2.string(from: now)
        return dateString
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


