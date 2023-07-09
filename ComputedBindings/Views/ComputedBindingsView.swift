//
//  ComputedBindingsView.swift
//  ComputedBindings
//
//  Created by Scott Storkel on 7/8/23.
//

import SwiftUI

// This code creates a SwiftUI view that will:
//
//   1. Collect some data from the user
//   2. Send that data to the server and display a ProgressView while waiting for a reply
//   3. Display a "success" alert if the network call is successful, then transition to
//      a "results" view
//   4. Display an "error" alert if the network call is unsuccesful and allow the user to
//      either retry the call or edit their input
//
// For this version of the code, we're going to define our UI using an enum that represents
// the five different possible states (editing, waiting for the network, showing the success
// alert, showing the error alert, or showing the results view).
//
// One of the challenges with this technique is that the `alert` and `navigationDestination`
// functions need a binding to a boolean value. Unfortunately, Swift property wrappers can't
// currently be applied to computed properties, so we can't just do something like:
//
//    @State currentState: CurrentState = .editing
//    @State var showSuccessAlert: Bool {
//        return currentState == .showSuccessAlert
//    }
//    ...
//    .alert("Success!", isPresented: $showSuccessAlert) { ... }
//
// Luckily, we CAN manually create Bindings on-the-fly to do exactly what we need, based on a
// technique described on Stack Overflow:
//
//    https://stackoverflow.com/questions/59738550/how-to-bind-a-computed-property-in-swiftui
//
// We just need to write a function that looks something like:
//
//    func showSuccessAlertBinding() -> Binding<Bool> {
//        return Binding<Bool>(
//            get: { return currentState == .showSuccessAlert },
//            set: { newValue in /* this binding is effectively read-only */ }
//        )
//    }
//
// And then use it anywhere we might need a binding:
//
//    .alert("Success!", isPresented: showSuccessAlertBinding()) { ... }
//
// We can avoid having to replicate the code for each state by creating a more generic
// version of the showSuccessAlertBinding() function:
//
//    func currentStateMatches(_ desiredState: CurrentState) -> Binding<Bool> {
//        return Binding<Bool>(
//            get: { return currentState == desiredState },
//            set: { newValue in /* this binding is effectively read-only */ }
//        )
//    }
//
struct ComputedBindingsView: View {

    enum CurrentState {
        case editing
        case waitingForNetwork
        case showSuccessAlert
        case showErrorAlert
        case showResults
    }

    // MARK: - State

    @State var itemName = "Cool New Item"

    @State var itemDescription = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam aliquam, est vel vehicula cursus, metus mauris venenatis odio, id interdum nisi dolor ut sem."

    @State var currentState: CurrentState = .editing

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
                    Text(currentState == .editing ? "Save Changes" : " ")
                }
                .frame(minWidth: 248)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .disabled(currentState == .waitingForNetwork)

                if currentState == .waitingForNetwork {
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .onAppear() {
            // Need to reset the current state in case the user navigates back to this
            // view from the ResultsView
            currentState = .editing
        }
        // Success alert
        .alert("Success!", isPresented: currentStateMatches(.showSuccessAlert)) {
            Button("OK") {
                currentState = .showResults
            }
        } message: {
            Text("Your item was successfully saved.")
        }
        // Error alert
        .alert("Error!", isPresented: currentStateMatches(.showErrorAlert)) {
            Button("Edit", role: .cancel) {
                currentState = .editing
            }
            Button("Retry") {
                saveChanges()
            }
        } message: {
            Text("Unable to save your item. You can either retry or edit the information you entered.")
        }
        // Programmatic navigation to next screen; requires that we're embedded in a NavigationStack view
        .navigationDestination(isPresented: currentStateMatches(.showResults)) {
            ResultsView()
        }
        .padding()

    }

    // This function simulates a network call that takes time to run
    private func saveChanges() {
        currentState = .waitingForNetwork
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Randomly decide whether to show the success or error alerts
            let shouldShowSuccess = Bool.random()
            currentState = shouldShowSuccess ? .showSuccessAlert : .showErrorAlert
        }
    }

    private func currentStateMatches(_ desiredState: CurrentState) -> Binding<Bool> {
        return Binding<Bool>(
            get: { return currentState == desiredState },
            set: { newValue in /* this binding is effectively read-only */ }
        )
    }
}

// MARK: -

struct ComputedBindingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NormalView()
        }
    }
}
