# PeerDrive

A distributed peer-to-peer file storage system built in Go with encryption, automatic replication, and comprehensive monitoring.

## Overview

### What is PeerDrive?

PeerDrive is a production-ready, decentralized file storage system designed for secure and resilient data distribution across peer-to-peer networks. Built entirely in Go with zero external dependencies, it provides enterprise-grade features in a lightweight, easy-to-deploy package.

At its core, PeerDrive creates a distributed storage network where files are automatically replicated across multiple nodes. When you store a file on any node, it's immediately encrypted with AES-256 encryption and propagated to all connected peers. This ensures your data remains available even if individual nodes go offline or fail.

### How It Works

1. **Content-Addressable Storage**: Files are identified by their SHA-256 hash, ensuring data integrity and deduplication
2. **Automatic Replication**: When a file is stored, it's broadcast to all connected peers who automatically fetch and store it
3. **Peer Discovery**: Nodes can find each other through manual bootstrap configuration, local network discovery (mDNS), or peer exchange (PEX)
4. **Encryption Layer**: All files are encrypted before storage and network transmission, ensuring data privacy
5. **Streaming Architecture**: Files are transferred using streaming I/O, allowing efficient handling of files of any size with constant memory usage

### Use Cases

PeerDrive is ideal for scenarios requiring distributed, fault-tolerant storage:

- **Distributed Backup Systems**: Replicate critical data across multiple geographic locations with automatic integrity verification
- **Edge Computing**: Store data close to edge nodes for low-latency access with built-in monitoring
- **Development & CI/CD**: Share build artifacts across distributed build nodes with automatic cleanup
- **Content Distribution**: Create CDN-like networks for media distribution with bandwidth tracking
- **Collaborative Workflows**: Share files across distributed teams with real-time replication

## Key Features

### Core Storage & Security

- **Distributed Storage**: Files are automatically replicated across all connected peer nodes in real-time. When you store a file on one node, it's immediately broadcast to the network, ensuring redundancy and high availability. Even if multiple nodes fail, your data remains accessible from surviving peers.

- **AES-256 Encryption**: Industry-standard encryption protects your data at rest and in transit. Every file is encrypted before being written to disk or sent over the network. Configurable encryption keys ensure you maintain full control over your data security.

- **Content-Addressable Storage (CAS)**: Files are organized and identified by their SHA-256 hash, creating a tamper-proof storage system. This approach enables automatic deduplication, ensures data integrity, and allows for efficient file retrieval across the network.

### Network & Discovery

- **Flexible Peer Discovery**: Multiple discovery mechanisms ensure nodes can find each other in any environment:
  - **Manual Bootstrap**: Traditional approach for internet-deployed nodes
  - **mDNS Local Discovery**: Zero-configuration automatic discovery on local networks
  - **Peer Exchange (PEX)**: Gossip-based protocol where nodes learn about peers from their existing connections, enabling organic network growth

- **Resilient Networking**: Built-in auto-reconnection, configurable timeouts, and retry mechanisms ensure stable connections. Supports NAT traversal with separate listen and advertise addresses for complex network topologies.

### Resource Management

- **Storage Quotas**: Prevent disk space exhaustion with configurable storage limits. Interactive quota setup on first run, real-time usage tracking, and smart cleanup prompts when approaching limits. Quotas are enforced before accepting new files, ensuring predictable resource usage.

- **Garbage Collection**: Automated background process runs hourly to verify file integrity by recalculating SHA-256 hashes. Automatically removes corrupted files and orphaned data, maintaining storage health without manual intervention.

- **Streaming I/O**: Memory-efficient architecture uses streaming for all file operations. Transfer files of any size while using only ~32KB of memory per operation, making PeerDrive suitable for resource-constrained environments.

### Monitoring & Observability

- **Prometheus Metrics**: Comprehensive metrics tracking for production deployments:
  - File operations (stored, retrieved, deleted)
  - Network statistics (bytes sent/received, peer connections)
  - Storage utilization (used, total, percentage)
  - System health (errors, uptime)

  Metrics available in Prometheus, JSON, and human-readable formats via HTTP endpoints.

