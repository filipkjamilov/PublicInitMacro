import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct PublicInitMacro: MemberMacro {
    static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Only `struct` and `class` is suitable for this macro
        guard declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) else {
            let message: DiagnosticMessage
            if !declaration.is(StructDeclSyntax.self) {
                message = PublicInitMacroDiagnostic.notAsStruct("PublicInitMacro")
            } else {
                message = PublicInitMacroDiagnostic.notAsClass("PublicInitMacro")
            }
            let error = Diagnostic(
                node: attribute._syntaxNode,
                message: message
            )
            context.diagnose(error)
            return []
        }

        var parameters = [String]()
        var assignments = [String]()

        if let decl = declaration.as(ClassDeclSyntax.self) {
            (parameters, assignments) = makeData(
                getModifiers("", decl.modifiers),
                decl.memberBlock.members,
                decl.attributes
            )
        }
        if let decl = declaration.as(StructDeclSyntax.self) {
            (parameters, assignments) = makeData(
                getModifiers("", decl.modifiers),
                decl.memberBlock.members,
                decl.attributes
            )
        }

        let initBody: [CodeBlockItemListSyntax.Element] = assignments.enumerated().map { index, assignment in
            if index == 0 {
                return "\(raw: assignment)"
            } else {
                return "\n\(raw: assignment)"
            }
        }

        let initDeclSyntax = try InitializerDeclSyntax(
            SyntaxNodeString(
                stringLiteral: "public init(\n\(parameters.joined(separator: ",\n"))\n)"
            ),
            bodyBuilder: { .init(initBody) }
        )

        return ["\(raw: initDeclSyntax)"]
    }

    private static func makeData(
        _ accessorPrefix: String,
        _ members: MemberBlockItemListSyntax,
        _ attributes: AttributeListSyntax?
    ) -> ([String], [String]) {
        var parameters = [String]()
        var assignments = [String]()

        for member in members {
            if let syntax = member.decl.as(VariableDeclSyntax.self),
               let bindings = syntax.bindings.as(PatternBindingListSyntax.self),
               let pattern = bindings.first?.as(PatternBindingSyntax.self),
               let identifier = pattern.pattern.as(IdentifierPatternSyntax.self)?.identifier,
               let type = pattern.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type,
               !(syntax.bindingSpecifier.tokenKind == .keyword(.let) && pattern.initializer != nil) {

                let shouldAddScaping = type.is(FunctionTypeSyntax.self)
                let typePrefix = "\(shouldAddScaping ? "@escaping " : "")"

                var parameter = "\(identifier): \(typePrefix)\(type)"
                if let initializer = pattern.initializer {
                    parameter += "\(initializer)"
                }

                let memberAccessor = getModifiers("", syntax.modifiers)
                let memberAccessorPrefix = (memberAccessor.contains("static") ? "S" : "s") + "elf"

                let isComputedProperty = pattern.accessorBlock?.is(CodeBlockSyntax.self) == true
                let isUsingAccessors = pattern.accessorBlock?.is(AccessorBlockSyntax.self) == true
                if !isComputedProperty, !isUsingAccessors {
                    parameters.append(parameter)
                    assignments.append("\(memberAccessorPrefix).\(identifier) = \(identifier)")
                }
            }
        }

        return (parameters, assignments)
    }
}

private extension AttachedMacro {
    static func getModifiers(
        _ initialModifiers: String,
        _ modifiers: DeclModifierListSyntax?
    ) -> String {
        var initialModifiers = initialModifiers
        modifiers?.forEach {
            if let accessorType = $0.as(DeclModifierSyntax.self)?.name {
                initialModifiers += "\(accessorType.text) "
            }
        }
        return initialModifiers
    }
}
