# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /app

# Install system dependencies including Node.js for MCP support
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g npm@latest

# Verify Node.js and npm installation
RUN node --version && npm --version && npx --version

# Install uv package manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Copy project configuration files first (for better caching)
COPY pyproject.toml langgraph.json ./
COPY README.md CLAUDE.md* ./

# Create directory structure
RUN mkdir -p /app/notebooks \
    && mkdir -p /app/src/deep_research_from_scratch/files \
    && mkdir -p /app/data \
    && mkdir -p /app/scripts

# Copy source code and other files
COPY src/ /app/src/
COPY notebooks/ /app/notebooks/
COPY scripts/ /app/scripts/
COPY env.example /app/.env.example

# Install Python dependencies using uv
RUN uv venv .venv && \
    . .venv/bin/activate && \
    uv pip install -e . && \
    uv pip install jupyter notebook ipykernel

# Make venv globally accessible
RUN echo "source /app/.venv/bin/activate" >> /etc/bash.bashrc

# Create the startup script using COPY instead of complex RUN commands
COPY <<EOF /app/start.sh
#!/bin/bash

echo "=============================================="
echo "🧱 Deep Research From Scratch - Docker Setup"
echo "=============================================="
echo ""
echo "✅ Python version: \$(python --version)"
echo "✅ Node.js version: \$(node --version)"
echo "✅ NPX version: \$(npx --version)"
echo ""

# Check for .env file
if [ ! -f /app/.env ]; then
    if [ -f /app/.env.example ]; then
        echo "📝 Creating .env from example..."
        cp /app/.env.example /app/.env
        echo "⚠️  Please edit /app/.env with your API keys"
    else
        echo "⚠️  No .env file found. Creating template..."
        cat > /app/.env << 'ENVFILE'
# Required for research agents with external search
TAVILY_API_KEY=your_tavily_api_key_here

# Required for model usage
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Optional: For evaluation and tracing
LANGSMITH_API_KEY=your_langsmith_api_key_here
LANGSMITH_TRACING=true
LANGSMITH_PROJECT=deep_research_from_scratch
ENVFILE
        echo "📝 Please edit /app/.env with your actual API keys"
    fi
else
    echo "✅ .env file found"
fi

echo ""
echo "🚀 Starting Jupyter Notebook..."
echo "   Access it at: http://localhost:8888"
echo "   No token/password required for local development"
echo "=============================================="
echo ""

# Activate virtual environment and start Jupyter
source /app/.venv/bin/activate
exec jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root \\
    --NotebookApp.token="" --NotebookApp.password="" \\
    --notebook-dir=/app/notebooks
EOF

# Make startup script executable
RUN chmod +x /app/start.sh

# Expose Jupyter port
EXPOSE 8888

# Set the default command
CMD ["/app/start.sh"]