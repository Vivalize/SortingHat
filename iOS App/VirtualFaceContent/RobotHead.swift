/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The RobotHead node.
*/

import Foundation
import SceneKit
import ARKit


class RobotHead: SCNReferenceNode, VirtualFaceContent {
    
    private var originalJawY: Float = 0
    private var originalBrowY: Float = 0

    private lazy var jawNode = childNode(withName: "jaw", recursively: true)!
    private lazy var eyeLeftNode = childNode(withName: "eyeLeft", recursively: true)!
    private lazy var eyeRightNode = childNode(withName: "eyeRight", recursively: true)!

    private lazy var jawHeight: Float = {
        let (min, max) = jawNode.boundingBox
        return max.y - min.y
    }()
    
    private lazy var browHeight: Float = {
        let (min, max) = eyeLeftNode.boundingBox
        return max.y - min.y
    }()
    
    init() {
        guard let url = Bundle.main.url(forResource: "robotHead", withExtension: "scn", subdirectory: "Models.scnassets")
            else { fatalError("missing expected bundle resource") }
        super.init(url: url)!
        self.load()
        originalJawY = jawNode.position.y
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    var readyToSend = true;

    /// - Tag: BlendShapeAnimation
    var blendShapes: [ARFaceAnchor.BlendShapeLocation: Any] = [:] {
        didSet {
//            guard let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
//                let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,
//                let jawOpen = blendShapes[.jawOpen] as? Float
//                else { return }
            guard let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
                let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,
                let browDownLeft = blendShapes[.browDownLeft] as? Float,
                let browDownRight = blendShapes[.browDownRight] as? Float,
                let jawOpen = blendShapes[.jawOpen] as? Float,
                let lipOpen = blendShapes[.mouthClose] as? Float
                else { return }
            let browAvg = (browDownLeft+browDownRight)/2.0
//            let brow1 = (blendShapes[.mouthSmileLeft] ?? 0.0) as! Float
//            let brow2 = (blendShapes[.mouthSmileRight] ?? 0.0) as! Float
//            let brow3 = (brow1 + brow2)/2.0
//            print(brow3)
            eyeLeftNode.scale.z = 1 - eyeBlinkLeft
            eyeRightNode.scale.z = 1 - eyeBlinkRight
            eyeLeftNode.position.y = 10 + 5 * browAvg
            eyeRightNode.position.y = 10 + 5 * browAvg
            jawNode.position.y = originalJawY - jawHeight * jawOpen
            
            
//            print(UInt8(jawOpen*64))
//            serial.send
            
            if (readyToSend) {
                readyToSend = false;
                
                var mouthFinal = 1-lipOpen
                var tipFinal = (browAvg + 0.01)
                var rightEyeFinal = 1-(eyeBlinkLeft + 0.01)
                var leftEyeFinal = 1-(eyeBlinkRight + 0.01)
                
                mouthFinal = (mouthFinal>1 ? 1.0 : mouthFinal)
                tipFinal = (tipFinal>1 ? 1.0 : tipFinal)
                leftEyeFinal = (leftEyeFinal>1 ? 1.0 : leftEyeFinal)
                rightEyeFinal = (rightEyeFinal>1 ? 1.0 : rightEyeFinal)
                
                mouthFinal = (mouthFinal<0 ? 0.0 : mouthFinal)
                tipFinal = (tipFinal<0 ? 0.0 : tipFinal)
                leftEyeFinal = (leftEyeFinal<0 ? 0.0 : leftEyeFinal)
                rightEyeFinal = (rightEyeFinal<0 ? 0.0 : rightEyeFinal)
                
                
//                print("Start")
//                print(mouthFinal)
//                print(tipFinal)
//                print(leftEyeFinal)
//                print(rightEyeFinal)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    serial.sendBytesToDevice([UInt8(mouthFinal*63+0)])
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    serial.sendBytesToDevice([UInt8(tipFinal*63+64)])
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                    serial.sendBytesToDevice([UInt8(leftEyeFinal*63+128)])
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                    serial.sendBytesToDevice([UInt8(rightEyeFinal*63+192)])
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.readyToSend = true;
                }
            }
            
        }
    }
    
    /// - Tag: ARFaceGeometryBlendShapes
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        blendShapes = faceAnchor.blendShapes
    }
}
