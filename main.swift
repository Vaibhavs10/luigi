import Foundation

// Check if there are command line arguments
if CommandLine.arguments.count > 1 {
    // Get the input string from command line arguments
    let input = CommandLine.arguments[1]
    print("hello \(input)")
} else {
    print("Please provide a string as input")
} 