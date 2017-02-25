//
//  ViewController.swift
//  alarm
//
//  Created by 石森愛海 on 2016/05/28.
//  Copyright © 2016年 石森愛海. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController ,CLLocationManagerDelegate, AVAudioPlayerDelegate{
    
    var myLocationManager:CLLocationManager!
    
      private var myButton: UIButton!
    
    var audioPlayer:AVAudioPlayer!
    var timer: NSTimer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        do {
            // 音楽ファイルが"sample.mp3"の場合
            let filePath = NSBundle.mainBundle().pathForResource("music", ofType: "mp3")
            let audioPath = NSURL(fileURLWithPath: filePath!)
            audioPlayer = try AVAudioPlayer(contentsOfURL: audioPath)
            audioPlayer.prepareToPlay()
        } catch {
            print("Error")
        }
        
        //止めるボタンの非表示
        self.stopButton.hidden = true
        
        
        // 起動した時点の時刻をmyLabelに反映
        myLabel.text = getNowTime()
        // 時間管理してくれる
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: true)
        
        // ボタンの生成.
        myButton = UIButton()
        myButton.frame = CGRectMake(0,0,500,20)
        myButton.backgroundColor = UIColor.clearColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("", forState: .Normal)
        myButton.layer.cornerRadius = 50.0
        myButton.layer.position = CGPoint(x: self.view.bounds.width/2,y:490)
        
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        
        
        self.view.addSubview(myButton)
        
    }
    @IBOutlet var stopButton: UIButton!
    
    
    // ボタンイベントのセット.
    func onClickMyButton(sender: UIButton){
    }
    
    
    private var tempTime: String = "00:00:00"
    private var setTime: String = "00:00:00"
    
    
    func myButtonFunc(sender: AnyObject) {
        // アラームをセット
        setTime = tempTime
        // test print
        print("test: myButton Pushed!")
        
        let alert = UIAlertController(title: "セット完了", message: "アラームがセットされました！", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(
            UIAlertAction(title: "OK",
                          style: UIAlertActionStyle.Default,
                        handler: {action in
                            
                            NSLog("button pushied")
                            
            }
            )
        )
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func myDPFunc(sender: AnyObject) {
        print("test: myDP moved!")
        // DPの値を成形
        let format = NSDateFormatter()
        format.dateFormat = "HH:mm"
        // 一時的にDPの値を保持
        tempTime = format.stringFromDate(myDPvar.date)
    
    }
      
    
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myDPvar: UIDatePicker!
    
    func getNowTime()-> String {
        // 現在時刻を取得
        let nowTime: NSDate = NSDate()
        // 成形する
        let format = NSDateFormatter()
        format.dateFormat = "HH:mm"
        let nowTimeStr = format.stringFromDate(nowTime)
        // 成形した時刻を文字列として返す
        return nowTimeStr
    }
    
    func update() {
        // 現在時刻を取得
        let str = getNowTime()
        // myLabelに反映
        myLabel.text = str
        // アラーム鳴らすか判断
        myAlarm(str)
    }
    
    func myAlarm(str: String) {
        // 現在時刻が設定時刻と一緒なら
        if str == setTime{
            timer.invalidate()
            alert()
            
            audioPlayer.play() // 音楽の再生
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
        
                   //止めるボタンの表示
            self.stopButton.hidden = false
           
        }else{
            print("hideeeeeeee")
            self.stopButton.hidden = true
        }
    
        
    }
    
    // アラートの表示
    func alert() {
        let myAlert = UIAlertController(title: "時刻です！", message: "おはよう！迷路をといてアラームを止めよう！", preferredStyle: .Alert)
        let myAction = UIAlertAction(title: "わかった！", style: .Default) {
            action in print("foo!!")
        }
        myAlert.addAction(myAction)
        presentViewController(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func stop() {
      audioPlayer.stop()
    }
    
    
    
    
          override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        


}
    
    