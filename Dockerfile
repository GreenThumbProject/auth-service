FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build

# Step 1: install auth library into local Maven repo
COPY auth/pom.xml auth/pom.xml
RUN mvn dependency:go-offline -q -f auth/pom.xml
COPY auth/src auth/src
RUN mvn install -DskipTests -q -f auth/pom.xml

# Step 2: build auth-service fat JAR (auth library already in local repo)
COPY auth-service/pom.xml auth-service/pom.xml
RUN mvn dependency:go-offline -q -f auth-service/pom.xml
COPY auth-service/src auth-service/src
RUN mvn package -DskipTests -q -f auth-service/pom.xml

FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=build /build/auth-service/target/auth-service-*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
