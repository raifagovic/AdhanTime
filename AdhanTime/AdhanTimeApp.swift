//
//  AdhanTimeApp.swift
//  AdhanTime
//
//  Created by Raif Agovic on 18. 3. 2024..
//

import SwiftUI

@main
struct AdhanTimeApp: App {
    @StateObject private var viewModel = StatusBarViewModel.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(viewModel)
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            HStack {
                Image(systemName: "star.circle.fill") // Use a suitable SF Symbol
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 10)
                Spacer().frame(width: 10)
                Text(viewModel.statusBarTitle)
            }
        }
        .menuBarExtraStyle(.window) // Use the window style for rounded corners
    }
}
