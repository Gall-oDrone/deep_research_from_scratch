#!/bin/bash

# Deep Research with LangGraph - Setup Script

set -e  # Exit on error

echo "🚀 Setting up Deep Research with LangGraph Docker environment..."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed (try both docker-compose and docker compose)
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    echo "❌ Docker Compose is not installed. Please install Docker Compose."
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose detected"
echo ""

# Create necessary directories
echo "📁 Creating project directories..."
mkdir -p notebooks
mkdir -p data
mkdir -p src/deep_research_from_scratch/files

# Check if this is the actual repo or needs setup
if [ ! -f "pyproject.toml" ]; then
    echo "⚠️  Project files not found. This script should be run from the project root."
    echo "   Please clone the repository first:"
    echo "   git clone https://github.com/langchain-ai/deep_research_from_scratch"
    exit 1
fi

# Check if notebooks exist
if [ ! -d "notebooks" ] || [ -z "$(ls -A notebooks 2>/dev/null)" ]; then
    echo "⚠️  Notebooks directory is empty."
    echo "   The notebooks should be part of the repository."
    echo "   If they're missing, check the repository or download them manually."
fi

# Check if .env file exists
if [ ! -f .env ]; then
    if [ -f env.example ]; then
        echo "📝 Creating .env file from env.example..."
        cp env.example .env
    else
        echo "📝 Creating .env file with template..."
        cat > .env << 'EOF'
# Deep Research with LangGraph - Environment Variables
# Copy this file to .env and fill in your actual API keys

# Required for research agents with external search
# Get your API key from: https://tavily.com
TAVILY_API_KEY=your_tavily_api_key_here

# Required for model usage
# Get your API key from: https://platform.openai.com
OPENAI_API_KEY=your_openai_api_key_here

# Get your API key from: https://console.anthropic.com
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Optional: For evaluation and tracing
# Get your API key from: https://smith.langchain.com
LANGSMITH_API_KEY=your_langsmith_api_key_here
LANGSMITH_TRACING=false
LANGSMITH_PROJECT=deep_research_from_scratch
EOF
    fi
    echo ""
    echo "⚠️  IMPORTANT: Edit the .env file with your actual API keys before starting!"
    echo "   Required keys:"
    echo "   - TAVILY_API_KEY (from https://tavily.com)"
    echo "   - OPENAI_API_KEY (from https://platform.openai.com)"
    echo "   - ANTHROPIC_API_KEY (from https://console.anthropic.com)"
    echo ""
else
    echo "✅ .env file already exists"
fi

# Set proper permissions
echo "🔐 Setting file permissions..."
chmod -R 755 notebooks/ 2>/dev/null || true
chmod -R 755 data/ 2>/dev/null || true
chmod 600 .env  # Secure the .env file

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Edit the .env file with your API keys (if not already done):"
echo "   nano .env  # or use your preferred editor"
echo ""
echo "2. Build the Docker image:"
echo "   $DOCKER_COMPOSE build"
echo ""
echo "3. Start the container:"
echo "   $DOCKER_COMPOSE up"
echo ""
echo "4. Open Jupyter Notebook in your browser:"
echo "   http://localhost:8888"
echo ""
echo "📚 The notebooks will be in the /app/notebooks/ directory"
echo ""
echo "🛑 To stop the container:"
echo "   $DOCKER_COMPOSE down"
echo ""
echo "For more information, see README.md"