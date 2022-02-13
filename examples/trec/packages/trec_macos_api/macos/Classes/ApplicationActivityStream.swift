//
//  ApplicationActivityStream.swift
//  trec_macos_api
//
//  Created by Sergey Sen on 12.02.2022.
//

import Foundation
import FlutterMacOS
import Combine



final class ApplicationActivityStream: NSObject, FlutterStreamHandler {

    private var sink: FlutterEventSink?
    private var subscriptions: Set<AnyCancellable> = Set()
    private var encode: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.sink = events
        setupActivityObservation()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.sink = nil
        subscriptions.removeAll()
        return nil
    }
    
    // MARK: Setup
    func setupActivityObservation() {
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification).sink(receiveValue: onApplicationActivate).store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didDeactivateApplicationNotification).sink(receiveValue: onApplicationDeactivate).store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didHideApplicationNotification).sink(receiveValue: onApplicationHide).store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didUnhideApplicationNotification).sink(receiveValue: onApplicationUnhide).store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didLaunchApplicationNotification).sink(receiveValue: onApplicationLaunch).store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didTerminateApplicationNotification).sink(receiveValue: onApplicationTerminate).store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification).sink(receiveValue: onWake).store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.screensDidSleepNotification).sink(receiveValue: onSleep).store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.willPowerOffNotification).sink(receiveValue: onPowerOff).store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.activeSpaceDidChangeNotification).sink(receiveValue: onChangeSpace).store(in: &subscriptions)
        DistributedNotificationCenter.default().publisher(for: .init("com.apple.screenIsLocked")).sink(receiveValue: onLock).store(in: &subscriptions)
        DistributedNotificationCenter.default().publisher(for: .init("com.apple.screenIsUnlocked")).sink(receiveValue: onUnlock).store(in: &subscriptions)
    }
    
    
    // MARK: On Activate
    func onApplicationActivate(_ notification: Notification) {
        if let sink = sink {
            guard let app = processNotification(notification) else {
                return
            }
            let activity = PlatformActivity.ApplicationActivate(at: Date(), application: app)
            let encodedActivity = try! self.encode.encode(activity)
            sink(encodedActivity)
        }
    }
    
    // MARK: On Deactivate
    func onApplicationDeactivate(_ notification: Notification) {
        if let sink = sink {
            guard let app = processNotification(notification) else {
                return
            }
            let activity = PlatformActivity.ApplicationDeactivate(at: Date(), application: app)
            let encodedActivity = try! self.encode.encode(activity)
            sink(encodedActivity)
        }
    }
    
    // MARK: On Hide
    func onApplicationHide(_ notification: Notification) {
        if let sink = sink {
            guard let app = processNotification(notification) else {
                return
            }
            let activity = PlatformActivity.ApplicationHide(at: Date(), application: app)
            let encodedActivity = try! self.encode.encode(activity)
            sink(encodedActivity)
        }
    }
    
    // MARK: On Unhide
    func onApplicationUnhide(_ notification: Notification) {
        if let sink = sink {
            guard let app = processNotification(notification) else {
                return
            }
            let activity = PlatformActivity.ApplicationUnhide(at: Date(), application: app)
            let encodedActivity = try! self.encode.encode(activity)
            sink(encodedActivity)
        }
    }
    
    // MARK: On Launch
    func onApplicationLaunch(_ notification: Notification) {
        if let sink = sink {
            guard let app = processNotification(notification) else {
                return
            }
            let activity = PlatformActivity.ApplicationLaunch(at: Date(), application: app)
            let encodedActivity = try! self.encode.encode(activity)
            sink(encodedActivity)
        }
    }
    
    // MARK: On Terminate
    func onApplicationTerminate(_ notification: Notification) {
        if let sink = sink {
            guard let app = processNotification(notification) else {
                return
            }
            let activity = PlatformActivity.ApplicationTerminate(at: Date(), application: app)
            let encodedActivity = try! self.encode.encode(activity)
            sink(encodedActivity)
        }
    }
    
    // MARK: On Sleep
    func onSleep(_ notification: Notification) {
        guard let sink = sink else { return }
        let activity = PlatformActivity.Sleep(at: Date())
        let encodedActivity = try! self.encode.encode(activity)
        sink(encodedActivity)
    }
    
    // MARK: On Wake
    func onWake(_ notification: Notification) {
        guard let sink = sink else { return }
        let activity = PlatformActivity.Wake(at: Date())
        let encodedActivity = try! self.encode.encode(activity)
        sink(encodedActivity)
    }
    
    // MARK: On Power off
    func onPowerOff(_ notification: Notification) {
        guard let sink = sink else { return }
        let activity = PlatformActivity.PowerOff(at: Date())
        let encodedActivity = try! self.encode.encode(activity)
        sink(encodedActivity)
    }
    
    // MARK: On Change Space
    func onChangeSpace(_ notification: Notification) {
        guard let sink = sink else { return }
        let activity = PlatformActivity.ChangeSpace(at: Date())
        let encodedActivity = try! self.encode.encode(activity)
        sink(encodedActivity)
    }
    
    // MARK: On Lock
    func onLock(_ notification: Notification) {
        guard let sink = sink else { return }
        let activity = PlatformActivity.Lock(at: Date())
        let encodedActivity = try! self.encode.encode(activity)
        sink(encodedActivity)
    }
    
    // MARK: On Unlock
    func onUnlock(_ notification: Notification) {
        guard let sink = sink else { return }
        let activity = PlatformActivity.Unlock(at: Date())
        let encodedActivity = try! self.encode.encode(activity)
        sink(encodedActivity)
    }
    
    
    private func processNotification(_ notification: Notification) -> PlatformActivity.Application? {
        if notification.userInfo != nil {
            return notification.userInfo!.values.filter { $0 is NSRunningApplication }.map { $0 as! NSRunningApplication }.map { application -> PlatformActivity.Application in
                return PlatformActivity.Application(name: application.appName, bundleId: application.bundleId, processId: application.processId)
            }.first ?? nil
        }
        return nil
    }
    
    deinit {
        subscriptions.removeAll()
    }
}



