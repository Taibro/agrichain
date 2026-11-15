# ---- build ----
FROM maven:3.9-eclipse-temurin-25 AS builder
WORKDIR /build
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -B dependency:go-offline -q || true
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -B clean package -DskipTests -q \
 && rm -f target/*.jar.original \
 && cp target/*.jar /build/app.jar

# ---- runtime ----
FROM eclipse-temurin:25-jre-noble
RUN useradd -r -u 1001 appuser
WORKDIR /app
COPY --from=builder /build/app.jar app.jar
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=10 \
  CMD wget -qO- http://127.0.0.1:8080/actuator/health | grep -q UP || exit 1
ENTRYPOINT ["java", \
  "-XX:MaxRAMPercentage=75", "-XX:+UseSerialGC", \
  "-jar", "/app/app.jar"]
