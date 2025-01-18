//
//  LivePollsApp.swift
//  LivePolls
//
//  Created by Efe Koç on 09/07/23.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase uygulamasını yapılandırma
        FirebaseApp.configure()
        
        // Firestore ayarlarını yapılandırma
        let firestore = Firestore.firestore()
        let settings = firestore.settings
        settings.cacheSettings = MemoryCacheSettings() // Bellek önbellek ayarlarını etkinleştir
        firestore.settings = settings
        
        return true
    }
}

@main
struct LivePollsApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var isUserLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if Auth.auth().currentUser != nil {
                    // Eğer kullanıcı oturumu açık ise direkt olarak ana sayfaya yönlendir
                    HomeView()
                        .onAppear {
                            isUserLoggedIn = true
                        }
                } else {
                    // Kullanıcı oturumu kapalı ise Login sayfası
                    LoginView()
                        .onAppear {
                            isUserLoggedIn = false
                        }
                }
            }
        }
    }
}
