

import SwiftUI
import OneSignalFramework

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    static var orientationLock: UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        AppDelegate.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        start()
        OneSignal.initialize("b63834e8-a55d-4838-803f-d8f5a8e0ee71", withLaunchOptions: launchOptions)
        OneSignal.Notifications.requestPermission({ accepted in
            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: true)

        return true
    }
    
    private func start() {
        self.window = .init()
        let rootViewController = UIHostingController(rootView: MainTabView())
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
    }
}

