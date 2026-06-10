//
//  CustomNavigationScroll.swift
//  ChemVista
//
//  A reusable scroll wrapper that gives a collapsing large-title header
//  (similar to Apple's native nav bar) without fighting with NavigationView.
//

import SwiftUI

// MARK: - StickyNavHeader
private struct StickyNavHeader<TrailingContent: View>: View {

    let title: String
    let isCollapsed: Bool
    let trailingContent: TrailingContent

    init(
        title: String,
        isCollapsed: Bool,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.title = title
        self.isCollapsed = isCollapsed
        self.trailingContent = trailingContent()
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Text(title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(isCollapsed ? 0 : 1)
                    .scaleEffect(isCollapsed ? 0.9 : 1.0, anchor: .leading)

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .opacity(isCollapsed ? 1 : 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, isCollapsed ? -8 : 8)
            .padding(.bottom, isCollapsed ? 12 : 6)

            trailingContent
                .padding(.trailing, 16)
                .padding(.top, 6)
        }
        .background {
            Rectangle()
                .fill(Color(red: 3/255, green: 2/255, blue: 8/255))
                .opacity(isCollapsed ? 1 : 0.8)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .black,              location: 0.0),
                            .init(color: .black.opacity(0.8), location: 0.7),
                            .init(color: .clear,              location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea(edges: .top)
        }
        .animation(.spring(response: 0.15, dampingFraction: 0.9), value: isCollapsed)
    }
}

// MARK: - CustomNavigationScrollModifier
private struct CustomNavigationScrollModifier<TrailingContent: View>: ViewModifier {
    let title: String
    let trailingContent: () -> TrailingContent
    
    @State private var scrollOffset: CGFloat = 0
    private let collapseThreshold: CGFloat = 40

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                ZStack {
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .named("scroll")).minY
                        )
                    }
                    .frame(height: 0)
                    
                    content
                        .padding(.top, 70) // Space for large title
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }

            StickyNavHeader(
                title: title,
                isCollapsed: scrollOffset < -collapseThreshold,
                trailingContent: trailingContent
            )
        }
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func customNavigationScroll<TrailingContent: View>(
        title: String,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent
    ) -> some View {
        modifier(CustomNavigationScrollModifier(title: title, trailingContent: trailingContent))
    }
    
    func customNavigationScroll(title: String) -> some View {
        modifier(CustomNavigationScrollModifier(title: title, trailingContent: { EmptyView() }))
    }
}
