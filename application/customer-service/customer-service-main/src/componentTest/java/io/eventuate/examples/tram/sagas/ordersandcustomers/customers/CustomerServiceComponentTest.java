package io.eventuate.examples.tram.sagas.ordersandcustomers.customers;


import io.eventuate.common.testcontainers.DatabaseContainerFactory;
import io.eventuate.common.testcontainers.EventuateDatabaseContainer;
import io.eventuate.examples.springauthorizationserver.testcontainers.AuthorizationServerContainerForServiceContainers;
import io.eventuate.messaging.kafka.testcontainers.EventuateKafkaCluster;
import io.eventuate.messaging.kafka.testcontainers.EventuateKafkaContainer;
import io.eventuate.testcontainers.service.ServiceContainer;
import io.restassured.RestAssured;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.testcontainers.lifecycle.Startables;

import static io.restassured.RestAssured.given;
import static io.restassured.RestAssured.oauth2;

public class CustomerServiceComponentTest {

    public static EventuateKafkaCluster eventuateKafkaCluster = new EventuateKafkaCluster();

    public static EventuateKafkaContainer kafka = eventuateKafkaCluster.kafka;

    public static EventuateDatabaseContainer<?> database =
            DatabaseContainerFactory.makeVanillaPostgresContainer()
                    .withNetwork(eventuateKafkaCluster.network)
                    .withNetworkAliases("customer-service-db")
                    .withReuse(true);


    public static AuthorizationServerContainerForServiceContainers authorizationServer = new AuthorizationServerContainerForServiceContainers()
            .withNetwork(eventuateKafkaCluster.network)
            .withNetworkAliases("authorization-server")
            .withReuse(true);


    public static ServiceContainer service =
            new ServiceContainer("./Dockerfile", "../../gradle.properties")
                    .withNetwork(eventuateKafkaCluster.network)
                    .withDatabase(database)
                    .withKafka(kafka)
                    .dependsOn(kafka, database)
                    .withEnv(authorizationServer.resourceServerEnv())
                    .withLogConsumer(outputFrame -> System.out.print(outputFrame.getUtf8String()))
                    .withReuse(false) // should rebuild
            ;

    @BeforeClass
    public static void startContainers() {
        Startables.deepStart(service, authorizationServer).join();
    }

    @Before
    public void setup() {
        RestAssured.port = service.getFirstMappedPort();
        RestAssured.authentication = oauth2(authorizationServer.getJwt());
    }

    @Test
    public void shouldStart() {
        // HTTP
        // Messaging
    }


    @Test
    public void shouldGetCustomers() {
        given()
            .when()
            .get("/customers")
            .then()
            .log().ifValidationFails()
            .statusCode(200);
    }

    @Test
    public void shouldGetActuatorHealth() {
        given().
            when()
            .auth().none()
            .get("/actuator/health")
            .then()
            .statusCode(200);
    }
}
