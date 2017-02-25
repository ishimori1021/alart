//
//  File.swift
//  Walking Alarm
//
//  Created by 石森愛海 on 2016/06/25.
//  Copyright © 2016年 石森愛海. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import Accounts
import Social

class MeiroViewControllerFile: UIViewController {
    
    @IBOutlet weak var myTextView: UITextView!
    
    var number:Int = 0 // 間違えた回数
    var myComposeView : SLComposeViewController!
    var playerView: UIView!
    var playerMotionManager: CMMotionManager!
    var speedX: Double = 0.0
    var speedY: Double = 0.0
    var accountStore = ACAccountStore() //Twitter、Facebookなどの認証を行うクラス
    var twitterAccount: ACAccount?      //Twitterのアカウントデータを格納する
    
    let screenSize = UIScreen.mainScreen().bounds.size
    let maze = [
        [1,0,0,1],
        [0,1,0,0],
        [1,0,1,2],
        [3,0,1,0],
        [1,0,1,0],
        [0,0,0,0],
        ]
    
    var goalView: UIView!
    var startView: UIView!
    
    var wallRectArray = [CGRect]()
    
    var audioPlayer:AVAudioPlayer!
    
    
    let session = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //アプリ実行時にTwitter認証を行うアカウントデータを取得する
        getTwitterAccount()
        
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch  {
            // エラー処理
            fatalError("カテゴリ設定失敗")
        }
        
        // sessionのアクティブ化
        do {
            try session.setActive(true)
        } catch {
            // audio session有効化失敗時の処理
            // (ここではエラーとして停止している）
            fatalError("session有効化失敗")
        }

        
        do {
            // 音楽ファイルが"sample.mp3"の場合
            let filePath = NSBundle.mainBundle().pathForResource("music", ofType: "mp3")
            let audioPath = NSURL(fileURLWithPath: filePath!)
            audioPlayer = try AVAudioPlayer(contentsOfURL: audioPath)
            audioPlayer.prepareToPlay()
        } catch {
            print("Error")
        }
        
        audioPlayer.play()
        
        
        let cellWidth = screenSize.width/CGFloat(maze[0].count)//6
        let cellHeight = screenSize.height/CGFloat(maze.count)//10
        
        let cellOffsetX = screenSize.width/CGFloat(maze[0].count*2)
        let cellOffsetY = screenSize.height/CGFloat(maze.count*2)
        
        for y in 0 ..< maze.count{
            for x in 0 ..< maze[y].count{
                switch maze [y][x]{
                case 1:
                    let wallView = createView(x: x, y: y, width: cellWidth,height: cellHeight,offsetX: cellOffsetX,offsetY: cellOffsetY)
                    wallView.backgroundColor = UIColor.blackColor()
                    view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                case 2:
                    startView = createView(x: x, y: y, width: cellWidth,height: cellHeight,offsetX: cellOffsetX,offsetY: cellOffsetY)
                    startView.backgroundColor = UIColor.greenColor()
                    self.view.addSubview(startView)
                case 3:
                    goalView = createView(x: x, y: y, width: cellWidth,height: cellHeight,offsetX: cellOffsetX,offsetY: cellOffsetY)
                    goalView.backgroundColor = UIColor.redColor()
                    self.view.addSubview(goalView)
                    
                case 4:
                    let wallView = createView(x: x, y: y, width: cellWidth,height: cellHeight,offsetX: cellOffsetX,offsetY: cellOffsetY)
                    wallView.backgroundColor = UIColor.redColor()
                    view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                    
                    
                    
                default:
                    break
                    
                    
                    
                }
            }
            
        }
        
        
        playerView = UIView(frame: CGRectMake(0 , 0, screenSize.width / 36,  screenSize.height / 60))
        playerView.center = startView.center
        playerView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(playerView)
        
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        self.startAccelerometer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createView(x x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat = 0, offsetY: CGFloat = 0)->
        UIView{
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            let view = UIView(frame: rect)
            
            let center = CGPoint(
                x: offsetX + width * CGFloat(x),
                y: offsetY + height * CGFloat(y)
            )
            
            view.center = center
            return view
    }
    
