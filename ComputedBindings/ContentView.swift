//
//  ContentView.swift
//  ComputedBindings
//
//  Created by Scott Storkel on 7/8/23.
//

import SwiftUI

struct ContentView: View {
    @State var selectedView = 1

    var body: some View {
        TabView(selection: $selectedView) {
            NavigationStack {
                NormalView()
            }
            .padding()
            .tabItem {
                Label("Normal", systemImage:"1.circle")
            }
            .tag(1)

            NavigationStack {
                ComputedBindingsView()
            }
            .padding()
            .tabItem {
                Label("Bindings", systemImage:"2.circle")
            }
            .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
