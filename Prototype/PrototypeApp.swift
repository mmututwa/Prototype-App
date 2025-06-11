//
//  PrototypeApp.swift
//  Prototype
//
//  Created by Mututwa Mututwa on 2/23/25.
//

import SwiftUI

@main
struct PrototypeApp: App {
    @StateObject private var authService = AuthenticationService()
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environmentObject(authService)
        }
    }
}

struct AppCoordinatorView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
            } else {
                AuthenticationView()
                    .environmentObject(authService)
            }
        }
    }
}
