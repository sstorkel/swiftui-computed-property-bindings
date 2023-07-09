
# Bindings for Computed Properties in SwiftUI

This is a simple project that shows how to implement Swift UI bindings for computed properties.

This is slightly difficult because the `@State` property wrapper can't be applied to computed properties.

```
    @State var showErrorAlert: Bool {     // Error: Property wrapper cannot be applied to a computed property
        return currentState == .showErrorAlert
    }
```

A little googling turned up this question on Stack Overflow: 

https://stackoverflow.com/questions/59738550/how-to-bind-a-computed-property-in-swiftui

Which explains how to create Bindings that can do exactly what we need. So, for example, if we need a `Binding<Bool>` that returns `true` when our `currentState` variable has a particular value we can do something like:

```
    .alert("Network Error!", isPresented: Binding<Bool>(
        get: { return currentState == .showErrorAlert },
        set: { newValue in /* ignore; this binding is effectively read-only */ }
    ) {
        ...
    }
```

The example code here shows two different approaches to creating the same View:

**`NormalView.swift`:** shows a naive approach, where we have a number of different `Bool` properties that we use for `@State` and bindings. This approach is easier, because we can use the standard binding syntax (`$var`), but it's also error-prone: it would be very easy to forget to update one of the boolean properties and introduce bugs.

**`ComputedBindingsView.swift`:** takes the View from `NormalView.swift` and replaces all of the `Bool` properties with a single `CurrentState` enum. It then drives the UI configuration from this enum and creates computed `Bool` bindings on-the-fly where necessary to make the UI work.

