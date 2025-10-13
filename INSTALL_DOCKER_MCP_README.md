# Docker MCP Gateway Installation Script

This script automates the installation and setup of Docker MCP Gateway with Claude Code integration.

## Prerequisites

Before running this script, ensure you have:

1. **Docker** installed and running
   - Ubuntu: [Install Docker Engine](https://docs.docker.com/engine/install/ubuntu/)
   - macOS: [Install Docker Desktop](https://docs.docker.com/desktop/install/mac-install/)

2. **Claude Code** installed
   ```bash
   curl -fsSL https://claude.ai/install.sh | sh
   ```

3. **Git** installed (usually pre-installed on most systems)

## Installation

### Quick Install
```bash
# Download and run the script
curl -fsSL https://raw.githubusercontent.com/your-repo/install-docker-mcp-gateway.sh | bash
```

### Manual Install
```bash
# Download the script
wget https://raw.githubusercontent.com/your-repo/install-docker-mcp-gateway.sh

# Make it executable
chmod +x install-docker-mcp-gateway.sh

# Run the installation
./install-docker-mcp-gateway.sh
```

## Architecture Overview

### Component Diagram
```
┌─────────────────────────────────────────────────────────────────┐
│                    CODING AGENT ENVIRONMENT                     │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────────────┐ │
│  │ Claude Code │◄──►│ MCP Protocol │◄──►│ MCP Gateway Process │ │
│  │   (Agent)   │    │  (JSON-RPC)  │    │  (Host Process)     │ │
│  └─────────────┘    └──────────────┘    └─────────┬───────────┘ │
│                                                   │             │
│                                                   ▼             │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │           MCP SERVERS (DOCKER CONTAINERS)                  │ │
│  │                                                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │
│  │  │mcp/sqlite   │  │mcp/duckduckgo│ │   mcp/github        │ │ │
│  │  │(container)  │  │ (container) │  │   (container)       │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │
│  │                                                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │
│  │  │mcp/postgres │  │  mcp/slack  │  │ mcp/aws-docs        │ │ │
│  │  │(container)  │  │ (container) │  │ (container)         │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │
│  │                                                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │
│  │  │ mcp/notion  │  │ mcp/stripe  │  │ mcp/youtube-        │ │ │
│  │  │(container)  │  │ (container) │  │ transcript          │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                EXTERNAL RESOURCES                           │ │
│  │                                                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │
│  │  │    Local    │  │   GitHub    │  │     DuckDuckGo      │ │ │
│  │  │ Filesystem  │  │     API     │  │     Search API      │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │
│  │                                                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │
│  │  │ PostgreSQL  │  │ Slack APIs  │  │    AWS Docs API     │ │ │
│  │  │  Database   │  │             │  │                     │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Flow Diagram: Agent-to-Resource Interaction
```
┌─────────────┐                                    ┌─────────────────┐
│ Claude Code │                                    │ Docker Container│
│   (Agent)   │                                    │  MCP Gateway    │
└──────┬──────┘                                    └─────────┬───────┘
       │                                                     │
       │ 1. Request: "Search for Python tutorials"          │
       ├────────────────────────────────────────────────────►│
       │                                                     │
       │                                                     │ 2. Parse request
       │                                                     │    Route to server
       │                                                     ▼
       │                                          ┌─────────────────┐
       │                                          │   DuckDuckGo    │
       │                                          │  MCP Server     │
       │                                          └─────────┬───────┘
       │                                                     │
       │                                                     │ 3. Execute search
       │                                                     ▼
       │                                          ┌─────────────────┐
       │                                          │   DuckDuckGo    │
       │                                          │   Search API    │
       │                                          └─────────┬───────┘
       │                                                     │
       │                                                     │ 4. Return results
       │ 5. Formatted response                               │
       │◄────────────────────────────────────────────────────┴───────
       │   "Found 10 Python tutorials..."                          
       │                                                            
       ▼                                                            
┌─────────────┐                                                     
│   Agent     │                                                     
│  continues  │                                                     
│    task     │                                                     
└─────────────┘                                                     
```

### Detailed Request Flow: Multi-Server Integration
```
     Agent Request                MCP Gateway              MCP Servers              External APIs
         │                           │                         │                       │
         │ "Get GitHub issue         │                         │                       │
         │  and search docs"         │                         │                       │
         ├──────────────────────────►│                         │                       │
         │                           │                         │                       │
         │                           │ Route to github server  │                       │
         │                           ├────────────────────────►│                       │
         │                           │                         │ github.get_issue()    │
         │                           │                         ├──────────────────────►│
         │                           │                         │◄──────────────────────┤
         │                           │◄────────────────────────┤ Issue data            │
         │                           │                         │                       │
         │                           │ Route to search server  │                       │
         │                           ├─────────────────────────┼──────────────────────►│
         │                           │                         │ duckduckgo.search()   │
         │                           │                         ├──────────────────────►│
         │                           │                         │◄──────────────────────┤
         │                           │◄────────────────────────┤ Search results        │
         │                           │                         │                       │
         │                           │ Combine responses       │                       │
         │                           │ Format for agent        │                       │
         │◄──────────────────────────┤                         │                       │
         │ Combined response:        │                         │                       │
         │ - Issue details           │                         │                       │
         │ - Related documentation   │                         │                       │
         │                           │                         │                       │
```

### MCP Server Lifecycle Management
```
Docker MCP Gateway Deployment Flow:

1. Gateway Process Startup
   ┌─────────────────────────────┐
   │ docker mcp gateway run      │
   │ ├─ Load catalog config      │
   │ ├─ Initialize gateway proxy │
   │ └─ Listen for client conn   │
   └─────────────────────────────┘
                │
                ▼
2. Server Enablement (Container-per-Server)
   ┌──────────────────────────────────────────────────────────────┐
   │ docker mcp server enable <server-name>                      │
   │                                                              │
   │ ┌─────────────────┐    ┌─────────────────┐    ┌────────────┐│
   │ │ Pull mcp/sqlite │    │Pull mcp/aws-docs│    │Pull mcp/   ││
   │ │ Docker image    │    │ Docker image    │    │youtube-    ││
   │ └─────────────────┘    └─────────────────┘    │transcript  ││
   │           │                       │           └────────────┘│
   │           ▼                       ▼                  │     │
   │ ┌─────────────────┐    ┌─────────────────┐           ▼     │
   │ │ Start container │    │ Start container │    ┌────────────┐│
   │ │ (tender_brown)  │    │(jolly_kowalevski)│    │Start cont  ││
   │ └─────────────────┘    └─────────────────┘    │(nervous_   ││
   │                                               │mendel)     ││
   │                                               └────────────┘│
   └──────────────────────────────────────────────────────────────┘
                                │
                                ▼
3. Runtime Architecture
   ┌─────────────┐    ┌─────────────────┐    ┌──────────────────┐
   │ Claude Code │◄──►│ Gateway Process │◄──►│ MCP Containers   │
   │   Client    │    │ (Proxy/Router)  │    │ (Auto-named)     │
   │             │    │                 │    │ - tender_brown   │
   │             │    │                 │    │ - jolly_kowalevski│
   │             │    │                 │    │ - nervous_mendel │
   └─────────────┘    └─────────────────┘    └──────────────────┘

Command Mapping & Container Verification:
- docker mcp server ls        → List enabled servers
- docker mcp server enable    → Pull image + start container
- docker mcp server disable   → Stop and remove container
- docker ps                   → See actual MCP containers running
- docker mcp tools ls         → Show tools from all containers
- docker mcp tools count      → Verify tool availability
```

## Understanding MCP Server Deployment

### **Key Architecture Insights**

**🔍 Deployment Model**: Each MCP server runs as an **individual Docker container**, not as host processes.

**🎯 Gateway Role**: The `docker mcp gateway run` command starts a **host process** (not a container) that acts as a proxy/router between Claude Code and the MCP server containers.

**📦 Container Lifecycle**: When you enable an MCP server:
1. Docker pulls the appropriate `mcp/<server-name>` image
2. Starts a new container with auto-generated name
3. Gateway registers the container and routes requests to it

### **Verification Commands**

```bash
# Start the gateway process (required for MCP servers to work)
docker mcp gateway run

# In another terminal, enable a server and watch containers
docker mcp server enable sqlite
docker ps  # You'll see new mcp/sqlite container

# Check tools are available from the new server
docker mcp tools count  # Should increase

# Test the tools with key=value format
docker mcp tools call <tool-name> arg1=value1 arg2=value2
```

### **Tool Testing Examples**

```bash
# List all available tools in JSON format for detailed schemas
docker mcp tools ls --format=json

# Inspect a specific tool to understand its parameters
docker mcp tools inspect get_video_info

# YouTube Video Information
docker mcp tools call get_video_info url=https://www.youtube.com/watch?v=xhrqmAWI_cw

# YouTube Transcript Extraction (Full Text)
docker mcp tools call get_transcript url=https://www.youtube.com/watch?v=xhrqmAWI_cw

# YouTube Transcript with Timestamps
docker mcp tools call get_timed_transcript url=https://www.youtube.com/watch?v=xhrqmAWI_cw lang=en

# DuckDuckGo Search
docker mcp tools call search query="vibe coding" max_results=3

# AWS Documentation Search
docker mcp tools call search_documentation search_phrase="S3 bucket encryption" limit=2

# Fetch Web Content
docker mcp tools call fetch_content url=https://github.com/docker/mcp-gateway

# AWS Documentation Reading
docker mcp tools call read_documentation url=https://docs.aws.amazon.com/AmazonS3/latest/userguide/default-bucket-encryption.html max_length=5000

# AWS Documentation Recommendations
docker mcp tools call recommend url=https://docs.aws.amazon.com/AmazonS3/latest/userguide/default-bucket-encryption.html
```

### **Tool Call Response Examples**

**Video Information Response:**
```json
{
  "title": "Stop The Prompting... Vibe Coding has Evolved With This",
  "description": "Vibe coding with Claude Code explores a new agentic framework...",
  "uploader": "AI LABS",
  "upload_date": "2025-10-12T17:06:02.733650",
  "duration": "8 minutes"
}
```

**Search Response:**
```
Found 3 search results:

1. Vibe coding - Wikipedia
   URL: https://en.wikipedia.org/wiki/Vibe_coding
   Summary: Vibe coding is an artificial intelligence-assisted software development technique...
```

### **Container Naming Pattern**

Docker automatically assigns creative names to MCP containers:
- `mcp/sqlite` → `tender_brown`
- `mcp/aws-documentation` → `jolly_kowalevski` 
- `mcp/youtube-transcript` → `nervous_mendel`

### **Why This Architecture Works**

✅ **Isolation**: Each MCP server runs in its own container
✅ **Security**: Containers have limited host access
✅ **Scalability**: Easy to add/remove servers without affecting others
✅ **Management**: Simple enable/disable commands handle container lifecycle
✅ **Debugging**: Can inspect individual server containers with `docker logs <container-name>`

## What the Script Does

1. **Detects your OS** (Ubuntu/macOS) and adjusts installation accordingly
2. **Checks prerequisites** (Docker, Claude Code, Git)
3. **Installs Go** using the appropriate package manager
4. **Builds Docker MCP Gateway** from source
5. **Initializes MCP environment** and catalog
6. **Enables default servers** (DuckDuckGo, GitHub)
7. **Connects Claude Code** to the MCP Gateway
8. **Shows available tools** and usage instructions

## Post-Installation Usage

### Browse Available MCP Servers
```bash
docker mcp catalog show              # Browse 100+ available servers
```

### Manage MCP Servers
```bash
docker mcp server ls                 # List enabled servers
docker mcp server enable <name>      # Enable new servers
docker mcp server disable <name>     # Disable servers
```

### View Available Tools
```bash
docker mcp tools ls                  # See all tools from enabled servers
```

### Claude Code Integration
```bash
claude mcp list                      # List configured MCP servers
```

## Popular MCP Servers to Try

- `filesystem` - Local filesystem access
- `postgres` - PostgreSQL database integration
- `slack` - Slack workspace integration
- `notion` - Notion workspace tools
- `stripe` - Stripe payment processing
- `aws-documentation` - AWS documentation access

## Troubleshooting

### Script Fails to Install Go
- **Ubuntu**: Make sure you have `sudo` access
- **macOS**: Install Homebrew first: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### Docker Permission Issues
```bash
# Add your user to docker group (Ubuntu)
sudo usermod -aG docker $USER
# Then logout and login again
```

### Claude Code Not Found
```bash
# Install Claude Code
curl -fsSL https://claude.ai/install.sh | sh
# Restart your terminal
```

## System Requirements

- **OS**: Ubuntu 18.04+, macOS 10.15+
- **Docker**: 20.10+
- **Claude Code**: 1.0+
- **Disk Space**: ~500MB for Go and build tools

## Security Notes

- The script builds MCP Gateway from official Docker sources
- All components run in isolated Docker containers
- MCP servers have restricted access based on their configuration
- You can review enabled servers anytime with `docker mcp server ls`

## Support

- [Docker MCP Gateway Issues](https://github.com/docker/mcp-gateway/issues)
- [Claude Code Documentation](https://docs.claude.ai/en/docs/claude-code)
- [Model Context Protocol Spec](https://modelcontextprotocol.io/)