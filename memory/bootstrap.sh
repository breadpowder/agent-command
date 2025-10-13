#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
check_command() {
    local cmd="$1"
    local description="$2"
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "$description ($cmd) is not installed or not in PATH"
        return 1
    fi
    log_success "$description found: $(command -v "$cmd")"
}

# Function to validate environment variables
validate_env_var() {
    local var_name="$1"
    local var_value="${!var_name:-}"
    
    if [[ -z "$var_value" ]]; then
        log_error "Environment variable $var_name is not set"
        return 1
    fi
    log_success "Environment variable $var_name is set"
}

# Function to wait for Neo4j to be ready
wait_for_neo4j() {
    local uri="$1"
    local max_attempts=30
    local attempt=1
    
    log_info "Waiting for Neo4j to be ready at $uri..."
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker exec neo4j cypher-shell -u "${NEO4J_USER}" -p "${NEO4J_PASSWORD}" "RETURN 'Neo4j is ready'" >/dev/null 2>&1; then
            log_success "Neo4j is ready!"
            return 0
        fi
        
        log_info "Neo4j not ready yet (attempt $attempt/$max_attempts)..."
        sleep 2
        ((attempt++))
    done
    
    log_error "Neo4j failed to become ready within timeout"
    return 1
}

# Main execution starts here
log_info "Starting Graphiti Hybrid Memory Bootstrap..."

# --- Phase 1: Environment validation ---
log_info "Phase 1: Validating prerequisites..."

# Required environment variables
: "${OPENAI_API_KEY:?❌ OPENAI_API_KEY must be set. Export it with: export OPENAI_API_KEY=sk-...}"

# Optional environment variables with defaults
NEO4J_USER="${NEO4J_USER:-neo4j}"
NEO4J_PASSWORD="${NEO4J_PASSWORD:-graphiti}"
NEO4J_URI="${NEO4J_URI:-bolt://localhost:7687}"
MODEL_NAME="${MODEL_NAME:-gpt-4o-mini}"

# Validate required commands
check_command "docker" "Docker" || exit 1
check_command "docker" "Docker" && {
    if ! docker compose version >/dev/null 2>&1; then
        log_error "Docker Compose is not available (try 'docker compose version')"
        exit 1
    fi
    log_success "Docker Compose found: $(docker compose version --short 2>/dev/null || echo 'unknown version')"
}

check_command "claude" "Claude Code CLI" || {
    log_error "Claude Code CLI not found. Install it with:"
    log_error "  npm install -g @anthropic-ai/claude-code"
    log_error "  or download from: https://claude.ai/download"
    exit 1
}

check_command "git" "Git" || exit 1

validate_env_var "OPENAI_API_KEY" || exit 1

log_success "All prerequisites validated!"

# --- Phase 2: Neo4j startup ---
log_info "Phase 2: Starting Neo4j database..."

# Check if Neo4j is already running
if docker ps --format "table {{.Names}}" | grep -q "^neo4j$"; then
    log_warning "Neo4j container is already running. Stopping it first..."
    docker stop neo4j >/dev/null 2>&1 || true
    docker rm neo4j >/dev/null 2>&1 || true
fi

# Start Neo4j with Docker Compose
log_info "Starting Neo4j container..."
docker compose up -d

# Wait for Neo4j to be ready
wait_for_neo4j "$NEO4J_URI" || {
    log_error "Failed to start Neo4j. Check logs with: docker logs neo4j"
    exit 1
}

log_success "Neo4j is running and accessible!"
log_info "Neo4j Browser: http://localhost:7474 (login: ${NEO4J_USER}/${NEO4J_PASSWORD})"

# --- Phase 3: Graphiti setup ---
log_info "Phase 3: Setting up Graphiti MCP server..."

# Clone Graphiti if not present
if [[ ! -d "graphiti" ]]; then
    log_info "Cloning Graphiti repository..."
    git clone https://github.com/getzep/graphiti.git
    log_success "Graphiti repository cloned!"
else
    log_info "Graphiti repository already exists, using existing copy"
fi

# Navigate to MCP server directory
cd graphiti/mcp_server

# Set up dependencies
if command -v uv >/dev/null 2>&1; then
    log_info "Installing dependencies with uv..."
    uv sync
    SERVER_CMD=(uv run graphiti_mcp_server.py --transport stdio)
    log_success "Dependencies installed with uv!"
else
    log_info "uv not found, falling back to pip with virtual environment..."
    
    # Create and activate virtual environment
    python -m venv .venv
    source .venv/bin/activate
    
    # Upgrade pip and install requirements
    pip install -U pip
    pip install -r requirements.txt
    
    SERVER_CMD=(python graphiti_mcp_server.py --transport stdio)
    log_success "Dependencies installed with pip!"
fi

# Return to original directory
cd - >/dev/null

# --- Phase 4: Claude Code MCP registration ---
log_info "Phase 4: Registering Graphiti MCP server with Claude Code..."

# Remove existing registration if present
if claude mcp list 2>/dev/null | grep -q "graphiti"; then
    log_info "Removing existing Graphiti MCP registration..."
    claude mcp remove graphiti 2>/dev/null || true
fi

# Build the full server command path
GRAPHITI_DIR="$(pwd)/graphiti/mcp_server"
if command -v uv >/dev/null 2>&1; then
    # For uv, we need to run from the correct directory
    FULL_SERVER_CMD=(bash -c "cd '$GRAPHITI_DIR' && uv run graphiti_mcp_server.py --transport stdio")
else
    # For pip, we need to activate the venv first
    FULL_SERVER_CMD=(bash -c "cd '$GRAPHITI_DIR' && source .venv/bin/activate && python graphiti_mcp_server.py --transport stdio")
fi

# Register MCP server with Claude Code
log_info "Registering MCP server with stdio transport..."
claude mcp add --scope user --transport stdio graphiti \
    --env OPENAI_API_KEY="$OPENAI_API_KEY" \
    --env MODEL_NAME="$MODEL_NAME" \
    --env NEO4J_URI="$NEO4J_URI" \
    --env NEO4J_USER="$NEO4J_USER" \
    --env NEO4J_PASSWORD="$NEO4J_PASSWORD" \
    -- "${FULL_SERVER_CMD[@]}"

log_success "Graphiti MCP server registered with Claude Code!"

# --- Final verification ---
log_info "Performing final verification..."

# Check MCP registration
if claude mcp list 2>/dev/null | grep -q "graphiti"; then
    log_success "MCP registration verified - 'graphiti' found in claude mcp list"
else
    log_error "MCP registration verification failed"
    exit 1
fi

# Summary
echo
log_success "🎉 Graphiti Hybrid Memory setup completed successfully!"
echo
log_info "Next steps:"
log_info "  1. Neo4j Browser: http://localhost:7474 (login: ${NEO4J_USER}/${NEO4J_PASSWORD})"
log_info "  2. In Claude Code, run: /mcp"
log_info "  3. Try Graphiti tools like:"
log_info "     - 'add a memory that Henry owns Lakeside Tower'"
log_info "     - 'search for facts about Henry'"
log_info "     - 'what properties does Henry own?'"
echo
log_info "To verify MCP status: claude mcp list"
log_info "To stop Neo4j: docker compose down"