- **Health Checks**: Built-in peer health monitoring tracks last-seen timestamps and connection status. Automatic detection of stale or disconnected peers helps maintain network health.

## Quick Start

```bash
# 1. Build
make build

# 2. Generate a secure key (64 hex characters, which represents a 32-byte key)
export PEERDRIVE_KEY=$(openssl rand -hex 32)

# 3. Start first node
./bin/peerdrive -addr :3000 -metrics :9090 -discover-local -interactive

# 4. Start second node (in another terminal, using the same key)
export PEERDRIVE_KEY="use-the-same-hex-key-generated-above"
./bin/peerdrive -addr :4000 -bootstrap localhost:3000 -discover-local -interactive

# 5. Store and retrieve files
PeerDrive> store myfile.txt
PeerDrive> list
PeerDrive> get myfile.txt
```

## Installation

### Prerequisites

- Go 1.25.6 or higher
- Make (optional)
- Network connectivity between nodes

### Build

```bash
git clone https://github.com/DishaKawatra/PeerDrive.git
cd PeerDrive
make build
```

## Configuration

PeerDrive supports flexible configuration with options resolvable in the following order of precedence (highest first):

1. **Command-Line Flags** (overrides everything)
2. **Environment Variables**
3. **YAML Config File** (specified via `--config`)
4. **Hardcoded Defaults**

### Configuration File

You can start PeerDrive using a YAML config file. Copy the provided [config.yaml.example](config.yaml.example) to `config.yaml`, customize the settings, and start the server:

```bash
./bin/peerdrive -config config.yaml
```

### Environment Variables & CLI Flags

| CLI Flag                    | Environment Variable        | Description                                            | Default            |
| --------------------------- | --------------------------- | ------------------------------------------------------ | ------------------ |
| `--config`                  | â€”                           | Path to YAML config file                               | None               |
| `--addr`                    | `PEERDRIVE_LISTEN`          | Listen address for the file server                     | `:3000`            |
| `--advertise`               | `PEERDRIVE_ADVERTISE`       | Address to advertise to peers                          | Auto-detected      |
| `--bootstrap`               | `PEERDRIVE_BOOTSTRAP`       | Comma-separated bootstrap node addresses               | None               |
| `--public-ip`               | `PEERDRIVE_PUBLIC_IP`       | Auto-detect and advertise node's public IP             | `false`            |
| `--key`                     | `PEERDRIVE_ENC_KEY`         | AES-256 encryption key (32 raw bytes or 64 hex chars)  | **Required**       |
| `--quota`                   | `PEERDRIVE_QUOTA`           | Maximum storage quota (e.g. 5GB)                       | None               |
| `--interactive`             | `PEERDRIVE_INTERACTIVE`     | Enable interactive terminal mode                       | `false`            |
| `--demo`                    | `PEERDRIVE_DEMO`            | Run demo mode with test data                           | `false`            |
| `--verbose` / `--debug`     | `PEERDRIVE_VERBOSE`         | Enable debug logging level                             | `false`            |
| `--metrics`                 | `PEERDRIVE_METRICS`         | Prometheus metrics endpoint address                    | Disabled           |
| `--discover-local`          | `PEERDRIVE_DISCOVER_LOCAL`  | Enable mDNS local discovery                            | `false`            |
| `--discover-pex`            | `PEERDRIVE_DISCOVER_PEX`    | Enable Peer Exchange (PEX)                             | `false`            |
| `--log-level`               | `PEERDRIVE_LOG_LEVEL`       | Output logging level (debug, info, warn, error)        | `info`             |
| `--fetch-timeout`           | `PEERDRIVE_FETCH_TIMEOUT`   | Timeout duration for file fetching                     | `5s`               |
| `--pex-interval`            | `PEERDRIVE_PEX_INTERVAL`    | Peer list exchange interval                            | `5m`               |
| `--gc-interval`             | `PEERDRIVE_GC_INTERVAL`     | Garbage collection execution interval                  | `1h`               |
| `--gc-delay`                | `PEERDRIVE_GC_DELAY`        | Initial garbage collection delay on boot               | `5m`               |

