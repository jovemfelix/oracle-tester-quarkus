# =========================================================================
# ESTÁGIO 1: Build (Compilación) con Red Hat UBI 8 OpenJDK 21
#
# Este estágio usa a imagem Universal Base Image (UBI) da Red Hat com o JDK completo
# e instala o Maven para compilar el proyecto Quarkus.
# =========================================================================
FROM registry.access.redhat.com/ubi9/openjdk-21:1.21 AS builder

# Cambia al usuario root temporalmente para instalar paquetes
USER 0

# Instala Maven usando el gestor de paquetes 'microdnf'
RUN microdnf install maven -y && \
    microdnf clean all

# Retorna al usuario por defecto no privilegiado de la imagen (buena práctica)
USER 185

# Define el directorio de trabajo
WORKDIR /home/jboss/app

# Copia el pom.xml primero para aprovechar el cache de dependencias de Docker
COPY --chown=185 pom.xml .

# Descarga todas las dependencias del proyecto
RUN mvn dependency:go-offline -B

# Copia el resto del código fuente
COPY --chown=185 src ./src

# Construye el proyecto Quarkus. Esto genera un JAR ejecutable y sus dependencias.
RUN mvn package -DskipTests

# =========================================================================
# ESTÁGIO 2: Run (Ejecución) con Red Hat UBI 8 OpenJDK 21 Runtime
#
# Este estágio usa la imagen UBI de runtime, que es significativamente más pequeña
# al no incluir herramientas de build. Contiene solo el JRE necesario.
# =========================================================================
FROM registry.access.redhat.com/ubi9/openjdk-21-runtime

# Define el directorio de trabajo
WORKDIR /deployments

# Copia los artefactos de la aplicación construidos en el estágio anterior
# Quarkus empaqueta todo lo necesario en la carpeta 'quarkus-app'
COPY --from=builder /home/jboss/app/target/quarkus-app/ .

# Expone el puerto por defecto de Quarkus
EXPOSE 8080

USER 185

# Variables de entorno para la conexión a la base de datos.
# Estos valores deben ser proporcionados al ejecutar el contenedor.
ENV DB_USER=""
ENV DB_PASS=""
ENV DB_HOST=""
ENV DB_PORT=""
ENV DB_SID=""

# # El comando para iniciar la aplicación Quarkus
# CMD ["java", "-jar", "quarkus-run.jar"]

EXPOSE 8080
USER 185
ENV JAVA_OPTS_APPEND="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV JAVA_APP_JAR="/deployments/quarkus-run.jar"

ENTRYPOINT [ "/opt/jboss/container/java/run/run-java.sh" ]