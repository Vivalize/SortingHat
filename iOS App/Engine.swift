//  Created by Marko Ritachka on 10/04/2018
//  Copyright © Marko Ritachka 2018. All rights reserved. 
//  Engine file shown for quick reference, export for full code

// MARK: Imports

import AVFoundation
import UIKit

// MARK: Engine Class

class Engine
{

// MARK: Properties

	// Engine
	var engine:AVAudioEngine!

	// Microphone
	var unitnodemic:AVAudioInputNode!

	var unitnodepitch:AVAudioUnitTimePitch!

	var unitnodedelay:AVAudioUnitDelay!

	// Output
	var unitnthStatePhoniqueDefaultOutput:AVAudioOutputNode!


// MARK: Initalization

	init()
	{
		engine = AVAudioEngine()
		buildNodes()
	}

// MARK: Start/Stop

	func start()
	{
		engine.reset()

		attachNodes()
		tapNodes()
		preConfigureNodes()
		connectNodes()

		try! engine.start()

		postConfigureNodes()
	}

	func stop()
	{
		stopNodes()
		unTapNodes()

		engine.stop()
	}

// MARK: Build Nodes

	func buildNodes()
	{
		unitnodemic = engine.inputNode
		buildunitnodepitch()
		buildunitnodedelay()
		buildunitnthStatePhoniqueDefaultOutput()
		unitnthStatePhoniqueDefaultOutput = engine.outputNode
	}

	func buildunitnodepitch()
	{
		unitnodepitch = AVAudioUnitTimePitch()
		unitnodepitch.overlap = 8.00
		unitnodepitch.pitch = 0.00
		unitnodepitch.rate = 1.00
		unitnodepitch.bypass = false
	}

	func buildunitnodedelay()
	{
		unitnodedelay = AVAudioUnitDelay()
		unitnodedelay.delayTime = 0.25
		unitnodedelay.feedback = 0.00
		unitnodedelay.lowPassCutoff = 10.00
		unitnodedelay.wetDryMix = 0.00
		unitnodedelay.bypass = false
	}

	func buildunitnthStatePhoniqueDefaultOutput()
	{
	}

// MARK: Attach Nodes

	func attachNodes()
	{
		engine.attach(unitnodepitch)
		engine.attach(unitnodedelay)
	}

// MARK: Connect Nodes

	func connectNodes()
	{
		engine.connect(unitnodemic, to:unitnodepitch, format:engine.mainMixerNode.outputFormat(forBus: 0))
		engine.connect(unitnodepitch, to:unitnodedelay, format:engine.mainMixerNode.outputFormat(forBus: 0))
		engine.connect(unitnodedelay, to:unitnthStatePhoniqueDefaultOutput, format:engine.mainMixerNode.outputFormat(forBus: 0))
	}

// MARK: Tap Nodes

	func tapNodes()
	{
	}

// MARK: Pre-Configure Nodes

	func preConfigureNodes()
	{
	}

// MARK: Post Configure Nodes

	func postConfigureNodes()
	{
	}

// MARK: Stop Nodes

	func stopNodes()
	{
		stopunitnodepitch()
		stopunitnodedelay()
		stopunitnthStatePhoniqueDefaultOutput()
	}

	func stopunitnodepitch()
	{
	}

	func stopunitnodedelay()
	{
	}

	func stopunitnthStatePhoniqueDefaultOutput()
	{
	}

// MARK: Un-Tap Nodes

	func unTapNodes()
	{
	}

}