## Usage

### Basic Deployment

**Single Node:**

```bash
./bin/peerdrive -addr :3000
```

**Multi-Node with Auto-Discovery:**

```bash
# Node 1
./bin/peerdrive -addr :3000 -discover-local -interactive

# Node 2
./bin/peerdrive -addr :4000 -discover-local -interactive
```

**Internet Deployment:**

```bash
# Bootstrap node
export PEERDRIVE_KEY='production-key'
./bin/peerdrive -addr :3000 -public-ip -discover-pex

# Client node
export PEERDRIVE_KEY='production-key'
./bin/peerdrive -addr :3000 -bootstrap 203.0.113.5:3000 -discover-pex
```

### Peer Discovery

**1. Manual Bootstrap** - Specify bootstrap nodes manually

```bash
./bin/peerdrive -addr :3000 -bootstrap peer1:3000,peer2:3000
```

**2. Local Discovery (mDNS)** - Zero-config discovery on LANs

```bash
./bin/peerdrive -addr :3000 -discover-local
```

**3. Peer Exchange (PEX)** - Learn peers from existing connections

```bash
./bin/peerdrive -addr :3000 -discover-pex -bootstrap initial-peer:3000
```

**Combine All Methods:**

```bash
./bin/peerdrive -addr :3000 -bootstrap seed:3000 -discover-local -discover-pex
```

### Interactive Commands

```
store <filename>        - Store a file
get <filename>          - Retrieve a file
delete <filename>       - Delete from network
list                    - List all files
quota                   - Show storage quota
metrics                 - Show metrics
peers                   - Show connected peers
discover                - Show discovery status
status                  - Show server status
help                    - Show all commands
quit                    - Exit
```

#### Example Session

```bash
PeerDrive> status
Server listening on: :3000
Local IP: 192.168.1.100
Connected peers: 2

PeerDrive> peers
Connected Peers (2):
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Address                   â”‚ Status      â”‚ Last Seen      â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ 192.168.1.101:3000        â”‚ âœ“ Healthy   â”‚ 5s ago         â”‚
â”‚ 192.168.1.102:3000        â”‚ âœ“ Healthy   â”‚ 8s ago         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

PeerDrive> store document.txt
File 'document.txt' stored successfully

PeerDrive> list
Files stored on this node (1 files):
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Filename                            â”‚ Size (bytes)â”‚ Hash (first 8 chars) â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ document.txt                        â”‚        2048 â”‚ a3b5c7d9             â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

PeerDrive> get document.txt
File 'document.txt' retrieved successfully

PeerDrive> delete old_file.txt
Are you sure you want to delete 'old_file.txt'? This will remove it from all nodes. (y/N): y
File 'old_file.txt' deleted successfully from all nodes

PeerDrive> discover

=== Peer Discovery Status ===
mDNS Discovered Peers: 2
  - 192.168.1.105:3000
  - 192.168.1.106:4000

Peer Exchange (PEX): 5 known peers
  bootstrap: 1 peers
  mdns: 2 peers
  pex: 2 peers

PeerDrive> metrics
=== PeerDrive Metrics ===

File Operations:
  Stored:     15
  Retrieved:  8
  Deleted:    2

Network:
  Bytes Sent:     256.45 MB
  Bytes Received: 189.32 MB
  Peers Connected: 3

Storage:
  Used:        1.23 GB
  Total:       5.00 GB
  Utilization: 24.6%

System:
  Errors:  0
  Uptime:  2h 34m
  Started: 2026-02-05 14:30:00
```

### Storage Quota

On first startup, you can configure your storage quota interactively:

```
Enter maximum storage size (e.g., 1GB, 500MB, 10GB): 5GB
```

Alternatively, you can set the quota non-interactively for headless/automated deployments using the `-quota` command-line flag or the `PEERDRIVE_QUOTA` environment variable:

