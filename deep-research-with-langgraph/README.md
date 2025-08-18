# Deep Research with LangGraph - Docker Setup

This Docker setup allows you to follow the [Deep Research from Scratch](https://github.com/Gall-oDrone/deep_research_from_scratch) course (forked from the original LangChain course) without installing any dependencies on your local system.

## Prerequisites

- Docker installed on your system
- Docker Compose installed on your system

## Quick Start

1. **Clone the course repository:**
   ```bash
   git clone https://github.com/Gall-oDrone/deep_research_from_scratch
   cd deep_research_from_scratch
   ```

2. **Create environment file:**
   ```bash
   # Create .env file with your API keys
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
   ```

3. **Build and run the Docker container:**
   ```bash
   # Build the image
   docker-compose build
   
   # Start the container
   docker-compose up -d
   ```

4. **Access Jupyter Notebook:**
   - Open your browser and go to: `http://localhost:8888`
   - The notebook will be accessible without authentication

## Course Structure

The course consists of 5 tutorial notebooks:

1. **User Clarification and Brief Generation** (`notebooks/1_scoping.ipynb`)
   - Clarify research scope and transform user input into structured research briefs
   - Learn: State management, structured output patterns, conditional routing

2. **Research Agent with Custom Tools** (`notebooks/2_research_agent.ipynb`)
   - Build an iterative research agent using external search tools
   - Learn: Agent patterns, tool integration, search optimization

3. **Research Agent with MCP** (`notebooks/3_research_agent_mcp.ipynb`)
   - Integrate Model Context Protocol (MCP) servers as research tools
   - Learn: MCP integration, client-server architecture

4. **Research Supervisor** (`notebooks/4_research_supervisor.ipynb`)
   - Multi-agent coordination for complex research tasks
   - Learn: Multi-agent patterns, parallel processing, research coordination

5. **Full Multi-Agent Research System** (`notebooks/5_full_agent.ipynb`)
   - Complete end-to-end research system integrating all components
   - Learn: System architecture, subgraph composition, end-to-end workflows

## Container Management

### Start the container:
```bash
docker-compose up -d
```

### Stop the container:
```bash
docker-compose down
```

### View logs:
```bash
docker-compose logs -f
```

### Access container shell:
```bash
docker-compose exec deep-research bash
```

### Rebuild after changes:
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Directory Structure

```
deep-research-with-langgraph/
├── Dockerfile              # Docker configuration
├── docker-compose.yml      # Docker Compose configuration
├── requirements.txt        # Python dependencies
├── pyproject.toml         # Project configuration
├── .dockerignore          # Docker ignore file
├── README.md              # This file
├── .env                   # Environment variables (create this)
├── notebooks/             # Course notebooks (mounted from course repo)
└── data/                  # Data directory (mounted)
```

## Environment Variables

Create a `.env` file in the project root with the following variables:

- `TAVILY_API_KEY`: Required for external search functionality
- `OPENAI_API_KEY`: Required for OpenAI model usage
- `ANTHROPIC_API_KEY`: Required for Anthropic model usage
- `LANGSMITH_API_KEY`: Optional, for tracing and evaluation
- `LANGSMITH_TRACING`: Optional, enable/disable tracing
- `LANGSMITH_PROJECT`: Optional, project name for LangSmith

## Troubleshooting

### Port already in use:
If port 8888 is already in use, modify the `docker-compose.yml` file:
```yaml
ports:
  - "8889:8888"  # Change 8888 to 8889 or another available port
```

### Permission issues:
If you encounter permission issues, ensure the mounted directories have proper permissions:
```bash
chmod -R 755 notebooks/
chmod -R 755 data/
```

### Container won't start:
Check the logs for errors:
```bash
docker-compose logs
```

### Dependencies not found:
If you need to add additional dependencies, modify the `requirements.txt` file and rebuild:
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Learning Resources

- [Course Repository](https://github.com/Gall-oDrone/deep_research_from_scratch)
- [LangChain Documentation](https://python.langchain.com/)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)

## Contributing

This Docker setup is designed to make the course accessible. If you encounter issues or have improvements, please:

1. Check the troubleshooting section
2. Review the course documentation
3. Ensure your environment variables are correctly set

## License

This Docker setup follows the same license as the original course repository.
