import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import PublicInitImplementation

final class PublicInitMacroTests: XCTestCase {
    private let macros = ["PublicInit": PublicInitMacro.self]
    
    func testPublicInitMacroAsClassExpandsCorrectly() throws {
        assertMacroExpansion(
        """
        @PublicInit
        public final class Test {
            let age: Int
            let cash: Double?
            let name: String
        }
        """,
        expandedSource:
        """
        
        public final class Test {
            let age: Int
            let cash: Double?
            let name: String
        
            public init(
                age: Int,
                cash: Double?,
                name: String
            ) {
                self.age = age
                self.cash = cash
                self.name = name
            }
        }
        """,
        macros: macros
        )
    }
    
    func testPublicInitMacroAsClassWithEscapingClosureExpandsCorrectly() throws {
        assertMacroExpansion(
        """
        @PublicInit
        public struct AccessibilityInformation {
            public let id: String
            public let description: String
            public let traits: AccessibilityTraits
            public let action: () -> Void
        }
        """,
        expandedSource:
        """
        
        public struct AccessibilityInformation {
            public let id: String
            public let description: String
            public let traits: AccessibilityTraits
            public let action: () -> Void
        
            public init(
                id: String,
                description: String,
                traits: AccessibilityTraits,
                action: @escaping () -> Void
            ) {
                self.id = id
                self.description = description
                self.traits = traits
                self.action = action
            }
        }
        """,
        macros: macros
        )
    }
    
    func testPublicInitMacroAsClassWithOptionalEscapingClosureExpandsCorrectly() throws {
        assertMacroExpansion(
        """
        @PublicInit
        public struct AccessibilityInformation {
            public let id: String
            public let description: String
            public let traits: AccessibilityTraits
            public let action: (() -> Void)?
        }
        """,
        expandedSource:
        """
        
        public struct AccessibilityInformation {
            public let id: String
            public let description: String
            public let traits: AccessibilityTraits
            public let action: (() -> Void)?
        
            public init(
                id: String,
                description: String,
                traits: AccessibilityTraits,
                action: (() -> Void)?
            ) {
                self.id = id
                self.description = description
                self.traits = traits
                self.action = action
            }
        }
        """,
        macros: macros
        )
    }
    
    func testPublicInitMacroAsStructExpandsCorrectly() throws {
        assertMacroExpansion(
        """
        @PublicInit
        public struct RandomPoint {
            let x: Int
            var y: Int
        }
        """,
        expandedSource:
        """
        
        public struct RandomPoint {
            let x: Int
            var y: Int
        
            public init(
                x: Int,
                y: Int
            ) {
                self.x = x
                self.y = y
            }
        }
        """,
        macros: macros
        )
    }
    
    func testPublicInitMacroAsStructWithComputedPropertyExpandsCorrectly() throws {
        assertMacroExpansion(
        """
        @PublicInit
        public struct RandomPoint {
            let x: Int
            var y: Int
            var xPlusY: Int { x + y }
        }
        """,
        expandedSource:
        """
        
        public struct RandomPoint {
            let x: Int
            var y: Int
            var xPlusY: Int { x + y }
        
            public init(
                x: Int,
                y: Int
            ) {
                self.x = x
                self.y = y
            }
        }
        """,
        macros: macros
        )
    }
    
    func testPublicInitMacroAsStructWithAccessorsExpandsCorrectly() throws {
        assertMacroExpansion(
        """
        @PublicInit
        public struct RandomPoint {
            let x: Int
            var y: Int
            var displayResult: Bool
            var isSelected: Bool {
                get {
                    displayResult
                }
                set {
                    displayResult = newValue
                }
            }
        }
        """,
        expandedSource:
        """
        
        public struct RandomPoint {
            let x: Int
            var y: Int
            var displayResult: Bool
            var isSelected: Bool {
                get {
                    displayResult
                }
                set {
                    displayResult = newValue
                }
            }
        
            public init(
                x: Int,
                y: Int,
                displayResult: Bool
            ) {
                self.x = x
                self.y = y
                self.displayResult = displayResult
            }
        }
        """,
        macros: macros
        )
    }
    
    func testPublicInitMacroAsStructWithStaticAccessorsExpandsCorrectly() throws {
        assertMacroExpansion(
        """
        @PublicInit
        public struct RandomPoint {
            static let x: Int
            var y: Int
            static var displayResult: Bool
            var isSelected: Bool {
                get {
                    displayResult
                }
                set {
                    displayResult = newValue
                }
            }
        }
        """,
        expandedSource:
        """
        
        public struct RandomPoint {
            static let x: Int
            var y: Int
            static var displayResult: Bool
            var isSelected: Bool {
                get {
                    displayResult
                }
                set {
                    displayResult = newValue
                }
            }
        
            public init(
                x: Int,
                y: Int,
                displayResult: Bool
            ) {
                Self.x = x
                self.y = y
                Self.displayResult = displayResult
            }
        }
        """,
        macros: macros
        )
    }
    
    func testPublicInitMacroAsStructNotPublicExpandsCorrectly() throws {
        assertMacroExpansion(
        """
        @PublicInit
        struct RandomPoint {
            let x: Int
            var y: Int
            var displayResult: Bool
        }
        """,
        expandedSource:
        """
        
        struct RandomPoint {
            let x: Int
            var y: Int
            var displayResult: Bool
        
            public init(
                x: Int,
                y: Int,
                displayResult: Bool
            ) {
                self.x = x
                self.y = y
                self.displayResult = displayResult
            }
        }
        """,
        macros: macros
        )
    }
    
    func testPublicInitMacroImplicitDefaults() throws {
        assertMacroExpansion(
        """
        @PublicInit
        struct RandomPoint {
            let x: Int = 5
            var y: Int
            var displayResult: Bool = true
        }
        """,
        expandedSource:
        """
        
        struct RandomPoint {
            let x: Int = 5
            var y: Int
            var displayResult: Bool = true
        
            public init(
                y: Int,
                displayResult: Bool = true
            ) {
                self.y = y
                self.displayResult = displayResult
            }
        }
        """,
        macros: macros
        )
    }
}
