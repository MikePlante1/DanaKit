import LoopKitUI
import SwiftUI

struct DanaKitPasswordEntryView: View {
    @Environment(\.dismissAction) private var dismiss
    @Environment(\.appName) var appName

    @State private var passwordText: String = ""
    @State private var showError: Bool = false

    let nextAction: (UInt16) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section {
                    Text(String(
                        format: LocalizedString(
                            "Enter the 4-digit Bluetooth password set on your DanaRS v1/v2 pump. The default password is 1234.",
                            comment: "DanaRS v1 password entry instruction"
                        )
                    ))

                    Text(LocalizedString(
                        "On your pump: Menu → Etc → BT Pairing Password",
                        comment: "DanaRS v1 pump navigation hint"
                    ))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }

                Section(header: SectionHeader(label: LocalizedString("Pump Password", comment: "DanaRS v1 password section header"))) {
                    TextField(LocalizedString("4-digit password (e.g. 1234)", comment: "DanaRS v1 password field placeholder"), text: $passwordText)
                        .keyboardType(.numberPad)

                    if showError {
                        Text(LocalizedString("Please enter a valid 4-digit password (0000–9999).", comment: "DanaRS v1 password validation error"))
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
            }
            .insetGroupedListStyle()

            Spacer()

            ContinueButton(action: submit)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(false)
        .navigationTitle(LocalizedString("Setting up DanaRS v1/v2", comment: "Title for DanaRS v1 password entry view"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(LocalizedString("Cancel", comment: "Cancel button title"), action: {
                    self.dismiss()
                })
            }
        }
    }

    private func submit() {
        // The pump encodes the password as BCD: "2345" → 0x2345.
        // Parsing the user's input with radix 16 produces the same value.
        let digits = passwordText.filter { $0.isNumber }
        guard digits == passwordText, !passwordText.isEmpty, passwordText.count <= 4 else {
            showError = true
            return
        }
        let padded = String(repeating: "0", count: 4 - passwordText.count) + passwordText
        guard let value = UInt16(padded, radix: 16) else {
            showError = true
            return
        }
        showError = false
        nextAction(value)
    }
}

#Preview {
    DanaKitPasswordEntryView(nextAction: { _ in })
}
