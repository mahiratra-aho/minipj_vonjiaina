# Simple container that serves the Flutter project files
FROM alpine:latest

# Install basic tools
RUN apk add --no-cache curl unzip

# Create app directory
WORKDIR /app

# Copy the Flutter project files
COPY . .

# Create a simple info script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "=== VonjiAIna Frontend Container ==="' >> /start.sh && \
    echo 'echo "Flutter project files available at: /app"' >> /start.sh && \
    echo 'echo "To build locally:"' >> /start.sh && \
    echo 'echo "1. Copy the project from this container"' >> /start.sh && \
    echo 'echo "2. Run flutter pub get"' >> /start.sh && \
    echo 'echo "3. Run flutter build apk --release"' >> /start.sh && \
    echo 'echo ""' >> /start.sh && \
    echo 'echo "Project structure:"' >> /start.sh && \
    echo 'ls -la /app' >> /start.sh && \
    echo 'echo ""' >> /start.sh && \
    echo 'echo "Keeping container running..."' >> /start.sh && \
    echo 'tail -f /dev/null' >> /start.sh && \
    chmod +x /start.sh

CMD ["/start.sh"]
