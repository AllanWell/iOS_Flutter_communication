//
//  ViewController.swift
//  iOS_demo
//
//  Created by 危能 on 2019/3/27.
//  Copyright © 2019 AllanWell. All rights reserved.
//

import UIKit
import Flutter

class ViewController: UIViewController {
    
    @IBOutlet weak var basicSendInput: UITextField!
    @IBOutlet weak var basicSendReplyLabel: UILabel!
    
    @IBOutlet weak var basicReplyLabel: UILabel!
    
    @IBOutlet weak var eventSendInput: UITextField!
    @IBOutlet weak var eventReveiveLabel: UILabel!
    
    @IBOutlet weak var methodChannelReveiveLabel: UILabel!
    @IBOutlet weak var methodChannelDoneLabel: UILabel!
    
    
    var flutterViewController: FlutterViewController!
    
    var basicMessageChannel_flutter2iOS: FlutterBasicMessageChannel!
    var basicMessageChannel_iOS2flutter: FlutterBasicMessageChannel!
    
    var eventChannel: FlutterEventChannel!
    var eventSink: FlutterEventSink!
    
    var methodChannel: FlutterMethodChannel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "flutter" {
            flutterViewController = (segue.destination as! FlutterViewController)
            flutterViewController.setInitialRoute("Hello_From_iOS")
            setupBasicMessageChannel()
            setupEventChannel()
            setupMethodChannel()
        }
    }
    
    func setupBasicMessageChannel() {
        basicMessageChannel_flutter2iOS = FlutterBasicMessageChannel(name: "BasicMessageChannel_flutter2iOS", binaryMessenger: flutterViewController, codec: FlutterStringCodec.sharedInstance())
        basicMessageChannel_flutter2iOS.setMessageHandler { (message, reply) in
            guard let message = message as? String else {
                fatalError("message is not String type")
            }
            self.basicReplyLabel.text = message
            reply(message  + "<-iOS")
        }
        
        basicMessageChannel_iOS2flutter = FlutterBasicMessageChannel(name: "BasicMessageChannel_iOS2flutter", binaryMessenger: flutterViewController, codec: FlutterStringCodec.sharedInstance())
        
    }
    
    func setupEventChannel() {
        eventChannel = FlutterEventChannel(name: "EventChannel", binaryMessenger: flutterViewController)
        eventChannel.setStreamHandler(self)
    }
    
    func setupMethodChannel() {
        methodChannel = FlutterMethodChannel(name: "MethodChannel", binaryMessenger: flutterViewController)
        methodChannel.setMethodCallHandler { (call, result) in
            self.methodChannelReveiveLabel.text = "\(call.method), \(call.arguments ?? "empty")"
            result("Hello")
        }
        
    }
    
    
    @IBAction func basicSendBtnClick(_ sender: UIButton) {
        if let text = self.basicSendInput.text {
            basicMessageChannel_iOS2flutter.sendMessage(text) { (messageReplay) in
                guard let messageReplay = messageReplay as? String else {
                    fatalError("message is not String type")
                }
                self.basicSendReplyLabel.text = messageReplay
            }
        }
    }
    
    @IBAction func eventSenBtnClick(_ sender: UIButton) {
        if let text = self.eventSendInput.text {
            eventSink(text)
        }
    }
    
    @IBAction func methodChannelBtnClick(_ sender: UIButton) {
        methodChannel.invokeMethod("flutter_method", arguments: "Hello_Flutter") { (message) in
            if (message != nil) {
                self.methodChannelDoneLabel.isHidden = false
            }
        }
    }
    
    
}

extension ViewController: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    
}
