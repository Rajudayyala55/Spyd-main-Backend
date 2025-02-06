# Use an official Maven image to build the project (with OpenJDK 17)
FROM maven:3.8-openjdk-17 AS builder
 
# Set the working directory inside the container
WORKDIR /SPYD
 
# Copy the pom.xml from the Spyd-main-Backend directory
COPY /Spyd-main-Backend/SPYD

#install maven
RUN yum -y install maven
 
# Download Maven dependencies (this is a separate layer to leverage caching)
RUN mvn dependency:go-offline
 
# Copy the entire source code from Spyd-main-Backend into the container
COPY . .
 
# Run the Maven build to package the application into a JAR
RUN mvn clean install -DskipTests
 
# Debug step to verify the output JAR file exists
RUN ls /SPYD/target
 
# Use a slim openjdk image to run the application
FROM openjdk:17-jdk-slim
 
# Set the working directory inside the container
WORKDIR /SPYD/target/
RUN java -jar SPYD-0.0.1-SNAPSHOT.jar

 
# Expose the port the app will run on (change if needed)
EXPOSE 80
 
# Run the application
ENTRYPOINT ["java", "-jar", "/SPYD/spyd-backend.jar"]
