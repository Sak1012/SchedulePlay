import SwiftUI

struct MenuLabelView: View {
    @ObservedObject var model: StatusItemViewModel

    var body: some View {
        switch model.menuLabelContent {
        case .icon:
            Image(systemName: "calendar")
        case .text(let value):
            Text(value)
                .lineLimit(1)
                .truncationMode(.tail)
                .monospacedDigit()
        }
    }
}