    func startAccelerometer() {
        let handler:CMAccelerometerHandler = {(accelerometerData:CMAccelerometerData?,error:NSError?) -> Void in
            
            self.speedX += accelerometerData!.acceleration.x
            self.speedY += accelerometerData!.acceleration.y
            
            var posX = self.playerView.center.x + (CGFloat(self.speedX) / 3)
            var posY = self.playerView.center.y - (CGFloat(self.speedY) / 3)
            
            if posX <= (self.playerView.frame.width / 2){
                self.speedX = 0
                posX = self.playerView.frame.width / 2
            }
            
            if posY <= (self.playerView.frame.height / 2){
                self.speedY = 0
                posY = self.playerView.frame.height / 2
            }
            
            if posX >= (self.screenSize.width - (self.playerView.frame.width / 2)) {
                self.speedX = 0
                posX = self.screenSize.width - (self.playerView.frame.width / 2)
            }
            
            if posY >= (self.screenSize.height - (self.playerView.frame.height / 2)){
                self.speedY = 0
                posY = self.screenSize.width - (self.playerView.frame.width / 2)
            }
            
            
            
            for wallRect in self.wallRectArray {
                
                if (CGRectIntersectsRect(wallRect, self.playerView.frame)){
                    self.gameCheck("GameOver", message: "壁に当たりました")
                    
                    self.number = self.number+1
                    
                    return
                    
                }
            }
            
            
            if (CGRectIntersectsRect(self.goalView.frame, self.playerView.frame)){
                self.gameCheck("Clear", message: "クリア！！")
                
                self.audioPlayer.stop()
            }
            
            self.playerView.center = CGPointMake(posX, posY)
            
        }
        
        
        playerMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: handler)
        
    }
    
    
    
    private func getTwitterAccount() {
        
        //アカウントを取得するタイプをTwitterに設定する
        let accountType =
            accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        //Twitterのアカウントを取得する
        accountStore.requestAccessToAccountsWithType(accountType, options: nil)
        { (granted:Bool, error:NSError?) -> Void in
            
            if error != nil {
                // エラー処理
                print("error! \(error)")
                return
            }
            
            if !granted {
                print("error! Twitterアカウントの利用が許可されていません")
                return
            }
            
            // Twitterアカウント情報を取得
            let accounts = self.accountStore.accountsWithAccountType(accountType)
                as! [ACAccount]
            
            if accounts.count == 0 {
                print("error! 設定画面からアカウントを設定してください")
                return
            }
            
            // ActionSheetを表示
            self.selectTwitterAccount(accounts)
        }
    }
    
    private func selectTwitterAccount(accounts: [ACAccount]) {
        
        // ActionSheetのタイトルとメッセージを設定する
        let alert = UIAlertController(title: "Twitter",
                                      message: "アカウントを選択してください",
                                      preferredStyle: .ActionSheet)
        
        // アカウント選択のActionSheetを表示するボタン
        for account in accounts {
            alert.addAction(UIAlertAction(title: account.username, style: .Default,
                handler: { (action) -> Void in
                    
                    // 選択したTwitterアカウントのデータを変数に格納する
                    print("your select account is \(account)")
                    self.twitterAccount = account
            }))
        }
        
        // 表示する
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    func gameCheck(result:String,message:String){
        if playerMotionManager.accelerometerActive{
            playerMotionManager.stopAccelerometerUpdates()
        }
        
        
        let gameCheckAlert: UIAlertController = UIAlertController(title: result, message: message, preferredStyle: .Alert)
        
        if result == "Clear"{
            
            
            if number >= 4{
                let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
                let params = ["status" : "~Maze Alarm~                        私は、今日、起きられませんでした！！"]
                let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                        requestMethod: .POST,
                                        URL: URL,
                                        parameters: params)
                request.account = twitterAccount
                request.performRequestWithHandler { (responseData, urlResponse, error) -> Void in
                    if error != nil {
                        print("error is \(error)")
                    }
                    
                    
                }
                
            }
            
            
            
            
            let action = UIAlertAction(title: "閉じる", style: .Default) { action in
                self.back()
            }
            gameCheckAlert.addAction(action)
            //alert表示
            self.presentViewController(gameCheckAlert, animated: true, completion: nil)
        }else{
            let action = UIAlertAction(title: "もう一度", style: .Default) { action in
                self.retry()
            }
            
            gameCheckAlert.addAction(action)
            
            // alert表示
             self.presentViewController(gameCheckAlert, animated: true, completion: nil)
            
                     
        }
    }
    
    
    
    
    
    
    func retry(){
        playerView.center = startView.center
        
        if !playerMotionManager.accelerometerActive {
            self.startAccelerometer()
        }
        
        speedX = 0.0
        speedY = 0.0
    }
    
    
    
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil);//時間設定画面に戻る
    }
    
    
    @IBAction func stop(){
        audioPlayer.play()
    }
    
    
}

