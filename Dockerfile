# Use a Maven base image to build the application
FROM maven:3.8.1-jdk-11 AS builder

# Set the working directory to the folder containing the pom.xml
WORKDIR /SPYD

# Copy the pom.xml and source code into the container
COPY ./SPYD/pom.xml ./SPYD/src /SPYD/

# Download dependencies (this command will now work as Maven can find pom.xml)
RUN mvn dependency:go-offline

# Build the JAR file
RUN mvn package -DskipTests

# Start a new stage to reduce the final image size
FROM openjdk:11-jre-slim

# Copy the JAR file from the builder stage
COPY --from=builder /SPYD/target/*.jar /usr/local/bin/backend.jar

# Expose the application port
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "/usr/local/bin/backend.jar"]
