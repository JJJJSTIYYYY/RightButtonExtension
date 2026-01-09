import SwiftUI

// Define the Glass effect style enum
enum Glass {
    case thin
    case regular
    case thick
}

// View extension for glass effect
extension View {
    func glassEffect(_ style: Glass, in shape: Rectangle) -> some View {
        self.modifier(GlassEffectModifier(style: style))
    }
    
    func glassEffectID(_ id: UUID, in namespace: Namespace.ID) -> some View {
        self.modifier(GlassEffectIDModifier(id: id, namespace: namespace))
    }
}

// Glass effect modifier implementation
struct GlassEffectModifier: ViewModifier {
    let style: Glass
    
    func body(content: Content) -> some View {
        content
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(opacityForStyle)
                    .blur(radius: blurRadiusForStyle)
            )
    }
    
    private var opacityForStyle: Double {
        switch style {
        case .thin: return 0.2
        case .regular: return 0.4
        case .thick: return 0.6
        }
    }
    
    private var blurRadiusForStyle: CGFloat {
        switch style {
        case .thin: return 2
        case .regular: return 4
        case .thick: return 8
        }
    }
}

// Glass effect ID modifier for matching animations
struct GlassEffectIDModifier: ViewModifier {
    let id: UUID
    let namespace: Namespace.ID
    
    func body(content: Content) -> some View {
        content.matchedGeometryEffect(id: id, in: namespace)
    }
}

// Glass effect container wrapper
struct GlassEffectContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
    }
}
