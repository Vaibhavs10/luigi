# Project Title

A brief description of what this project does.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/vaibhavs10/luigi.git
    cd yourproject
    ```
2.  **Build the project:**
    ```bash
    swift build
    ```

### Building llama.cpp

`llama-server` is built alongside everything else from the root of the `llama.cpp` project.

If you need to build `llama.cpp`, follow these steps:

1.  **Clone the `llama.cpp` repository:**
    ```bash
    git clone https://github.com/ggml-org/llama.cpp.git
    cd llama.cpp
    ```
2.  **Build `llama-server` using CMake from the root of the `llama.cpp` project:**
    ```bash
    cmake -B build
    cmake --build build --config Release -t llama-server
    ```
    The binary will be located at `./build/bin/llama-server`.

    For more details, refer to the [llama.cpp server tools documentation](https://github.com/ggml-org/llama.cpp/tree/master/tools/server).

## Usage

[Instructions on how to use the project]

## Subscriptions

[Details about any subscription models or services related to this project]

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
