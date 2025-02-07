# Use the latest Maven image (which comes with OpenJDK as well)
FROM maven:latest AS builder

# Set the working directory inside the container
WORKDIR /SPYD

# Copy the pom.xml and the source code into the container (adjusting path based on your file structure)
COPY SPYD/pom.xml .
COPY SPYD/src ./src

# Run Maven to download dependencies and build the project (this will create the target directory)
RUN mvn clean package -DskipTests

# Debug: List the contents of the /SPYD/target directory to verify the JAR file exists
RUN ls /SPYD/target

# Stage 2: Create the final image from a clean base image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /SPYD

# Copy the JAR file from the builder stage into the final image
COPY --from=builder /SPYD/target/SPYD-0.0.1-SNAPSHOT.jar /SPYD/spyd-backend.jar

# Expose port 808 for the application
EXPOSE 80

# Command to run the application
ENTRYPOINT ["java", "-jar", "/SPYD/spyd-backend.jar"]