```bash
./bin/peerdrive -addr :3000 -quota 5GB
```

*Note: If no quota config exists and the application is run in a non-interactive/headless environment, it will default to a 10GB storage quota.*

Check quota status:

```bash
PeerDrive> quota
=== Storage Quota ===
Used:      2.34 GB
Total:     5.00 GB
Available: 2.66 GB
Usage:     46.8%
```

### Metrics & Monitoring

Enable metrics server:

```bash
./bin/peerdrive -addr :3000 -metrics :9090
```

**Endpoints:**

- `http://localhost:9090/` - Web dashboard
- `http://localhost:9090/metrics` - Prometheus format
- `http://localhost:9090/metrics/json` - JSON format
- `http://localhost:9090/health` - Health check

## Architecture

```mermaid
graph TB
    subgraph "PeerDrive Node"
        CLI[CLI Interface]
        Server[File Server]
        Store[Local Storage]
        Crypto[Encryption]
        Transport[P2P Transport]
        Quota[Quota Manager]
        Metrics[Metrics]
    end

    CLI --> Server
    Server --> Store
    Server --> Crypto
    Server --> Transport
    Server --> Quota
    Server --> Metrics
    Transport --> Network[Network]

    Network --> Peer1[Peer 1]
    Network --> Peer2[Peer 2]
    Network --> Peer3[Peer N]
```

### Network Topology

```mermaid
graph LR
    subgraph "Bootstrap Node"
        N1[Node 1<br/>:3000]
    end

    subgraph "Peer Nodes"
        N2[Node 2<br/>:4000]
        N3[Node 3<br/>:5000]
        N4[Node 4<br/>:6000]
    end

    N1 <-->|TCP| N2
    N1 <-->|TCP| N3
    N1 <-->|TCP| N4
    N2 <-->|TCP| N3
    N3 <-->|TCP| N4

    style N1 fill:#4a90e2
    style N2 fill:#50c878
    style N3 fill:#50c878
    style N4 fill:#50c878
```

### File Replication Flow

```mermaid
sequenceDiagram
    participant Client
    participant Node1
    participant Node2
    participant Node3

    Client->>Node1: Store file "data.txt"
    Node1->>Node1: Encrypt & Store Locally
    Node1->>Node2: Broadcast: File Available
    Node1->>Node3: Broadcast: File Available
    Node2->>Node1: Request file stream
    Node3->>Node1: Request file stream
    Node1->>Node2: Stream encrypted file
    Node1->>Node3: Stream encrypted file
    Node2->>Node2: Store encrypted file
    Node3->>Node3: Store encrypted file

    Note over Node1,Node3: File now replicated across 3 nodes

    Client->>Node2: Get file "data.txt"
    Node2->>Node2: Decrypt & Read Locally
    Node2->>Client: Return file content
```

## Project Structure

```
PeerDrive/
â”œâ”€â”€ cmd/peerdrive/          # CLI application
â”œâ”€â”€ internal/               # Private packages
â”‚   â”œâ”€â”€ crypto/            # AES-256 encryption
â”‚   â”œâ”€â”€ metrics/           # Metrics collection
â”‚   â”œâ”€â”€ network/           # File server & discovery
â”‚   â”œâ”€â”€ quota/             # Storage quota management
â”‚   â””â”€â”€ storage/           # Content-addressable storage
â”œâ”€â”€ pkg/p2p/               # P2P networking library
â”œâ”€â”€ Makefile
â””â”€â”€ README.md
```

## Testing

```bash
# Run all tests
make test

# Test coverage
make test-coverage

# Multi-node test
make test-multinode
```

## Performance

- **Memory Usage**: Constant ~32KB per transfer (streaming)
- **Encryption**: AES-256-CTR mode with HMAC-SHA256 authentication
- **Hash Algorithm**: SHA-256
- **GC Interval**: Every 1 hour
- **PEX Interval**: Every 5 minutes

## Author

**Disha Kawatra**
