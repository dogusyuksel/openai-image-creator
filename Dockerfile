# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /workspace

USER root

# Install Python dependencies
RUN pip install openai==0.28.0
RUN pip install Requests==2.32.3

CMD ["/bin/bash"]
