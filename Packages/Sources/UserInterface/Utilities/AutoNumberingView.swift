import SwiftUI

/// A view wrapper that gives its child views access to an auto-incrementing `counter` that starts at `initialValue` and counts up every time it is accessed. Use it to build numbered lists with variable content, where you may not be able to hardcode numbers into each view.
///
/// ```swift
/// AutoNumberingView { counter in
///   VStack {
///     Text("\(counter()). This is the first item.")
///     Text("\(counter()). This is the second item.")
///     if !hasCameraPermission {
///       Text("\(counter()). Please grant camera access before continuing.")
///     }
///     Text("\(counter()). This is the third or fourth item, depending on whether the user had granted camera access")
///   }
/// }
/// ```
struct AutoNumberingView<Content: View>: View {
  private let counter: IntCounter
  @ViewBuilder let content: (IntCounter) -> Content

  init(
    startingAt initialValue: Int = 1,
    @ViewBuilder content: @escaping (IntCounter) -> Content
  ) {
    self.counter = IntCounter(startingAt: initialValue)
    self.content = content
  }

  var body: some View {
    content(counter)
  }
}

final class IntCounter {
  private var value: Int

  fileprivate init(startingAt initialValue: Int = 1) {
    self.value = initialValue
  }

  func callAsFunction() -> Int {
    defer {
      value += 1
    }
    return value
  }

  func callAsFunction(restartingAt newInitialValue: Int) -> Int {
    value = newInitialValue
    return newInitialValue
  }
}

#Preview {
  HStack(alignment: .top) {
    ForEach([false, true], id: \.self) { includeExtraItem in
      AutoNumberingView { counter in
        VStack(alignment: .leading) {
          Text("\(counter()). This is the first item.")
            .foregroundColor(.blue)
          Text("\(counter()). This is the second item.")
            .foregroundColor(.green)
          if includeExtraItem {
            Text("\(counter()). This is the secret third item.")
              .foregroundColor(.purple)
          }
          Text("\(counter()). This is the third or fourth item, depending on what came before")
            .foregroundColor(.yellow)
        }
        .frame(width: 300)
        .padding()
      }
    }
  }
}
