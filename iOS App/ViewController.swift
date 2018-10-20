/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit
import CoreBluetooth
import AVFoundation

class ViewController: UIViewController, ARSessionDelegate, BluetoothSerialDelegate {
    
    // MARK: Outlets

    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet weak var blurView: UIVisualEffectView!
    
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()

    // MARK: Properties

    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }

    var nodeForContentType = [VirtualContentType: VirtualFaceNode]()
    
    let contentUpdater = VirtualContentUpdater()
    
    var selectedVirtualContent: VirtualContentType = .overlayModel {
        didSet {
            // Set the selected content based on the content type.
            contentUpdater.virtualFaceNode = nodeForContentType[selectedVirtualContent]
        }
    }

    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = contentUpdater
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        createFaceGeometry()

        // Set the initial face content, if any.
        contentUpdater.virtualFaceNode = nodeForContentType[selectedVirtualContent]

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        // Initialize Serial
        serial = BluetoothSerial(delegate: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
        
        startVoiceMirroring()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        print(serial.centralManager.state)
    }
    
    //MARK: BluetoothSerialDelegate
    
    func serialDidReceiveString(_ message: String) {
        print("Received String:")
        print(message)
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
            AR experiences typically involve moving the device without
            touch input for some time, so prevent auto screen dimming.
        */
        UIApplication.shared.isIdleTimerDisabled = true
        
        resetTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        session.pause()
    }
    
    // MARK: - Setup
    
    var engine = AVAudioEngine()
//    var distortion = AVAudioUnitDistortion()
//    var reverb = AVAudioUnitReverb()
//    var audioBuffer = AVAudioPCMBuffer()
    var delay = AVAudioUnitDelay()
    var pitchControl = AVAudioUnitTimePitch()
//    var bufferPlayer = AVAudioPlayerNode()
    
    func startVoiceMirroring() {
        
        //Restart Audio Engine
        engine.stop()
        engine.reset()
        engine = AVAudioEngine()
        
        // Setup AVAudioSession
        do {
            try
                AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.spokenAudio, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            
            let ioBufferDuration = 128.0 / 44100.0
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(ioBufferDuration)
            
            
        } catch {
            assertionFailure("AVAudioSession setup error: \(error)")
        }
        
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        
//        input.installTap(onBus: 0, bufferSize: 4096, format: format) {
//            (buffer : AVAudioPCMBuffer!, when : AVAudioTime!) in
//
//            do {
//                self.bufferPlayer.scheduleBuffer(buffer, at: nil)
//                self.bufferPlayer.play()
//                print("IS it doign somethign?")
////                try self.audioFile.write(from: buffer)
//            } catch {
//                print("error \(error.localizedDescription)")
//
//            }
//
//        }
        
//        //settings for reverb
//        reverb.loadFactoryPreset(.mediumChamber)
//        reverb.wetDryMix = 40 //0-100 range
//        engine.attach(reverb)
        
//        delay.delayTime = 0.2 // 0-2 range
//        engine.attach(delay)
        
        pitchControl.pitch = -500 //Rude man voice
        pitchControl.rate = 1.5 //In 1.5 times faster
        engine.attach(pitchControl)
        
        delay.delayTime = 0.5
        delay.feedback = -1.0
        engine.attach(delay)
        
//        bufferPlayer.volume = 1.0
//        engine.attach(bufferPlayer)
        
//        //settings for distortion
//        distortion.loadFactoryPreset(.drumsBitBrush)
//        distortion.wetDryMix = 20 //0-100 range
//        engine.attach(distortion)
        
        
//        engine.connect(input, to: delay, format: format)
//        engine.connect(delay, to: pitchControl, format: format)
//        engine.connect(reverb, to: distortion, format: format)
//        engine.connect(distortion, to: delay, format: format)
//        engine.connect(pitchControl, to: delay, format: format)
        
        engine.connect(input, to: engine.mainMixerNode, format: format)
        
//        engine.connect(input, to: delay, format: format)
//        engine.connect(delay, to: engine.mainMixerNode, format: format)
        
//        engine.connect(input, to: pitchControl, format: format)
//        engine.connect(pitchControl, to: engine.mainMixerNode, format: format)
        
//        engine.connect(bufferPlayer, to: pitchControl, format: format)
//        engine.connect(pitchControl, to: engine.mainMixerNode, format: format)
//        engine.connect(bufferPlayer, to: engine.mainMixerNode, format: format)
        

//
//        // Connect nodes
//        engine.connect(input, to: pitchControl, format: format)
//        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
////        engine.connect(mixer, to: output, format: nil)
////        engine.connect(input, to: output, format: format)
////        engine.connect(input, to: engine.mainMixerNode, format: format)
        
        // Start engine
        do {
            try engine.start()
//            bufferPlayer.play()
        } catch {
            assertionFailure("AVAudioEngine start error: \(error)")
        }
    }
    
    /// - Tag: CreateARSCNFaceGeometry
    func createFaceGeometry() {
        // This relies on the earlier check of `ARFaceTrackingConfiguration.isSupported`.
        let device = sceneView.device!
        let maskGeometry = ARSCNFaceGeometry(device: device)!
        let glassesGeometry = ARSCNFaceGeometry(device: device)!
        
        nodeForContentType = [
            .faceGeometry: Mask(geometry: maskGeometry),
            .overlayModel: GlassesOverlay(geometry: glassesGeometry),
            .blendShapeModel: RobotHead()
        ]
    }
    
    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        blurView.isHidden = false
        statusViewController.showMessage("""
        SESSION INTERRUPTED
        The session will be reset after the interruption has ended.
        """, autoHide: false)
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        blurView.isHidden = true
        
        DispatchQueue.main.async {
            self.resetTracking()
        }
    }
    
    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        statusViewController.showMessage("STARTING A NEW SESSION")
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - Interface Actions

    /// - Tag: restartExperience
    func restartExperience() {
        // Disable Restart button for a while in order to give the session enough time to restart.
        statusViewController.isRestartExperienceButtonEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.statusViewController.isRestartExperienceButtonEnabled = true
        }

        resetTracking()
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension ViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        /*
         Popover segues should not adapt to fullscreen on iPhone, so that
         the AR session's view controller stays visible and active.
        */
        return .none
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
         All segues in this app are popovers even on iPhone. Configure their popover
         origin accordingly.
        */
        guard let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton else { return }
        popoverController.delegate = self
        popoverController.sourceRect = button.bounds

        // Set up the view controller embedded in the popover.
        let contentSelectionController = popoverController.presentedViewController as! ContentSelectionController

        // Set the initially selected virtual content.
        contentSelectionController.selectedVirtualContent = selectedVirtualContent

        // Update our view controller's selected virtual content when the selection changes.
        contentSelectionController.selectionHandler = { [unowned self] newSelectedVirtualContent in
            self.selectedVirtualContent = newSelectedVirtualContent
        }
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionMode(_ input: AVAudioSession.Mode) -> String {
	return input.rawValue
}
