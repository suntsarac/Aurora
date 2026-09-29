import SwiftUI

enum GradientTheme: String, CaseIterable, Identifiable {
    case siriSpectrum
    case sage
    case ocean
    case sunset

    var id: String { rawValue }

    var name: LocalizedStringResource {
        switch self {
        case .siriSpectrum: "Siri Spectrum"
        case .sage: "Sage"
        case .ocean: "Ocean"
        case .sunset: "Sunset"
        }
    }

    var detail: LocalizedStringResource {
        switch self {
        case .siriSpectrum: "Blue, violet, pink, and cyan"
        case .sage: "Soft sage by day, deep forest by night"
        case .ocean: "Airy aqua by day, midnight blue by night"
        case .sunset: "Warm peach by day, rich plum by night"
        }
    }

    fileprivate func palette(for colorScheme: ColorScheme) -> GradientPalette {
        switch (self, colorScheme) {
        case (.siriSpectrum, .light):
            GradientPalette(
                base: [
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.93, green: 0.96, blue: 1.0),
                    Color(red: 0.99, green: 0.94, blue: 0.98)
                ],
                orbs: [
                    Color(red: 0.20, green: 0.58, blue: 1.0),
                    Color(red: 0.64, green: 0.35, blue: 1.0),
                    Color(red: 1.0, green: 0.34, blue: 0.67),
                    Color(red: 0.05, green: 0.78, blue: 0.82)
                ],
                orbOpacity: 0.30,
                veil: .white.opacity(0.08)
            )
        case (.siriSpectrum, .dark):
            GradientPalette(
                base: [
                    Color(red: 0.025, green: 0.03, blue: 0.10),
                    Color(red: 0.05, green: 0.015, blue: 0.12),
                    Color(red: 0.01, green: 0.07, blue: 0.14)
                ],
                orbs: [
                    Color(red: 0.05, green: 0.55, blue: 1.0),
                    Color(red: 0.61, green: 0.18, blue: 1.0),
                    Color(red: 1.0, green: 0.13, blue: 0.55),
                    Color(red: 0.0, green: 0.88, blue: 0.88)
                ],
                orbOpacity: 0.68,
                veil: .black.opacity(0.24)
            )
        case (.sage, .light):
            GradientPalette(
                base: [
                    Color(red: 0.99, green: 0.99, blue: 0.97),
                    Color(red: 0.93, green: 0.97, blue: 0.92),
                    Color(red: 0.97, green: 0.98, blue: 0.94)
                ],
                orbs: [
                    Color(red: 0.47, green: 0.66, blue: 0.48),
                    Color(red: 0.68, green: 0.78, blue: 0.61),
                    Color(red: 0.82, green: 0.74, blue: 0.52),
                    Color(red: 0.38, green: 0.72, blue: 0.63)
                ],
                orbOpacity: 0.27,
                veil: .white.opacity(0.12)
            )
        case (.sage, .dark):
            GradientPalette(
                base: [
                    Color(red: 0.01, green: 0.045, blue: 0.03),
                    Color(red: 0.02, green: 0.09, blue: 0.055),
                    Color(red: 0.025, green: 0.055, blue: 0.04)
                ],
                orbs: [
                    Color(red: 0.08, green: 0.42, blue: 0.24),
                    Color(red: 0.22, green: 0.53, blue: 0.31),
                    Color(red: 0.48, green: 0.42, blue: 0.16),
                    Color(red: 0.04, green: 0.45, blue: 0.39)
                ],
                orbOpacity: 0.62,
                veil: .black.opacity(0.28)
            )
        case (.ocean, .light):
            GradientPalette(
                base: [
                    Color(red: 0.96, green: 0.99, blue: 1.0),
                    Color(red: 0.89, green: 0.97, blue: 0.99),
                    Color(red: 0.94, green: 0.95, blue: 1.0)
                ],
                orbs: [
                    Color(red: 0.15, green: 0.62, blue: 0.94),
                    Color(red: 0.18, green: 0.78, blue: 0.79),
                    Color(red: 0.45, green: 0.48, blue: 0.95),
                    Color(red: 0.25, green: 0.73, blue: 0.60)
                ],
                orbOpacity: 0.28,
                veil: .white.opacity(0.10)
            )
        case (.ocean, .dark):
            GradientPalette(
                base: [
                    Color(red: 0.01, green: 0.035, blue: 0.09),
                    Color(red: 0.015, green: 0.08, blue: 0.15),
                    Color(red: 0.025, green: 0.03, blue: 0.13)
                ],
                orbs: [
                    Color(red: 0.0, green: 0.35, blue: 0.92),
                    Color(red: 0.0, green: 0.68, blue: 0.82),
                    Color(red: 0.25, green: 0.20, blue: 0.78),
                    Color(red: 0.0, green: 0.55, blue: 0.43)
                ],
                orbOpacity: 0.64,
                veil: .black.opacity(0.25)
            )
        case (.sunset, .light):
            GradientPalette(
                base: [
                    Color(red: 1.0, green: 0.98, blue: 0.94),
                    Color(red: 1.0, green: 0.92, blue: 0.89),
                    Color(red: 0.98, green: 0.94, blue: 1.0)
                ],
                orbs: [
                    Color(red: 1.0, green: 0.47, blue: 0.28),
                    Color(red: 0.96, green: 0.33, blue: 0.51),
                    Color(red: 0.61, green: 0.39, blue: 0.92),
                    Color(red: 1.0, green: 0.70, blue: 0.25)
                ],
                orbOpacity: 0.28,
                veil: .white.opacity(0.10)
            )
        case (.sunset, .dark):
            GradientPalette(
                base: [
                    Color(red: 0.08, green: 0.015, blue: 0.06),
                    Color(red: 0.14, green: 0.025, blue: 0.08),
                    Color(red: 0.055, green: 0.018, blue: 0.10)
                ],
                orbs: [
                    Color(red: 0.95, green: 0.20, blue: 0.09),
                    Color(red: 0.85, green: 0.08, blue: 0.34),
                    Color(red: 0.43, green: 0.12, blue: 0.68),
                    Color(red: 0.92, green: 0.48, blue: 0.05)
                ],
                orbOpacity: 0.62,
                veil: .black.opacity(0.28)
            )
        @unknown default:
            GradientTheme.siriSpectrum.palette(for: .dark)
        }
    }
}

