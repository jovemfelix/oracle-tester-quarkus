package org.acme;

import io.agroal.api.AgroalDataSource;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.sql.Connection;
import java.sql.SQLException;

@Path("/test-connection")
public class ConnectionTestingResource {

    @Inject
    AgroalDataSource dataSource;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public Response testDatabaseConnection() {
        // Usa try-with-resources para garantizar que la conexión se cierre automáticamente.
        try (Connection connection = dataSource.getConnection()) {
            
            // Valida que la conexión esté activa (timeout de 1 segundo)
            if (connection.isValid(1)) {
                String successMessage = "✅ CONEXIÓN EXITOSA!\n\n" +
                                        "La aplicación se ha conectado correctamente a la base de datos Oracle.";
                return Response.ok(successMessage).build();
            } else {
                String failureMessage = "❌ CONEXIÓN FALLIDA!\n\n" +
                                        "La conexión se estableció pero no es válida.";
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(failureMessage).build();
            }

        } catch (SQLException e) {
            // Captura cualquier excepción SQL durante el intento de conexión.
            String errorMessage = "❌ ERROR DE CONEXIÓN!\n\n" +
                                  "No se pudo establecer la conexión con la base de datos Oracle.\n\n" +
                                  "--- DETALLES DEL ERROR ---\n" +
                                  "Mensaje: " + e.getMessage() + "\n" +
                                  "SQLState: " + e.getSQLState() + "\n" +
                                  "ErrorCode: " + e.getErrorCode();
            
            e.printStackTrace(); // Imprime el stack trace completo en el log del servidor.
            
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(errorMessage).build();
        }
    }
}