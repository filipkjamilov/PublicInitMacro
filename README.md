PublicInitMacro
PublicInitMacro is a Swift Macro that automatically generates public initializers for Swift classes and structs. This macro aims to reduce boilerplate code by automatically generating initializer methods with public access modifiers.

Usage
To use PublicInitMacro, follow these steps:

Import the PublicInitMacro module into your Swift file.
Annotate your classes or structs with @PublicInit macro.
Ensure that the properties you want to include in the initializer are declared with appropriate access modifiers.
After applying the @PublicInit macro, your class or struct will have a public initializer automatically generated with parameters for the annotated properties.

Installation
PublicInitMacro can be integrated into your Swift project using Swift Package Manager (SPM).

Add the following line to your Package.swift file:
.package(url: "https://github.com/filipkjamilov/PublicInitMacro.git", from: "1.0.0")

Add PublicInitMacro as a dependency of your target:
.target(
name: "YourTarget",
dependencies: [
.product(name: "PublicInitMacro", package: "PublicInitMacro"),
]
)

Run swift build to build your project and fetch the dependencies.
Testing
This repository contains a comprehensive set of test cases to ensure the correctness of the PublicInitMacro. These tests cover various scenarios, including classes, structs with different property types, computed properties, accessors, default property values, and more.

Contributing
Contributions to PublicInitMacro are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.
