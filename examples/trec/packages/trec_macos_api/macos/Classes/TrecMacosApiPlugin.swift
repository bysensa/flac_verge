import Cocoa
import FlutterMacOS

public final class TrecMacosApiPlugin: NSObject, FlutterPlugin {

    var applicationActivityChannel: FlutterEventChannel?
    
    init(_ applicationActivityChannel: FlutterEventChannel) {
        self.applicationActivityChannel = applicationActivityChannel
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "trec_macos_api", binaryMessenger: registrar.messenger)
        let applicationActivityChannel = FlutterEventChannel(name: "trec_macos_api/applicationActivity", binaryMessenger: registrar.messenger)
        applicationActivityChannel.setStreamHandler(ApplicationActivityStream())


        let instance = TrecMacosApiPlugin(applicationActivityChannel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
