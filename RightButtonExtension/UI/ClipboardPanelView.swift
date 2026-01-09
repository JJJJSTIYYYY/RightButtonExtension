import SwiftUI
import AppKit
internal import Combine

struct ClipboardPanelView: View {

    @State private var items: [ClipboardItem] = ClipboardStore.shared.items
    @State private var highlightedItem: UUID?

    let onItemsCountChange: ((Int) -> Void)?

    private let timer = Timer.publish(
        every: 0.15,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        ScrollView {
            LazyVStack(
                alignment: .leading,
                spacing: ClipboardUIConfig.rowSpacing
            ) {
                ForEach(items) { item in
                    ClipboardItemRow(
                        item: item,
                        highlightedItem: $highlightedItem
                    ) {
                        items = ClipboardStore.shared.items
                        onItemsCountChange?(items.count)
                    }
                }
            }
            .padding(10)
        }
        .scrollIndicators(.never)
        .frame(width: ClipboardUIConfig.windowWidth)
        .background(Color.white.opacity(0.01))
        .cornerRadius(16)
        .onAppear {
            onItemsCountChange?(items.count)
        }
        .onReceive(timer) { _ in
            withAnimation(.easeOut(duration: 0.15)) {
                items = ClipboardStore.shared.items
                onItemsCountChange?(items.count)
            }
        }
    }
}
