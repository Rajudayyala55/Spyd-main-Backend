# Use an official OpenJDK 17 image as a base
FROM openjdk:17-jdk-slim AS builder

# Install Maven
RUN apt-get update && apt-get install -y maven

# Set the working directory inside the container
WORKDIR /SPYD

# Copy the pom.xml from the Spyd-main-Backend/SPYD directory
COPY Spyd-main-Backend/SPYD/pom.xml .

# Download Maven dependencies (this is a separate layer to leverage caching)
RUN mvn dependency:go-offline

# Copy the entire source code from Spyd-main-Backend/SPYD into the container
COPY Spyd-main-Backend/SPYD/src ./src

# Run the Maven build to package the application into a JAR
RUN mvn clean package -DskipTests

# Debug step to verify the output JAR file exists
RUN ls /SPYD/target

# Use a slim openjdk image to run the application
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /SPYD

# Copy the packaged JAR from the builder stage into the final image
COPY --from=builder /SPYD/target/SPYD-0.0.1-SNAPSHOT.jar /SPYD/spyd-backend.jar

# Expose the port the app will run on (change if needed)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/SPYD/spyd-backend.jar"]
