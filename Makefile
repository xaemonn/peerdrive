.PHONY: build test clean run fmt vet help

# Binary configuration
BINARY_NAME=peerdrive
BIN_DIR=./bin

# Build variables
GO=go
LDFLAGS=-ldflags "-s -w"

# Default target
all: build

# Build the application
build:
	@echo "Building $(BINARY_NAME)..."
	@mkdir -p $(BIN_DIR)
	$(GO) build $(LDFLAGS) -o $(BIN_DIR)/$(BINARY_NAME) ./cmd/peerdrive
	@echo "Build complete: $(BIN_DIR)/$(BINARY_NAME)"

# Run tests
test:
	@echo "Running tests..."
	$(GO) test -v ./...
	@echo "Tests complete"

# Clean build artifacts
clean:
	@echo "Cleaning..."
	@rm -rf $(BIN_DIR)
	@rm -f coverage.out coverage.html
	@rm -rf storage/
	@echo "Clean complete"

# Run the application
run: build
	@echo "Starting PeerDrive..."
	$(BIN_DIR)/$(BINARY_NAME)

# Format code
fmt:
	@echo "Formatting code..."
	$(GO) fmt ./...

# Run go vet
vet:
	@echo "Running go vet..."
	$(GO) vet ./...

# Help
help:
	@echo "PeerDrive Makefile Commands:"
	@echo ""
	@echo "  make build    - Build the application"
	@echo "  make test     - Run all tests"
	@echo "  make clean    - Remove build artifacts and storage"
	@echo "  make run      - Build and run the application"
	@echo "  make fmt      - Format code with go fmt"
	@echo "  make vet      - Run go vet for code quality"
	@echo "  make help     - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  ./bin/peerdrive -interactive              # Run in interactive mode"
	@echo "  ./bin/peerdrive -addr :3000 -metrics :9090 # Run with metrics"
	@echo "  ./bin/peerdrive -demo                      # Run demo mode"
	@echo ""
