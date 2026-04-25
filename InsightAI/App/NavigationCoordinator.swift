import SwiftUI

// MARK: - Navigation Path
enum NavigationPath: Hashable {
    case insightDetail(Insight)
    case journalEntryDetail(JournalEntry)
}

// MARK: - Navigation Coordinator
@Observable
final class NavigationCoordinator {
    var selectedTab: Int = 0
    var showNewEntrySheet = false
    var journalPath: [NavigationPath] = []
    var insightsPath: [NavigationPath] = []
    var timelinePath: [NavigationPath] = []
    
    func navigateToTab(_ tab: Int) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            selectedTab = tab
        }
    }
    
    func presentNewEntry() {
        showNewEntrySheet = true
    }
    
    func dismissNewEntry() {
        showNewEntrySheet = false
    }
    
    func navigateToInsight(_ insight: Insight) {
        navigateToTab(1)
        insightsPath.append(.insightDetail(insight))
    }
    
    func popToRoot() {
        journalPath.removeAll()
        insightsPath.removeAll()
        timelinePath.removeAll()
    }
}

// MARK: - Environment Key
struct NavigationCoordinatorKey: EnvironmentKey {
    static let defaultValue = NavigationCoordinator()
}

extension EnvironmentValues {
    var navigationCoordinator: NavigationCoordinator {
        get { self[NavigationCoordinatorKey.self] }
        set { self[NavigationCoordinatorKey.self] = newValue }
    }
}
