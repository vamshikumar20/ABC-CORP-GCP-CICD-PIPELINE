# Stage 1: Build stage
FROM ubuntu:20.04 as builder

RUN apt-get update && \
    apt-get -y install wget default-jdk && \
    wget https://github.com/zaproxy/zaproxy/releases/download/v2.16.0/ZAP_2.16.0_Linux.tar.gz && \
    mkdir /zap && \
    tar -xvf ZAP_2.16.0_Linux.tar.gz -C /zap && \
    rm ZAP_2.16.0_Linux.tar.gz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: Final stage
FROM openjdk:11-jre-slim

# Copy the built ZAP files from the builder stage
COPY --from=builder /zap /zap

# Copy your specific Java application JAR file from the Maven target directory
COPY target/java-vulnerable-code-asecurityguru-1.0-SNAPSHOT.jar /app/app.jar

# Set the working directory
WORKDIR /app

# Run the Java application
CMD ["java", "-jar", "app.jar"]

# Optional: OWASP ZAP scanning configuration
ENTRYPOINT ["/zap/ZAP_2.16.0/zap.sh", "-cmd", "-quickurl", "https://www.example.com", "-quickprogress", "-quickout", "/zap_report.html"]