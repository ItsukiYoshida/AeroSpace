@testable import AppBundle
import XCTest

@MainActor
final class WindowRemovalFocusTest: XCTestCase {
    override func setUp() async throws {
        setUpWorkspacesForTests()
    }

    func testClosingBackgroundDialogPreservesFocusedWindow() {
        let previousApp = appForTests
        defer { appForTests = previousApp }
        let workspace = Workspace.get(byName: "1")
        let browserApp = TestApp(pid: 1)
        let terminalApp = TestApp(pid: 2)
        let dialogApp = TestApp(pid: 3)
        let browser = TestWindow.new(id: 1, parent: workspace.rootTilingContainer, app: browserApp)
        XCTAssertTrue(browser.focusWindow())
        let terminal = TestWindow.new(id: 2, parent: workspace.rootTilingContainer, app: terminalApp)
        let dialog = TestWindow.new(id: 3, parent: workspace.floatingWindowsContainer, app: dialogApp)
        terminal.markAsMostRecentChild()
        dialog.unbindAndRestoreFocus(focus)

        XCTAssertEqual(focus.windowOrNil, browser)
        XCTAssertEqual(browserApp.focusedWindow, browser)
        XCTAssertNil(terminalApp.focusedWindow)
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
