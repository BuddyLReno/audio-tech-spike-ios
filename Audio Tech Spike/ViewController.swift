//
//  ViewController.swift
//  Audio Tech Spike
//
//  Created by Buddy Reno on 2/20/19.
//  Copyright © 2019 Buddy Reno. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealNameLabel: UILabel!
    var avQueuePlayer: AVQueuePlayer?
    var playerItems: [AVPlayerItem] = []
    var playerMetadata: [Episode] = []
    var elapsedEmitter: Timer?
    var queueIndex: Int = 0
    var db: SQLiteDatabase?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var fileUrl: URL?
        do {
            fileUrl = try SQLiteDatabase.createDB()
        } catch let error as Error {
            print("Error creating DB: \(error)")
        }

        do {
            db = try SQLiteDatabase.open(path: fileUrl?.absoluteString ?? "")
            print("Successfully opened db connection")
        } catch let error as Error {
            print("Unable to open database.")
        }

        let episode = db?.episode(id: 1)
        print(episode)
        
//        setupDefaultData()
    }
    
    //MARK: Actions
    @IBAction func setDefaultLabelText(_ sender: UIButton) {
        playerItems.append(AVPlayerItem(url: URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_1.mp3?dest-id=412720")!))
        
        playerItems.append(AVPlayerItem(url: URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_2.mp3?dest-id=412720")!))
        
//        playerItems.append(AVPlayerItem(url: URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_3.mp3?dest-id=412720")!))
//
//        playerItems.append(AVPlayerItem(url: URL(string: "https://traffic.libsyn.com/secure/draudioarchives/02192019_the_dave_ramsey_show_archive_1.mp3?dest-id=412720")!))
        
        
        
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
            
            mealNameLabel.text = playerMetadata[queueIndex].title
            
            startElapsedEmitter()
            setupRemoteCommandCenter()
            setupNowPlaying(trackName: playerMetadata[queueIndex].title as! String)
            
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
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 3.0
        
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
        self.avQueuePlayer?.playImmediately(atRate: 3.0)
        return .success
    }
    
    func mediaControlsPause(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        self.avQueuePlayer?.pause()
        return .success
    }
    
    @objc func playerReachedEnd(notification: NSNotification) {
        queueIndex += 1
        
        var episode: Episode? = db?.episode(id: 1)
        episode?.progress = 100
        episode?.id = 1
        
        do {
            try db?.updateEpisode(episode: episode!)
        } catch let error as Error {
            print("Problem updating record: \(error)")
        }
        
        
        mealNameLabel.text = playerMetadata[queueIndex].title as! String
        setupNowPlaying(trackName: playerMetadata[queueIndex].title as! String)
    }
    
    @objc func stalledPlayback(notification: NSNotification) {
        avQueuePlayer?.playImmediately(atRate: 3.0)
    }
    
    func setupDefaultData() {
        var fileUrl: URL?
        do {
            fileUrl = try SQLiteDatabase.createDB()
        } catch let error as Error {
            print("Error creating DB: \(error)")
        }
        
        do {
            db = try SQLiteDatabase.open(path: fileUrl?.absoluteString ?? "")
            print("Successfully opened db connection")
        } catch let error as Error {
            print("Unable to open database.")
        }
        
        do {
            try db?.dropTable(table: Episode.self)
            print("Dropped table")
        } catch let error as Error {
            print("Error dropping db: \(error)")
        }
        
        do {
            try db?.createTable(table: Episode.self)
            print("created table")
        } catch {
            print(db?.errorMessage)
        }
            
            let episode1 = Episode(id: 1,
                                   hourNumber: 1,
                                   title: "Do You Have Too Much Invested in Vehicles?",
                                   audioUrl:  "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_1.mp3?dest-id=412720",
                duration: 2448, progress: 0)
            
            let episode2 = Episode(
                id: 2,
                hourNumber: 2,
                title: "Keep Your Car and Pay It Off in 2 Years",
                audioUrl:  "https://traffic.libsyn.com/secure/draudioarchives/02202019_the_dave_ramsey_show_archive_2.mp3?dest-id=412720",
                duration: 2441, progress: 0)
            
            
            
            
            
            do {
                try db?.insertEpisode(episode: episode1)
                try db?.insertEpisode(episode: episode2)
                playerMetadata.append(episode1)
                playerMetadata.append(episode2)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        
    }
}

