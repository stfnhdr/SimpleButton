import XCTest
@testable import SimpleButton
import SnapshotTesting

public extension XCTestCase {
    var given: Given { Given() }
    var when: When { When() }
    var then: Then { Then() }
}

public struct Given {}

public struct When {}

public struct Then {}


final class ButtonTests: XCTestCase {
    
    class State {
        var button: SimpleButton!
    }
    
    override func setUp() {
        super.setUp()
        state = State()
    }
    
    override func tearDown() {
        state = nil
        super.tearDown()
    }
    
    var state: State!
    
    // MARK: - Main
    
    func testNormal() throws {
        given
            .aSimpleButton(state: state)
            .withAShortText(state: state)
        
        when
            .settingStyle(state: state)
        
        then
            .viewShouldMatch(state: state, testName: #function)
            .viewShouldMatchInDarkMode(state: state, testName: #function)
    }
    
    func testNormalWithImage() throws {
        given
            .aSimpleButton(state: state)
            .withAShortText(state: state)
            .withImage(state: state)
        
        when
            .settingStyle(state: state)
        then
            .viewShouldMatch(state: state, testName: #function)
            .viewShouldMatchInDarkMode(state: state, testName: #function)
    }
    
    func testDisabled() throws {
        given
            .aSimpleButton(state: state)
            .aDisabledButton(state: state)
            .withAShortText(state: state)
        
        when
            .settingStyle(state: state)
        then
            .viewShouldMatch(state: state, testName: #function)
            .viewShouldMatchInDarkMode(state: state, testName: #function)
    }
    
    func testDisabledWithImage() throws {
        given
            .aSimpleButton(state: state)
            .aDisabledButton(state: state)
            .withAShortText(state: state)
            .withImage(state: state)
        
        when
            .settingStyle(state: state)
        then
            .viewShouldMatch(state: state, testName: #function)
            .viewShouldMatchInDarkMode(state: state, testName: #function)
    }
    
    func testHighlighted() throws {
        given
            .aSimpleButton(state: state)
            .aHighlightedButton(state: state)
            .withAShortText(state: state)
        
        when
            .settingStyle(state: state)
        then
            .viewShouldMatch(state: state, testName: #function)
            .viewShouldMatchInDarkMode(state: state, testName: #function)
    }
    
    func testHighlightedWithImage() throws {
        given
            .aSimpleButton(state: state)
            .aHighlightedButton(state: state)
            .withAShortText(state: state)
            .withImage(state: state)
        
        when
            .settingStyle(state: state)
        then
            .viewShouldMatch(state: state, testName: #function)
            .viewShouldMatchInDarkMode(state: state, testName: #function)
    }
    
}

extension Given {
    
    @discardableResult func aSimpleButton(state: ButtonTests.State) -> Given {
        state.button = SimpleButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        return self
    }
    
    @discardableResult func aDisabledButton(state: ButtonTests.State) -> Given {
        state.button.isEnabled = false
        return self
    }
    
    @discardableResult func aHighlightedButton(state: ButtonTests.State) -> Given {
        state.button.isHighlighted = true
        return self
    }
    
    @discardableResult func withAShortText(state: ButtonTests.State) -> Given {
        state.button.setTitle("Test", for: .normal)
        return self
    }
    
    @discardableResult func withALongText(state: ButtonTests.State) -> Given {
        state.button.setTitle("TestTestTestTest", for: .normal)
        return self
    }
    
    @discardableResult func withImage(state: ButtonTests.State) -> Given {
        state.button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        state.button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return self
    }
}

extension When {
    func settingStyle(state: ButtonTests.State) {
        
        let firstColor = UIColor { traitColletion in
            switch traitColletion.userInterfaceStyle {
            case .dark:
                return UIColor.systemGreen
            default:
                return .green
            }
        }
        
        let secondColor = UIColor { traitColletion in
            switch traitColletion.userInterfaceStyle {
            case .dark:
                return UIColor.red
            default:
                return .red
            }
        }
        
        
        let thirdColor = UIColor { traitColletion in
            switch traitColletion.userInterfaceStyle {
            case .dark:
                return UIColor.blue
            default:
                return .blue
            }
        }
        
        let textColor = UIColor { traitColletion in
            switch traitColletion.userInterfaceStyle {
            case .dark:
                return .black
            default:
                return .white
            }
        }
        
        // normal
        state.button.setBackgroundColor(firstColor, for: .normal)
        state.button.setTitleColor(textColor, for: .normal)
        state.button.setImageColor(textColor, for: .normal)
        
        // disabled
        state.button.setBackgroundColor(secondColor, for: .disabled)
        state.button.setTitleColor(textColor, for: .disabled)
        state.button.setImageColor(textColor, for: .disabled)
        
        // highlighted
        state.button.setBackgroundColor(thirdColor, for: .highlighted)
        state.button.setTitleColor(textColor, for: .highlighted)
        state.button.setImageColor(textColor, for: .highlighted)
        
        state.button.setCornerRadius(2)
    }
}

extension Then {
    @discardableResult
    func viewShouldMatch(state: ButtonTests.State, testName: String) -> Then {
        assertSnapshot(matching: state.button, as: .image, named: testName)
        return self
    }
    
    @discardableResult
    func viewShouldMatchInDarkMode(state: ButtonTests.State, testName: String) -> Then {
        
        state.button.overrideUserInterfaceStyle = .dark
        assertSnapshot(matching: state.button, as: .image, named: testName)
        return self
    }
    
}
