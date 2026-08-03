# GoBytes
A high-performance, cross-language byte utility library written in **Go** and exposed to **Node.js** via a CGo bridge and [Koffi](https://koffi.dev/) FFI. 

Ported directly from TJ Holowaychuk's original [`bytes`](https://github.com/bytesjs/bytes.js) module with 100% feature parity.


---
## 🛠️ Prerequisites

Ensure you have the following installed on your system:

- **Node.js**: `v18.0.0` or higher
- **Go**: `v1.20` or higher
- **C Compiler / CGo Toolchain**:
  - **Windows**: [MinGW-w64](https://www.winlibs.com/) or GCC via MSYS2 / WinLibs (required for CGo compilation)
  - **macOS**: Xcode Command Line Tools (`xcode-select --install`)
  - **Linux**: `build-essential` (`sudo apt install build-essential`)

---

## 🐳 Docker Setup

Docker provides an isolated environment to build and test the project without installing local toolchains.

### 1. Build the Development Environment
To build an image with Go, Node.js, and all required dependencies (the `setup` target):
```bash
docker build --target setup -t bytes-go:setup .
```

### 2. Run the Tests via Docker
To build and run the test image (which automatically executes both Mocha and Go tests):
```bash
docker build --target test -t bytes-go:test .
docker run --rm bytes-go:test
```

For an interactive test shell:
```bash
docker run -it --rm bytes-go:test bash

```

---

## 📦 Installation (Go)

Installing the Go package from GitHub is done directly through the Go CLI.

### Adding a Library to Your Project (`go get`)

**1. Initialize your module** *(Skip if already done)*:
If you haven't already started a Go module in your project folder, run this first to create a `go.mod` file to track your dependencies:
```bash
go mod init your-project-name
```

**2. Download the package**:
Run `go get` followed by the GitHub URL to install the GoBytes library:
```bash
go get github.com/Adamantite-gt/GoBytes
```

**3. Import it in your code**:
You can now import and use the package at the top of your `.go` files:
```go
import "github.com/Adamantite-gt/GoBytes/src"
```

---

## 🧪 Running Tests & Fuzzing

### 1. Node.js Mocha Test Suite (Original JS Compatibility)
Execute the original Mocha test suite to verify the Koffi FFI dynamic library bridge:
```bash
npm test
```
*(Or `npx mocha test-original`)*

### 2. Go Native Unit Tests
Run the native Go unit tests:
```bash
go test ./test-port
```

### 3. Differential Fuzzing Suite
Run the 60s+ differential fuzzer comparing JS reference output vs Go implementation across millions of randomized inputs:
```bash
npm run fuzz
```

---

## ⚡ Performance & Benchmarks

Run the benchmark suite to evaluate throughput ($\text{ops/sec}$), tail latency ($P_{99}$), startup time, and memory footprint:

```bash
npm run bench
```

Detailed benchmarking methodologies and empirical results can be found in:
- [`bench/methodology.md`](https://github.com/Adamantite-gt/GoBytes/blob/main/bench/methodology.md)
- [`bench/results.json`](https://github.com/Adamantite-gt/GoBytes/blob/main/bench/results.json)

---
## Usage

#### bytes(number｜string value, [options]): number｜string｜null

Default export function. Delegates to either `bytes.format` or `bytes.parse` based on the type of `value`.

**Arguments**

| Name    | Type     | Description        |
|---------|----------|--------------------|
| value   | `number`｜`string` | Number value to format or string value to parse |
| options | `Object` | Conversion options for `format` |

**Returns**

| Name    | Type             | Description                                     |
|---------|------------------|-------------------------------------------------|
| results | `string`｜`number`｜`null` | Return null upon error. Numeric value in bytes, or string value otherwise. |

**Example**

```go
bytes(1024);
// output: '1KB'

bytes('1KB');
// output: 1024
```

#### bytes.format(number value, [options]): string｜null

Format the given value in bytes into a string. If the value is negative, it is kept as such. If it is a float, it is
 rounded.

**Arguments**

| Name    | Type     | Description        |
|---------|----------|--------------------|
| value   | `number` | Value in bytes     |
| options | `Object` | Conversion options |

**Options**

| Property          | Type   | Description                                                                             |
|-------------------|--------|-----------------------------------------------------------------------------------------|
| decimalPlaces | `number`｜`null` | Maximum number of decimal places to include in output. Default value to `2`. |
| fixedDecimals | `boolean`｜`null` | Whether to always display the maximum number of decimal places. Default value to `false` |
| thousandsSeparator | `string`｜`null` | Example of values: `' '`, `','` and `'.'`... Default value to `''`. |
| unit | `string`｜`null` | The unit in which the result will be returned (B/KB/MB/GB/TB). Default value to `''` (which means auto detect). |
| unitSeparator | `string`｜`null` | Separator to use between number and unit. Default value to `''`. |

**Returns**

| Name    | Type             | Description                                     |
|---------|------------------|-------------------------------------------------|
| results | `string`｜`null` | Return null upon error. String value otherwise. |

**Example**

```go
bytes.format(1024);
// output: '1KB'

bytes.format(1000);
// output: '1000B'

bytes.format(1000, {thousandsSeparator: ' '});
// output: '1 000B'

bytes.format(1024 * 1.7, {decimalPlaces: 0});
// output: '2KB'

bytes.format(1024, {unitSeparator: ' '});
// output: '1 KB'
```

#### bytes.parse(string｜number value): number｜null

Parse the string value into an integer in bytes. If no unit is given, or `value`
is a number, it is assumed the value is in bytes.

Supported units and abbreviations are as follows and are case-insensitive:

  * `b` for bytes
  * `kb` for kilobytes
  * `mb` for megabytes
  * `gb` for gigabytes
  * `tb` for terabytes
  * `pb` for petabytes

The units are in powers of two, not ten. This means 1kb = 1024b according to this parser.

**Arguments**

| Name          | Type   | Description        |
|---------------|--------|--------------------|
| value   | `string`｜`number` | String to parse, or number in bytes.   |

**Returns**

| Name    | Type        | Description             |
|---------|-------------|-------------------------|
| results | `number`｜`null` | Return null upon error. Value in bytes otherwise. |

**Example**

```go
bytes.parse('1KB');
// output: 1024

bytes.parse('1024');
// output: 1024

bytes.parse(1024);
// output: 1024
```

---

## 📖 Usage Examples

### JavaScript / Node.js
```javascript
const bytes = require('./index.js');

// Convert string to bytes integer
bytes('1KB');                     // 1024
bytes.parse('1.5MB');             // 1572864

// Convert bytes integer to formatted string
bytes(1024);                      // '1KB'
bytes.format(1000, { thousandsSeparator: ' ' }); // '1 000B'
bytes.format(1024, { unitSeparator: ' ' });      // '1 KB'
bytes.format(1024, { decimalPlaces: 3, fixedDecimals: true }); // '1.000KB'
```

### Native Go
```go
package main

import (
    "fmt"
    bytesutil "github.com/Adamantite-gt/GoBytes/src"
)

func main() {
    fmt.Println(bytesutil.Parse("1.5MB")) // Outputs: 1572864
    fmt.Println(bytesutil.Format(1024, nil)) // Outputs: "1KB"
}
```

---

## 🏗️ Project Architecture

```text
GoBytes/
├── bench/
│   ├── benchmark.js        # Node.js performance benchmark runner
│   ├── bytes_bench_test.go # Go standard testing.B microbenchmarks
│   ├── main.go             # Go benchmark runner exporting results.json
│   ├── methodology.md      # Detailed benchmark methodology & formulas
│   └── results.json        # Quantitative p99, RSS, startup & throughput metrics
├── bridge/
│   └── bridge.go           # CGo export functions bridging C types to Go
├── fuzz/
│   ├── BUGS_FOUND.md       # Log of bugs found during differential fuzzing
│   ├── harness.js          # Differential fuzzer engine comparing JS vs Go
│   ├── index.js            # Original reference JS library
│   └── log.txt             # 60s+ execution log demonstrating 0 divergences
├── src/
│   └── bytes.go            # Pure Go implementation of bytes formatting and parsing
├── test/
│   ├── .eslintrc.yml       # ESLint configuration for test suite
│   ├── byte-format.js      # Format function test suite (Mocha)
│   ├── byte-parse.js       # Parse function test suite (Mocha)
│   └── bytes.js            # Core constructor unit tests (Mocha)
├── test-port/
│   └── bytes_test.go       # Go native unit test suite
├── .gitignore              # Git ignore rules
├── DECISIONS.md            # Architecture and implementation decisions log
├── Dockerfile              # Docker configuration for dev and test environments
├── go.mod                  # Go module definition
├── index.js                # Node.js FFI wrapper powered by Koffi
├── package.json            # Node.js package configuration
├── port-mortem.toml        # Port-Mortem project metadata
└── README.md               # Project documentation
```

---

## 📄 License

MIT