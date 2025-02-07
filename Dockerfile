# Use a base image with OpenJDK (no need to install Maven)
FROM openjdk:11-jre-slim AS builder

# Set the working directory to the folder containing the pom.xml
WORKDIR /SPYD

# Copy the Maven wrapper and necessary files from the project
COPY ./SPYD/mvnw ./SPYD/mvnw
COPY ./SPYD/mvnw.cmd ./SPYD/mvnw.cmd
COPY ./SPYD/pom.xml ./SPYD/pom.xml
COPY ./SPYD/src ./SPYD/src

# Make sure the Maven wrapper is executable
RUN chmod +x mvnw

# Download dependencies and package the application
RUN ./mvnw clean install -DskipTests

# Start a new stage to reduce the final image size
FROM openjdk:11-jre-slim

# Copy the JAR file from the build stage
COPY --from=builder /SPYD/target/*.jar /usr/local/bin/backend.jar

# Expose port 80
EXPOSE 80

# Run the application on port 80
CMD ["java", "-jar", "-Dserver.port=80", "/usr/local/bin/backend.jar"]
