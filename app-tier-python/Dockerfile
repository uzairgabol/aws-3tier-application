# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Set build-time arguments (default values can be set here)
ARG DB_HOST
ARG DB_USER
ARG DB_PWD
ARG DB_DATABASE

# Set environment variables (these will be available at runtime in the container)
ENV DB_HOST=${DB_HOST}
ENV DB_USER=${DB_USER}
ENV DB_PWD=${DB_PWD}
ENV DB_DATABASE=${DB_DATABASE}

# Copy the current directory contents into the container at /app
COPY . /app

# Install any dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 4000 available to the world outside this container
EXPOSE 4000

# Run app.py when the container launches
CMD ["python", "app.py"]
