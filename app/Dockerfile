# Base image — Python 3.11 lightweight version
FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Copy dependencies file first (for Docker cache optimization)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose port 5000 to the outside world
EXPOSE 5000

# Command to run the app
CMD ["python", "app.py"]