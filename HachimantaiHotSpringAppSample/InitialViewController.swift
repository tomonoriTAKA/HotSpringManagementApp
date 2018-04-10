//
//  InitialViewController.swift
//  HachimantaiHotSpringAppSample
//
//  Created by 高橋知憲 on 2018/03/22.
//  Copyright © 2018年 高橋知憲. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var facilityNamePicker: UIPickerView!
    var facilityName: String = ""
    var facilityNumber: Int = 0
    
    private let facilitiesArray: [String] = ["七時雨憩の湯", "なかやま温泉館", "綿帽子温泉館", "八幡平温泉館森乃湯"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //デリゲートとデータソースを自分に設定
        facilityNamePicker.delegate = self
        facilityNamePicker.dataSource = self
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return facilitiesArray.count
    }
    
    
    
    /*
     pickerに表示する値を返すデリゲートメソッド.
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return facilitiesArray[row]
    }
    
    
    /*
     pickerが選択された際に呼ばれるデリゲートメソッド.
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row: \(row)")
        print("value: \(facilitiesArray[row])")
        
        facilityName = facilitiesArray[row]
        facilityNumber = row + 1
    }
    
    
    //決定ボタンが押された時
    @IBAction func tappedSubmitButton(_ sender: UIButton) {
        
        submitAlart()
        
    }
    
    
    func submitAlart() {
        let alertC = UIAlertController(title:"施設の決定", message: "本当にこの施設でよろしいですか？", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in
            self.saveFacilityNum()
            self.toNextView()
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertC.addAction(okAction)
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: nil)
        
    }
    
    
    func saveFacilityNum() {
        //UserDefaultsに施設番号(facilityNumber)を保存
        let userDefaults = UserDefaults.standard
        userDefaults.set(facilityNumber, forKey: "facilityNumber")
    }
    
    
    func toNextView() {
        //画面遷移
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let QRcodeVC = storyboard.instantiateInitialViewController() as! QRCodeViewController
        self.present(QRcodeVC, animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
