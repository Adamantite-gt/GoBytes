FROM golang:latest AS setup

# Install Node.js 18.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

WORKDIR /app

# Copy dependency definitions
COPY package*.json go.mod ./

# Install Node.js dependencies
RUN npm install

# Copy the entire project
COPY . .

# Build the native CGo bridge for Linux (generates libbytes.so)
RUN npm run build:linux


# ---------------------------------------------------------
# Test Stage (inherits from setup)
# ---------------------------------------------------------
FROM setup AS test

# Default command to run when starting this stage:
# Run both the Mocha (JavaScript) tests and the Go tests.
CMD ["sh", "-c", "npx mocha test && go test -v ./test-port"]

# build the image:
#     docker build --target (setup|test) -t bytes-go:test .
# run the test:
#     docker run -it --rm bytes-go:test bash (to get the interactive mode)
#     cd /app
#     npx mocha test-original