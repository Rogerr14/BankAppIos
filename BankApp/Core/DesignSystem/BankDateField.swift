import SwiftUI

struct BankDateField: View {
    let title: String
    @Binding var selection: Date?
    var allowedRange: ClosedRange<Date>? = nil
    var isRequired = false
    var errorMessage: String? = nil
    var allowsClear = true
    @State private var showsPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title + (isRequired ? " *" : "")).font(.subheadline.weight(.semibold))
            HStack {
                Button { showsPicker = true } label: {
                    HStack {
                    Text(selection?.displayDate ?? "Seleccionar fecha").foregroundStyle(selection == nil ? AppColors.muted : AppColors.ink)
                    Spacer()
                    Image(systemName: "calendar").foregroundStyle(AppColors.brand)
                    }.contentShape(Rectangle())
                }.buttonStyle(.plain)
                if selection != nil && allowsClear {
                    Button { selection = nil } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(AppColors.muted) }
                        .buttonStyle(.plain).accessibilityLabel("Limpiar \(title)")
                }
            }.padding(.horizontal, 15).frame(height: 54).background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14))
            if let errorMessage { Text(errorMessage).font(.caption).foregroundStyle(.red) }
        }
        .sheet(isPresented: $showsPicker) {
            NavigationStack {
                Group {
                    if let allowedRange {
                        DatePicker(title, selection: Binding(get: { selection ?? allowedRange.lowerBound }, set: { selection = $0 }), in: allowedRange, displayedComponents: .date)
                    } else {
                        DatePicker(title, selection: Binding(get: { selection ?? Date() }, set: { selection = $0 }), displayedComponents: .date)
                    }
                }.datePickerStyle(.graphical).padding()
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Listo") { showsPicker = false } } }
            }.presentationDetents([.medium])
        }
    }
}
