import SwiftUI
import Foundation

enum SpoilerAttribute: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
  typealias Value = Bool
  static var name = "spoiler"
}

extension AttributeScopes {
  struct SpoilerScope: AttributeScope {
    let spoiler: SpoilerAttribute
  }

  var spoilerScope: SpoilerScope.Type { SpoilerScope.self }
}

struct ContentView: View {
  @State private var revealSpoilers1 = false
  @State private var revealSpoilers2 = false

  private let source1 = """
    犯人は^[毛利小五郎](spoiler: true)
    """
  private let source2 = """
    黒幕は^[阿笠博士](spoiler: true)
    """

  private var parsed1: AttributedString {
    AttributedString(localized: String.LocalizationValue(source1), including: \.spoilerScope)
  }

  private var parsed2: AttributedString {
    AttributedString(localized: String.LocalizationValue(source2), including: \.spoilerScope)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Toggle("ネタバレを表示", isOn: $revealSpoilers1)

      Divider()

      renderedText(from: parsed1, revealSpoilers: revealSpoilers1)
        .font(.title)
        .padding(.vertical, 4)

      Text("")
        .padding(.vertical, 4)

      Toggle("ネタバレを表示", isOn: $revealSpoilers2)

      Divider()

      renderedText(from: parsed2, revealSpoilers: revealSpoilers2)
        .font(.title)
        .padding(.vertical, 4)

      Spacer()
    }
    .padding()
  }

  private func renderedText(from source: AttributedString, revealSpoilers: Bool) -> Text {
    var result = Text("")

    for run in source.runs {
      let isSpoiler = (run.spoilerScope.spoiler == true)
      let slice = AttributedString(source[run.range])

      if isSpoiler && !revealSpoilers {
        let raw = String(slice.characters)
        let masked = maskKeepingWhitespace(raw)

        result = result + Text(masked)
          .foregroundStyle(.secondary)
          .font(.title.monospaced())
      } else {
        result = result + Text(slice)
      }
    }

    return result
  }

  private func maskKeepingWhitespace(_ s: String) -> String {
    s.map { ch in
      isWhitespace(ch) ? ch : "█"
    }.map(String.init).joined()
  }

  private func isWhitespace(_ ch: Character) -> Bool {
    ch.unicodeScalars.allSatisfy { CharacterSet.whitespacesAndNewlines.contains($0) }
  }
}