private struct GradientPalette {
    let base: [Color]
    let orbs: [Color]
    let orbOpacity: Double
    let veil: Color
}

struct SiriGradientBackground: View {
    let theme: GradientTheme
    var colorSchemeOverride: ColorScheme?

    @Environment(\.colorScheme) private var colorScheme

    init(
        theme: GradientTheme = .siriSpectrum,
        colorScheme: ColorScheme? = nil
    ) {
        self.theme = theme
        self.colorSchemeOverride = colorScheme
    }

    var body: some View {
        let palette = theme.palette(for: colorSchemeOverride ?? colorScheme)

        TimelineView(.animation) { timeline in
            GeometryReader { geometry in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let width = geometry.size.width
                let height = geometry.size.height
                let longestSide = max(width, height)

                ZStack {
                    LinearGradient(
                        colors: palette.base,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    gradientOrb(
                        color: palette.orbs[0],
                        opacity: palette.orbOpacity,
                        size: longestSide * 0.78,
                        x: width * (0.12 + 0.14 * sin(time * 0.16)),
                        y: height * (0.06 + 0.13 * cos(time * 0.13))
                    )

                    gradientOrb(
                        color: palette.orbs[1],
                        opacity: palette.orbOpacity,
                        size: longestSide * 0.70,
                        x: width * (0.52 + 0.18 * cos(time * 0.12)),
                        y: height * (0.28 + 0.15 * sin(time * 0.17))
                    )

                    gradientOrb(
                        color: palette.orbs[2],
                        opacity: palette.orbOpacity,
                        size: longestSide * 0.58,
                        x: width * (0.48 + 0.19 * sin(time * 0.14)),
                        y: height * (0.68 + 0.12 * cos(time * 0.19))
                    )

                    gradientOrb(
                        color: palette.orbs[3],
                        opacity: palette.orbOpacity,
                        size: longestSide * 0.52,
                        x: width * (0.02 + 0.16 * cos(time * 0.18)),
                        y: height * (0.58 + 0.14 * sin(time * 0.11))
                    )

                    palette.veil
                }
                .frame(width: width, height: height)
                .clipped()
            }
        }
        .accessibilityHidden(true)
    }

    private func gradientOrb(
        color: Color,
        opacity: Double,
        size: CGFloat,
        x: CGFloat,
        y: CGFloat
    ) -> some View {
        Circle()
            .fill(color.opacity(opacity))
            .frame(width: size, height: size)
            .blur(radius: size * 0.16)
            .offset(x: x - size * 0.5, y: y - size * 0.5)
    }
}

struct GradientThemePreview: View {
    let theme: GradientTheme
    let colorScheme: ColorScheme

    var body: some View {
        let palette = theme.palette(for: colorScheme)

        LinearGradient(
            colors: palette.base + palette.orbs,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(palette.veil)
        .accessibilityHidden(true)
    }
}
