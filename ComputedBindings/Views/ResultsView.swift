//
//  ResultsView.swift
//  ComputedBindings
//
//  Created by Scott Storkel on 7/8/23.
//

import SwiftUI

struct ResultsView: View {
    var body: some View {
        VStack {
            Text("Results View")
                .font(.title)
                .padding()

            Text("This is the screen where we'd show you the results of creating a new item.")
        }
        .padding()
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}
