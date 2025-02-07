# Use an official Maven image to build the project (with OpenJDK 17)
FROM maven:latest AS builder

# Set the working directory inside the container
WORKDIR /SPYD

# Copy the pom.xml from the Spyd-main-Backend/SPYD directory
COPY . .

# Debug step to verify the output JAR file exists
RUN ls /SPYD/target

# Download Maven dependencies (this is a separate layer to leverage caching)
RUN mvn dependency:go-offline

# Run the Maven build to package the application into a JAR
RUN mvn clean package -DskipTests

# Use a slim openjdk image to run the application
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /SPYD

# Copy the packaged JAR from the builder stage into the final image
COPY --from=builder /SPYD/target/SPYD-0.0.1-SNAPSHOT.jar /SPYD/spyd-backend.jar

# Expose the port the app will run on (change if needed)
EXPOSE 80

# Run the application
ENTRYPOINT ["java", "-jar", "/SPYD/spyd-backend.jar"]
