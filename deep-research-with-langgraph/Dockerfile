# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Set working directory
WORKDIR /app

# Copy requirements files
COPY requirements.txt .

# Install Python dependencies using pip
RUN pip install -r requirements.txt

# Install Jupyter and additional development tools
RUN pip install jupyter notebook ipykernel

# Create a non-root user
RUN useradd -m -s /bin/bash researcher && \
    chown -R researcher:researcher /app

# Switch to researcher user
USER researcher

# Expose Jupyter port
EXPOSE 8888

# Create a startup script
RUN echo '#!/bin/bash\n\
    echo "Starting Jupyter Notebook..."\n\
    echo "You can access it at: http://localhost:8888"\n\
    echo "Default token will be displayed above"\n\
    jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token="" --NotebookApp.password=""' > /app/start.sh && \
    chmod +x /app/start.sh

# Set the default command
CMD ["/app/start.sh"]
