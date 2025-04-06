import SwiftUI

struct NumberField: UIViewRepresentable {
    @Binding var value: Double
    let formatter: NumberFormatter
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        context.coordinator.textField = textField
        textField.keyboardType = .decimalPad
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 72, weight: .bold)
        textField.delegate = context.coordinator
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: textField, action: #selector(UIResponder.resignFirstResponder))
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = formatter.string(from: NSNumber(value: value))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {        
        var parent: NumberField
        weak var textField: UITextField?
        
        init(_ parent: NumberField) {
            self.parent = parent
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.selectAll(nil)
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // Allow empty text
            if updatedText.isEmpty {
                parent.value = 0
                return true
            }
            
            // Allow decimal point if there isn't one already
            if string == "." && !currentText.contains(".") {
                return true
            }
            
            // Check if the resulting text would be a valid number
            if let _ = Double(updatedText) {
                if let number = parent.formatter.number(from: updatedText)?.doubleValue {
                    parent.value = number
                }
                return true
            }
            
            return false
        }
    }
}