protocol Activity: Encodable {}

class PlatformActivity {
    
    struct ApplicationActivate: Activity {
        let type: String = "activate"
        let at: Date
        let application: Application
    }
    
    
    struct ApplicationDeactivate: Activity {
        let type: String = "deactivate"
        let at: Date
        let application: Application
    }
    
    
    struct ApplicationHide: Activity {
        let type: String = "hide"
        let at: Date
        let application: Application
    }
    
    
    struct ApplicationUnhide: Activity {
        let type: String = "unhide"
        let at: Date
        let application: Application
    }
    
    
    struct ApplicationLaunch: Activity {
        let type: String = "launch"
        let at: Date
        let application: Application
    }
    
    
    struct ApplicationTerminate: Activity {
        let type: String = "terminate"
        let at: Date
        let application: Application
    }
    
    struct Sleep: Activity {
        let type: String = "sleep"
        let at: Date
    }
    
    struct Wake: Activity  {
        let type: String = "wake"
        let at: Date
    }
    
    struct PowerOff: Activity  {
        let type: String = "powerOff"
        let at: Date
    }
    
    struct ChangeSpace: Activity  {
        let type: String = "changeSpace"
        let at: Date
    }
    
    struct Lock: Activity  {
        let type: String = "lock"
        let at: Date
    }
    
    struct Unlock: Activity  {
        let type: String = "unlock"
        let at: Date
    }
}

extension PlatformActivity {
    struct Application: Encodable {
        let name: String
        let bundleId: String
        let processId: Int32
    }

}


extension NSRunningApplication {
    var appName: String {
        return localizedName ?? "Unknown"
    }
    
    var bundleId: String {
        return bundleIdentifier ?? "unknown"
    }
    
    var processId: Int32 {
        return processIdentifier
    }
}
