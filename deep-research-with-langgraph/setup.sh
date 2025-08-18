#!/bin/bash

# Deep Research with LangGraph - Setup Script

echo "🚀 Setting up Deep Research with LangGraph Docker environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p notebooks
mkdir -p data

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file template..."
    cat > .env << EOF
# Required for research agents with external search
TAVILY_API_KEY=your_tavily_api_key_here

# Required for model usage
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Optional: For evaluation and tracing
LANGSMITH_API_KEY=your_langsmith_api_key_here
LANGSMITH_TRACING=true
LANGSMITH_PROJECT=deep_research_from_scratch
EOF
    echo "⚠️  Please edit the .env file with your actual API keys before starting the container."
else
    echo "✅ .env file already exists."
fi

# Clone the course repository if not already present
if [ ! -d "notebooks" ] || [ -z "$(ls -A notebooks 2>/dev/null)" ]; then
    echo "📚 Cloning course repository..."
    git clone https://github.com/Gall-oDrone/deep_research_from_scratch temp_repo
    if [ -d "temp_repo/notebooks" ]; then
        cp -r temp_repo/notebooks/* notebooks/
        echo "✅ Course notebooks copied to notebooks/ directory."
    else
        echo "⚠️  Could not find notebooks in the repository. You may need to download them manually."
    fi
    rm -rf temp_repo
else
    echo "✅ Course notebooks already present."
fi

# Set proper permissions
echo "🔐 Setting permissions..."
chmod -R 755 notebooks/
chmod -R 755 data/

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit the .env file with your API keys"
echo "2. Run: docker-compose build"
echo "3. Run: docker-compose up -d"
echo "4. Open http://localhost:8888 in your browser"
echo ""
echo "For more information, see README.md"
