import Foundation
import ArgumentParser

struct LlamaCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "llama-cli",
        abstract: "A Swift CLI wrapper to run the llama-server binary.",
        discussion: """
        This tool wraps the 'llama-server' binary, allowing you to configure
        and run it with specified parameters. The 'llama-server' binary
        must be accessible by this wrapper.
        """
    )

    @Option(name: .customLong("hf"), help: "The Hugging Face model identifier (e.g., 'meta-llama/Llama-2-7b-chat-hf') or a local path to the model. This will be passed to llama-server.")
    var hfModel: String

    @Option(name: .customLong("c"), help: "A numeric value, often used for context size or number of threads for llama-server.")
    var cValue: Int

    // --- IMPORTANT: Configuration for llama-server ---
    // You will need to adjust these based on how your 'llama-server' binary
    // actually accepts its command-line arguments.
    // For example, if llama-server expects '--model-path' instead of '--model':
    private var modelArgName: String = "--hf-repo" // Placeholder: e.g., "--model", "--model-path"
    // And if '-c' corresponds to '--threads' or '--context-length':
    private var cValueArgName: String = "--ctx-size" // Placeholder: e.g., "--threads", "--context-size", "-n"

    private func findLlamaServerPath() throws -> String {
        // Priority for finding 'llama-server':
        // 1. LLAMA_SERVER_PATH environment variable
        if let envPath = ProcessInfo.processInfo.environment["LLAMA_SERVER_PATH"], !envPath.isEmpty {
            if FileManager.default.isExecutableFile(atPath: envPath) {
                print("Using llama-server from LLAMA_SERVER_PATH: \(envPath)")
                return envPath
            } else {
                print("Warning: LLAMA_SERVER_PATH ('\(envPath)') is set but the file is not executable or not found. Falling back...")
            }
        }

        // 2. Relative to the CLI executable's path (common for co-located/bundled binaries)
        if let executableFolderURL = Bundle.main.executableURL?.deletingLastPathComponent() {
            // Check in the same directory as the CLI executable
            let sameDirPath = executableFolderURL.appendingPathComponent("llama-server").path
            if FileManager.default.isExecutableFile(atPath: sameDirPath) {
                print("Found llama-server alongside the CLI executable: \(sameDirPath)")
                return sameDirPath
            }

            // Check in a 'Resources' subfolder relative to the executable (common for app bundles)
            // This path would be MainBundle/Contents/Resources/llama-server if CLI is in MainBundle/Contents/MacOS/
            let resourcesPath = executableFolderURL.deletingLastPathComponent().appendingPathComponent("Resources/llama-server").path
            if FileManager.default.isExecutableFile(atPath: resourcesPath) {
                print("Found llama-server in Resources folder: \(resourcesPath)")
                return resourcesPath
            }
        }
        
        // 3. Default path (e.g., current working directory)
        let defaultPath = "./llama-server"
        if FileManager.default.isExecutableFile(atPath: defaultPath) {
            print("Found llama-server in current directory: \(defaultPath)")
            return defaultPath
        }
        
        throw RuntimeError("Error: 'llama-server' binary not found.\nSearched LLAMA_SERVER_PATH, relative to executable (and ../Resources), and current directory ('./llama-server').\nPlease ensure 'llama-server' is executable and in one of these locations, or update LLAMA_SERVER_PATH.")
    }

    func run() throws {
        print("LlamaCLI preparing to launch llama-server...")
        print("  Model (-hf): \(hfModel)")
        print("  C Value (-c): \(cValue)")

        let llamaServerPath: String
        do {
            llamaServerPath = try findLlamaServerPath()
        } catch {
            print("\(error.localizedDescription)") // Error already includes "Error:"
            LlamaCLI.exit(withError: error)
        }

        // Construct arguments for llama-server.
        // !!! CRITICAL ASSUMPTION !!!
        // You MUST verify how 'llama-server' expects its arguments and update
        // `modelArgName`, `cValueArgName`, and the argument construction below.
        var serverArgs = [String]()
        serverArgs.append(modelArgName)
        serverArgs.append(hfModel)
        serverArgs.append(cValueArgName)
        serverArgs.append(String(cValue))
        
        // Add any other necessary default arguments for llama-server here.
        // For example:
        // serverArgs.append("--port")
        // serverArgs.append("8080")
        // serverArgs.append("--host")
        // serverArgs.append("127.0.0.1")

        print("Executing: \(llamaServerPath) \(serverArgs.joined(separator: " "))")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: llamaServerPath)
        process.arguments = serverArgs

        // Pass through standard output, error, and input for interactive servers
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        process.standardInput = FileHandle.standardInput // Important if llama-server is interactive

        do {
            try process.run()
            process.waitUntilExit() // Wait for the server process to complete

            if process.terminationStatus == 0 {
                print("\nllama-server exited successfully.")
            } else {
                print("\nllama-server exited with status: \(process.terminationStatus).")
                // Propagate the exit code from llama-server
                LlamaCLI.exit(withError: ExitCode(process.terminationStatus))
            }
        } catch {
            print("Error: Failed to start or run llama-server: \(error.localizedDescription)")
            LlamaCLI.exit(withError: error)
        }
    }
}

// Custom error for cleaner messages
struct RuntimeError: Error, CustomStringConvertible, LocalizedError {
    var message: String
    init(_ message: String) { self.message = message }
    var description: String { message }
    var errorDescription: String? { message }
}

// Entry point
LlamaCLI.main()
