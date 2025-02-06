# Use an official Maven image to build the project (with OpenJDK 17)
FROM maven:3.8.6-openjdk-17-slim AS builder
 
# Set the working directory inside the container
WORKDIR /SPYD
 
# Copy the pom.xml from the Spyd-main-Backend directory
COPY Spyd-main-Backend/SPYD/pom.xml .
#install maven
RUN yum -y install maven
 
# Download Maven dependencies (this is a separate layer to leverage caching)
RUN mvn dependency:go-offline
 
# Copy the entire source code from Spyd-main-Backend into the container
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
