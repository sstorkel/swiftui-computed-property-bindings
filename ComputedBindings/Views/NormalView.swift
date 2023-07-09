//
//  NormalView.swift
//  ComputedBindings
//
//  Created by Scott Storkel on 7/8/23.
//

import SwiftUI

// This code represents the naive implementation of a SwiftUI view that's
// going to:
//
//   1. Collect some data from the user
//   2. Send that data to the server and display a ProgressView while waiting for a reply
//   3. Display a "success" alert if the network call is successful, then transition to
//      a "results" view
//   4. Display an "error" alert if the network call is unsuccesful and allow the user to
//      either retry the call or edit their input
//
// There are a few things about this implementation, which are less than ideal. The biggest
// problem is that we're using four completely independent boolean variables (networkInProgressm
// showSuccessAlert, showErrorAlert, readyForResults) to control the visibility of various
// parts of the UI. It would be very easy to forget to update one of these variables or to
// have them end up in an inconsistent state.
//
// With a more complex UI, this situation could become even worse!
//
struct NormalView: View {

    // MARK: - State

    @State var itemName = "Cool New Item"

    @State var itemDescription = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam aliquam, est vel vehicula cursus, metus mauris venenatis odio, id interdum nisi dolor ut sem."

    // true if we're waiting for the network API call to finish, false otherwise
    @State var networkInProgress = false

    // true if the network call succeeded and we should show the success alert
    @State var showSuccessAlert = false

    // true if the network call failed and we need to show the error alert
    @State var showErrorAlert = false

    // true if we're finished with this view and ready to transition to the
    // results views
    @State var readyForResults = false

    // MARK: -

    var body: some View {
        VStack (alignment: .center) {
            VStack (alignment: .leading) {
                Text("Create Item")
                    .font(.title)
                TextField("Item Name", text: $itemName)
                TextEditor(text: $itemDescription)
            }

            ZStack {
                Button {
                    saveChanges()
                } label: {
                    Text(!networkInProgress ? "Save Changes" : " ")
                }
                .frame(minWidth: 248)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .disabled(networkInProgress)

                if networkInProgress {
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .onAppear() {
            // Need to reset the current state in case the user navigates back to this
            // view from the ResultsView
            networkInProgress = false
            showSuccessAlert = false
            showErrorAlert = false
            readyForResults = false
        }
        // Success alert
        .alert("Success!", isPresented: $showSuccessAlert) {
            Button("OK") {
                networkInProgress = false
                showSuccessAlert = false
                readyForResults = true
            }
        } message: {
            Text("Your item was successfully saved.")
        }
        // Error alert
        .alert("Error!", isPresented: $showErrorAlert) {
            Button("Edit", role: .cancel) {
                networkInProgress = false
                showErrorAlert = false
            }
            Button("Retry") {
                saveChanges()
            }
        } message: {
            Text("Unable to save your item. You can either retry or edit the information you entered.")
        }
        // Programmatic navigation to next screen; requires that we're embedded in a NavigationStack view
        .navigationDestination(isPresented: $readyForResults) {
            ResultsView()
        }
        .padding()

    }

    // This function simulates a network call that takes some amount of time to run
    private func saveChanges() {
        networkInProgress = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Randomly decide whether to show the success or error alerts
            showSuccessAlert = Bool.random()
            showErrorAlert = !showSuccessAlert
        }
    }
}

// MARK: -

struct NormalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NormalView()
        }
    }
}
