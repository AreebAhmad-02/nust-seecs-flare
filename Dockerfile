# Use the specified base image from the challenge
FROM pytorch/pytorch:2.2.1-cuda12.1-cudnn8-devel


# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /workspace
# ENV PYTHONPATH="/workspace:/workspace/LaMed/src:$PYTHONPATH"

RUN python --version

RUN python -c "import torch; print(torch.__version__)"

# # Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl 
#     unzip \
#     build-essential \
#     && rm -rf /var/lib/apt/lists/*


# Copy the entire project
COPY . /workspace/

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip
RUN python --version
RUN pip install --no-cache-dir -r requirements.txt --verbose
# Install huggingface_hub (and optionally git-lfs if you decide to use git)
RUN pip install --no-cache-dir huggingface_hub


# Create necessary directories
RUN mkdir -p /workspace/outputs
RUN mkdir -p /workspace/inputs
RUN mkdir -p /workspace/inputs/test_preprocessed

# Make download script executable
# Make predict.sh executable
RUN chmod +x /workspace/predict.sh

# Set default command
CMD ["bash", "predict.sh"]