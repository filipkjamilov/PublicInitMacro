@attached(member, names: named(init))
public macro PublicInit() = #externalMacro(
    module: "PublicInitImplementation",
    type: "PublicInitMacro"
)
