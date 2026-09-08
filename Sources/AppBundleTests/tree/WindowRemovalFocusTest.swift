@testable import AppBundle
import XCTest

@MainActor
final class WindowRemovalFocusTest: XCTestCase {
    override func setUp() {
        setUpWorkspacesForTests()
    }

    func testClosingBackgroundDialogPreservesFocusedWindow() {
        let workspace = Workspace.get(byName: "1")
        let browser = TestWindow.new(id: 1, parent: workspace.rootTilingContainer)
        XCTAssertTrue(browser.focusWindow())
        let terminal = TestWindow.new(id: 2, parent: workspace.rootTilingContainer)
        let dialog = TestWindow.new(id: 3, parent: workspace.floatingWindowsContainer)
        terminal.markAsMostRecentChild()
        browser.nativeFocus()

        dialog.unbindAndRestoreFocus(focus)

        XCTAssertEqual(focus.windowOrNil, browser)
        XCTAssertEqual(TestApp.shared.focusedWindow, browser)
    }

    func testClosingFocusedWindowSelectsRemainingWindow() {
        let workspace = Workspace.get(byName: "1")
        let browser = TestWindow.new(id: 1, parent: workspace.rootTilingContainer)
        let dialog = TestWindow.new(id: 2, parent: workspace.floatingWindowsContainer)
        XCTAssertTrue(dialog.focusWindow())

        dialog.unbindAndRestoreFocus(focus)

        XCTAssertEqual(focus.windowOrNil, browser)
    }

    func testClosingLastWindowLeavesWorkspaceFocused() {
        let workspace = Workspace.get(byName: "1")
        let window = TestWindow.new(id: 1, parent: workspace.rootTilingContainer)
        XCTAssertTrue(window.focusWindow())

        window.unbindAndRestoreFocus(focus)

        XCTAssertNil(focus.windowOrNil)
        XCTAssertEqual(focus.workspace, workspace)
    }
}
