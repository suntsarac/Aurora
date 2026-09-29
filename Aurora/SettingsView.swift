import SwiftUI

struct SettingsView: View {
    @Binding var selectedTheme: GradientTheme

    var body: some View {
        ZStack {
            SiriGradientBackground(theme: selectedTheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SettingsHeader()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gradient")
                            .font(.title2.bold())

                        Text("Each palette automatically adapts to your device’s light or dark appearance.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ForEach(GradientTheme.allCases) { theme in
                            ThemeChoiceCard(
                                theme: theme,
                                isSelected: theme == selectedTheme
                            ) {
                                selectedTheme = theme
                            }
                        }
                    }
                }
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Settings")
    }
}

private struct SettingsHeader: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "paintpalette.fill")
                .font(.title2)
                .frame(width: 46, height: 46)
                .glassEffect(
                    .regular.tint(.green.opacity(0.24)),
                    in: .circle
                )

            VStack(alignment: .leading, spacing: 3) {
                Text("Appearance")
                    .font(.title.bold())

                Text("Choose the atmosphere for Aurora.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ThemeChoiceCard: View {
    let theme: GradientTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(theme.name)
                            .font(.headline)

                        Text(theme.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(
                            isSelected
                                ? AnyShapeStyle(.tint)
                                : AnyShapeStyle(.secondary)
                        )
                }

                HStack(spacing: 10) {
                    ThemeModePreview(
                        title: "Light",
                        theme: theme,
                        colorScheme: .light
                    )
                    ThemeModePreview(
                        title: "Dark",
                        theme: theme,
                        colorScheme: .dark
                    )
                }
            }
            .padding(16)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .glassEffect(
            isSelected
                ? .regular.tint(.accentColor.opacity(0.20)).interactive()
                : .regular.interactive(),
            in: .rect(cornerRadius: 22)
        )
        .accessibilityHint("Selects this gradient throughout the app")
    }
}

private struct ThemeModePreview: View {
    let title: LocalizedStringResource
    let theme: GradientTheme
    let colorScheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            GradientThemePreview(theme: theme, colorScheme: colorScheme)
                .frame(height: 64)
                .clipShape(.rect(cornerRadius: 12))

            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    @Previewable @State var theme: GradientTheme = .sage

    NavigationStack {
        SettingsView(selectedTheme: $theme)
    }
}
