# Local Graphiti Hybrid Memory (Claude Code + MCP)

A local hybrid memory system that combines **graph-based fact storage** with **semantic search capabilities**, integrated with Claude Code via Model Context Protocol (MCP). This setup provides persistent memory for AI assistants with both structured relationships and semantic understanding.

## Quick Start

```bash
export OPENAI_API_KEY=sk-your-key-here
cd memory/
./bootstrap.sh
```

That's it! The script handles everything: Neo4j setup, Graphiti installation, and Claude Code MCP registration.

## Prerequisites

### Required Tools
- **Docker & Docker Compose**: For Neo4j database
  - [Install Docker](https://docs.docker.com/get-docker/)
  - [Install Docker Compose](https://docs.docker.com/compose/install/)
- **Claude Code CLI**: For MCP integration
  - `npm install -g @anthropic-ai/claude-code` 
  - Or download from [claude.ai/download](https://claude.ai/download)
- **Git**: For cloning Graphiti repository
- **Python 3.10+**: For running Graphiti MCP server

### Recommended Tools
- **uv**: Fast Python package manager (optional, speeds up setup)
  - [Install uv](https://docs.astral.sh/uv/getting-started/installation/)
  - Script falls back to pip if uv is not available

### Environment Variables
```bash
# Required
export OPENAI_API_KEY=sk-your-openai-api-key

# Optional (with defaults)
export NEO4J_USER=neo4j                    # Default: neo4j
export NEO4J_PASSWORD=graphiti             # Default: graphiti  
export NEO4J_URI=bolt://localhost:7687     # Default: bolt://localhost:7687
export MODEL_NAME=gpt-4o-mini              # Default: gpt-4o-mini
```

## Architecture

```
Claude Code ──(MCP stdio)── Graphiti MCP Server (local Python)
                                  │
                     ┌────────────┴────────────┐
                     │                         │
                 Neo4j (Docker)        Semantic Index (OpenAI embeddings)
```

**Components:**
- **Neo4j**: Graph database for storing structured relationships
- **Graphiti**: Hybrid memory framework with MCP server
- **Claude Code**: AI assistant with MCP protocol support  
- **OpenAI**: Embeddings and LLM provider for semantic operations

## Usage Instructions

### 1. Setup
```bash
# Clone this repository and navigate to memory folder
cd memory/

# Set your OpenAI API key
export OPENAI_API_KEY=sk-your-key-here

# Run the bootstrap script
./bootstrap.sh
```

### 2. Verification Steps

**Neo4j Database:**
- Open Neo4j Browser: http://localhost:7474
- Login with credentials: `neo4j` / `graphiti` (or your custom values)
- You should see an empty database ready for graph operations

**Claude Code MCP Integration:**
```bash
# Verify MCP server is registered
claude mcp list
# Should show 'graphiti' in the list

# Test MCP connection in Claude Code
# In Claude Code chat, run: /mcp
# You should see Graphiti tools available
```

### 3. Example Memory Operations

In Claude Code chat, try these commands:

**Adding Memories:**
```
Add a memory that Henry owns Lakeside Tower
Remember that Sarah works at TechCorp as a software engineer
Store the fact that the quarterly meeting is scheduled for Friday
```

**Searching Memories:**
```
What properties does Henry own?
Tell me about Sarah's job
When is the quarterly meeting?
Search for facts about real estate
```

**Graph Queries:**
```
Show me all relationships involving Henry
What connections exist between Sarah and TechCorp?
Find all scheduled events
```

## Verification & Testing

### Health Checks

**Neo4j Database:**
```bash
# Check Neo4j container status
docker ps | grep neo4j

# Test Neo4j connection
docker exec neo4j cypher-shell -u neo4j -p graphiti "RETURN 'Connected!'"

# View Neo4j logs
docker logs neo4j
```

**MCP Server:**
```bash
# List registered MCP servers
claude mcp list

# Test MCP connection (should show available tools)
# In Claude Code: /mcp
```

**Full System Test:**
1. Add a test memory: "Remember that Alice is the project manager for the Apollo initiative"
2. Search for it: "What do you know about Alice?"
3. Verify in Neo4j Browser: `MATCH (n) RETURN n LIMIT 10`

### Expected Outputs

**Successful Setup:**
- Bootstrap script completes without errors
- Neo4j accessible at http://localhost:7474
- `claude mcp list` shows `graphiti` server
- Claude Code `/mcp` command shows Graphiti tools
- Memory operations work in Claude Code chat

**Neo4j Browser:**
- Can connect with `neo4j`/`graphiti` credentials
- Database initially empty, populates as memories are added
- Graph visualization shows nodes and relationships

## Troubleshooting

### Common Issues

**Port Conflicts (7474, 7687):**
```bash
# Check what's using the ports
lsof -i :7474
lsof -i :7687

# Stop conflicting services or change Neo4j ports in docker-compose.yml
```

**API Key Issues:**
```bash
# Verify API key is set
echo $OPENAI_API_KEY

# Test API key with OpenAI
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models | head -20
```

**Claude Code CLI Not Found:**
```bash
# Install Claude Code CLI
npm install -g @anthropic-ai/claude-code

# Or download installer from claude.ai/download
# Add to PATH if needed
```

**Docker Permission Issues (Linux):**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in, or:
newgrp docker

# Test docker access
docker ps
```

**Python/Dependency Issues:**
```bash
# Check Python version (3.10+ required)
python --version

# If uv fails, try pip directly:
cd graphiti/mcp_server
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Logs and Debugging

**Neo4j Logs:**
```bash
docker logs neo4j
docker logs neo4j --follow  # Follow logs in real-time
```

**MCP Server Logs:**
- MCP server logs appear in Claude Code's diagnostic output
- Use Claude Code's developer tools or console for MCP debugging

**Verbose Bootstrap:**
```bash
# Run bootstrap with debug output
bash -x ./bootstrap.sh
```

## Configuration

### Custom Neo4j Settings
Edit `docker-compose.yml` to customize:
- Memory allocation
- Port mappings  
- Authentication
- Data persistence

### Environment Customization
```bash
# Use different OpenAI model
export MODEL_NAME=gpt-4-turbo

# Custom Neo4j connection
export NEO4J_URI=bolt://remote-host:7687
export NEO4J_USER=custom_user
export NEO4J_PASSWORD=secure_password

# Then run bootstrap
./bootstrap.sh
```

### Alternative LLM Providers
For future support of local LLMs like Ollama, modify the `MODEL_NAME` and ensure Graphiti supports the provider.

## File Structure

```
memory/
├── docker-compose.yml      # Neo4j container configuration
├── bootstrap.sh           # One-command setup script
├── README.md              # This documentation
└── graphiti/              # Cloned during setup
    └── mcp_server/        # Graphiti MCP server code
        ├── requirements.txt
        └── graphiti_mcp_server.py
```

## Cleanup

**Stop All Services:**
```bash
# Stop Neo4j container
docker compose down

# Remove MCP registration
claude mcp remove graphiti

# Remove Docker volumes (optional - deletes all data)
docker compose down -v
```

**Complete Removal:**
```bash
# Remove everything including cloned repository
docker compose down -v
rm -rf graphiti/
claude mcp remove graphiti
```

## Support & Contributing

**Documentation:**
- [Graphiti Documentation](https://help.getzep.com/graphiti/)
- [Claude Code MCP Guide](https://docs.claude.com/en/docs/claude-code/mcp)
- [Neo4j Docker Guide](https://hub.docker.com/_/neo4j)

**Issues:**
- Graph operations not working: Check Neo4j connection and Cypher queries
- Semantic search issues: Verify OpenAI API key and model access
- MCP connection problems: Check Claude Code CLI version and stdio transport

This setup provides a robust foundation for local hybrid memory with both graph relationships and semantic understanding, ready for integration with AI assistants via Claude Code.