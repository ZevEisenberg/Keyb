import AppKit
import ComposableArchitecture
import SwiftUI

/// The menu bar icon, which reflects whether one-handed typing is enabled.
public struct MenuBarLabel: View {
  let store: StoreOf<UserInterface>

  public init(store: StoreOf<UserInterface>) {
    self.store = store
  }

  public var body: some View {
    Image(nsImage: MenuBarIcon.image(isEnabled: store.isRunning))
  }
}

/// Placeholder menu bar artwork built from SF Symbols until a custom icon exists.
@MainActor
enum MenuBarIcon {
  static func image(isEnabled: Bool) -> NSImage {
    isEnabled ? enabled : disabled
  }

  private static let symbolName = "keyboard.onehanded.left.fill"

  private static let symbol: NSImage = {
    let configuration = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
    guard let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
      .withSymbolConfiguration(configuration)
    else {
      assertionFailure("Missing SF Symbol \(symbolName)")
      return NSImage()
    }
    return image
  }()

  private static let enabled: NSImage = {
    let image = symbol.copy() as! NSImage // swiftlint:disable:this force_cast
    image.isTemplate = true
    image.accessibilityDescription = "One-handed typing enabled"
    return image
  }()

  /// The symbol drawn faintly with a slash through it. It's a template image, so the system colors
  /// it to match the menu bar: partial alpha becomes gray, and the opaque slash becomes black in
  /// light mode and white in dark mode.
  private static let disabled: NSImage = {
    let baseSymbol = MenuBarIcon.symbol
    let image = NSImage(size: baseSymbol.size, flipped: false) { rect in
      let symbol = baseSymbol
      symbol.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 0.35)

      let half = rect.height / 2 - 1
      let slash = NSBezierPath()
      slash.move(to: NSPoint(x: rect.midX - half, y: rect.midY + half))
      slash.line(to: NSPoint(x: rect.midX + half, y: rect.midY - half))
      slash.lineCapStyle = .round

      // Knock out a gap around the slash, like SF Symbols' own slash variants.
      NSGraphicsContext.current?.compositingOperation = .clear
      slash.lineWidth = 4
      slash.stroke()

      NSGraphicsContext.current?.compositingOperation = .sourceOver
      NSColor.black.setStroke()
      slash.lineWidth = 1.5
      slash.stroke()
      return true
    }
    image.isTemplate = true
    image.accessibilityDescription = "One-handed typing disabled"
    return image
  }()
}

// `.symbolVariant(.slash)` only works for symbols that ship a slash variant, and
// `keyboard.onehanded.left.fill` doesn't, so the disabled icon draws its own slash.
#Preview("Menu Bar Icons") {
  HStack(spacing: 20) {
    Image(nsImage: MenuBarIcon.image(isEnabled: true))
    Image(nsImage: MenuBarIcon.image(isEnabled: false))
  }
  .padding()
}
