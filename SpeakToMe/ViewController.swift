/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The primary view controller. The speech-to-text engine is managed an configured here.
*/

import UIKit
import Speech
import Firebase


public class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    // MARK: Properties
    
    private var exercises = [Exercise]()
    
    private var exerciseIndex = 0
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet var textView : UITextView!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet var onButton : UIButton!
    
    @IBOutlet var readButton : UIButton!
    
    @IBOutlet weak var dbtextview: UITextView!
    
    //convenience init() {
      //  super.init()
        //FirebaseApp.configure()
        //Database.database().isPersistenceEnabled = true

    //}
    
   // required public convenience init?(coder aDecoder: NSCoder) {
//        self.init()
//        FirebaseApp.configure()
//        Database.database().isPersistenceEnabled = true
//    }
    
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        print("App started!")

        // Disable the record buttons until authorization has been granted.
        recordButton.isEnabled = false
        
        
        
       // let rootNode = Database.database().reference()
//        let exercisesNode = Database.database().reference().child("Exercises")
//        exercisesNode.observe(.childAdded) { (snapshot: DataSnapshot) in
//            let exerciseID = snapshot.key
//            let exercise = Exercise(id: exerciseID, dictionary: snapshot.value as AnyObject)
//            self.exercises.append(exercise)
//            DispatchQueue.main.async {
//                self.textView.text = "Hello!" //(in: exercise)
//            }
//        }
        
        
        
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
                The callback may not be called on the main thread. Add an
                operation to the main queue to update the record button's state.
            */
            OperationQueue.main.addOperation {
                switch authStatus {
                    case .authorized:
                        self.recordButton.isEnabled = true

                    case .denied:
                        self.recordButton.isEnabled = false
                        self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)

                    case .restricted:
                        self.recordButton.isEnabled = false
                        self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)

                    case .notDetermined:
                        self.recordButton.isEnabled = false
                        self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
     private func startRecording() throws {
        print("Start recording")
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            print("About to listen")
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                print("Listening")
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        //textView.text = "(Okay Speak Now...)"
    }

    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    // MARK: Interface Builder actions
    
    @IBAction func recordButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
        } else {
            try! startRecording()
            recordButton.setTitle("Stop recording", for: [])
        }
    }
    
//    @IBAction func onButton(_ sender: UIButton ) {
//        if sender == self {
//            if exerciseIndex + 1 < exercises.count {
//                exerciseIndex = exerciseIndex + 1
//            //    textView.text
//                
//            }
//        }
//    }
    
}

