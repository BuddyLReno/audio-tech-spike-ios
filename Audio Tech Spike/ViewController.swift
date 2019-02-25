//
//  ViewController.swift
//  Audio Tech Spike
//
//  Created by Buddy Reno on 2/20/19.
//  Copyright © 2019 Buddy Reno. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import MediaPlayer
import CoreData
import SwiftHTTP

class ViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealNameLabel: UILabel!
    var avQueuePlayer: AVQueuePlayer?
    var playerItems: [AVPlayerItem] = []
    var playerMetadata: [NSManagedObject] = []
    var elapsedEmitter: Timer?
    var queueIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let params = ["device": "ios", "deviceName" : "SwiftHTTP", "feedback": "Hello World", "userAgent": "Fake User Agemt", "osVersion": "12.2", "deviceId": "1234567890", "email": "spencer.jameson@daveramsey.com"]
        HTTP.POST("https://www.daveramsey.com/show/api/feedback/submit", parameters: params) { response in
            //do things...
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Episode")
        
        do {
            playerMetadata = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Actions
    @IBAction func setDefaultLabelText(_ sender: UIButton) {
        playerItems.append(AVPlayerItem(url: URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_1.mp3?dest-id=412720")!))
        
        playerItems.append(AVPlayerItem(url: URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_2.mp3?dest-id=412720")!))
        
        playerItems.append(AVPlayerItem(url: URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_3.mp3?dest-id=412720")!))
        
        playerItems.append(AVPlayerItem(url: URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02192019_the_dave_ramsey_show_archive_1.mp3?dest-id=412720")!))
        
        if (playerMetadata.count <= 0) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Episode", in: managedContext)!
            
            let episode1 = NSManagedObject(entity: entity, insertInto: managedContext)
            let episode2 = NSManagedObject(entity: entity, insertInto: managedContext)
            let episode3 = NSManagedObject(entity: entity, insertInto: managedContext)
            let episode4 = NSManagedObject(entity: entity, insertInto: managedContext)
            
            episode1.setValue(URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_1.mp3?dest-id=412720"), forKeyPath: "audioUrl")
            
            let dateString = "2019-02-20T00:00:00Z" // the date string to be parsed
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
            let date = df.date(from: dateString)
            episode1.setValue(date, forKeyPath: "broadcastOn")
            
            episode1.setValue(2448, forKeyPath: "duration")
            episode1.setValue(UUID(uuidString: "92032ee108a745408a61bc198e9ee862"), forKeyPath: "guid")
            episode1.setValue(1, forKeyPath: "hourNumber")
            episode1.setValue(0, forKeyPath: "playState")
            episode1.setValue(0, forKeyPath: "progress")
            episode1.setValue("Do You Have Too Much Invested in Vehicles?", forKeyPath: "title")
            episode1.setValue(URL(string: "https://www.youtube.com/watch?v=fFKnn1XG7V0&t=1"), forKeyPath: "videoUrl")
            
            episode2.setValue(URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_2.mp3?dest-id=412720"), forKeyPath: "audioUrl")
            
            episode2.setValue(2441, forKeyPath: "duration")
            episode2.setValue(UUID(uuidString: "64b76488d9d74d5293f256bbde2d9329"), forKeyPath: "guid")
            episode2.setValue(2, forKeyPath: "hourNumber")
            episode2.setValue(0, forKeyPath: "playState")
            episode2.setValue(0, forKeyPath: "progress")
            episode2.setValue("Keep Your Car and Pay It Off in 2 Years", forKeyPath: "title")
            episode2.setValue(URL(string: "https://www.youtube.com/watch?v=fFKnn1XG7V0&t=3601"), forKeyPath: "videoUrl")
            
            episode3.setValue(URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_3.mp3?dest-id=412720"), forKeyPath: "audioUrl")
            
            episode3.setValue(2441, forKeyPath: "duration")
            episode3.setValue(UUID(uuidString: "520884dbf4e4455c862f6e6b66b54aad"), forKeyPath: "guid")
            episode3.setValue(3, forKeyPath: "hourNumber")
            episode3.setValue(0, forKeyPath: "playState")
            episode3.setValue(0, forKeyPath: "progress")
            episode3.setValue("Dramatic Change Leads to Dramatic Wealth", forKeyPath: "title")
            episode3.setValue(URL(string: "https://www.youtube.com/watch?v=fFKnn1XG7V0&t=7201"), forKeyPath: "videoUrl")
            
            episode4.setValue(URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02192019_the_dave_ramsey_show_archive_1.mp3?dest-id=412720"), forKeyPath: "audioUrl")
            
            let dateString2 = "2019-02-19T00:00:00Z" // the date string to be parsed
            let df2 = DateFormatter()
            df2.locale = Locale(identifier: "en_US_POSIX")
            df2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
            let date2 = df2.date(from: dateString2)
            episode1.setValue(date2, forKeyPath: "broadcastOn")
            
            episode4.setValue(2448, forKeyPath: "duration")
            episode4.setValue(UUID(uuidString: "eed06a9bca6a4e729510771ddc76fbf3"), forKeyPath: "guid")
            episode4.setValue(1, forKeyPath: "hourNumber")
            episode4.setValue(0, forKeyPath: "playState")
            episode4.setValue(0, forKeyPath: "progress")
            episode4.setValue("Marrying Someone With a Lot of Debt", forKeyPath: "title")
            episode4.setValue(URL(string: "https://www.youtube.com/watch?v=0Qwt5ksf0w0&t=1"), forKeyPath: "videoUrl")
            
            do {
                try managedContext.save()
                playerMetadata.append(episode1)
                playerMetadata.append(episode2)
                playerMetadata.append(episode3)
                playerMetadata.append(episode4)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        playRemoteFile()
    }
    
    func playRemoteFile() {
        print("Playing queue")
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            avQueuePlayer = AVQueuePlayer(items: playerItems)
            avQueuePlayer?.automaticallyWaitsToMinimizeStalling = false
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerReachedEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(stalledPlayback), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
            
            avQueuePlayer?.playImmediately(atRate: 5.0)
            
            mealNameLabel.text = playerMetadata[queueIndex].value(forKeyPath: "title") as! String
            
            startElapsedEmitter()
            setupRemoteCommandCenter()
            setupNowPlaying(trackName: playerMetadata[queueIndex].value(forKeyPath: "title") as! String)
            
        } catch {
            print(error)
        }
    }
    
    func startElapsedEmitter() {
        elapsedEmitter = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: elapsedTick)
    }
    
    func elapsedTick(timer: Timer) {
        let elapsed: CMTime? = avQueuePlayer?.currentItem?.currentTime()
        print(elapsed?.seconds)
    }
    
    func setupNowPlaying(trackName: String) {
        if (avQueuePlayer?.currentItem?.status != AVPlayerItem.Status.readyToPlay) {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer: Timer) -> Void in
                self.setupNowPlaying(trackName: trackName)
                return
            })
            return
        }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = trackName
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = avQueuePlayer?.currentItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = avQueuePlayer?.currentItem?.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 5.0
        
        //Set metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(handler: mediaControlsPlay)
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(handler: mediaControlsPause)
        
    }
    
    func mediaControlsPlay(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus  {
        self.avQueuePlayer?.playImmediately(atRate: 5.0)
        return .success
    }
    
    func mediaControlsPause(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        self.avQueuePlayer?.pause()
        return .success
    }
    
    @objc func playerReachedEnd(notification: NSNotification) {
        queueIndex += 1
        
        mealNameLabel.text = playerMetadata[queueIndex].value(forKeyPath: "title") as! String
        setupNowPlaying(trackName: playerMetadata[queueIndex].value(forKeyPath: "title") as! String)
    }
    
    @objc func stalledPlayback(notification: NSNotification) {
        avQueuePlayer?.playImmediately(atRate: 5.0)
    }
}

