import SwiftUI

struct ClipboardItemRow: View {

    let item: ClipboardItem
    @Binding var highlightedItem: UUID?
    let onPasteFinished: () -> Void

    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            Text(item.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
                .truncationMode(.tail)

            HStack(spacing: 6) {
                if let app = item.sourceApp {
                    Text(app)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(item.date, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .frame(
            maxWidth: .infinity,
            minHeight: ClipboardUIConfig.rowHeight,
            maxHeight: ClipboardUIConfig.rowHeight,
            alignment: .leading     // 水平左对齐 + 垂直居中
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    isHovering
                    ? Color.white.opacity(0.95)
                    : Color.white.opacity(0.90)
                )
        )
        .shadow(
            color: isHovering ? .black.opacity(0.18) : .black.opacity(0.12),
            radius: isHovering ? 6 : 2,
            x: 0,
            y: isHovering ? 3 : 1
        )
        .scaleEffect(isHovering ? 1.04 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isHovering)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .onTapGesture {
            PasteBackService.paste(item: item)
            onPasteFinished()
        }
    }
}
