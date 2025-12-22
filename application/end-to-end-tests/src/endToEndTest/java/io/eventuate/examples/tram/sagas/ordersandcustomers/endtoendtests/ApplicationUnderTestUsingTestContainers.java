package io.eventuate.examples.tram.sagas.ordersandcustomers.endtoendtests;

import com.github.dockerjava.api.command.CreateContainerCmd;
import io.eventuate.cdc.testcontainers.EventuateCdcContainer;
import io.eventuate.common.testcontainers.DatabaseContainerFactory;
import io.eventuate.common.testcontainers.EventuateDatabaseContainer;
import io.eventuate.common.testcontainers.EventuateGenericContainer;
import io.eventuate.common.testcontainers.EventuateZookeeperContainer;
import io.eventuate.examples.springauthorizationserver.testcontainers.AuthorizationServerContainerForServiceContainers;
import io.eventuate.messaging.kafka.testcontainers.EventuateKafkaCluster;
import io.eventuate.messaging.kafka.testcontainers.EventuateKafkaContainer;
import io.eventuate.testcontainers.service.ServiceContainer;
import org.jetbrains.annotations.NotNull;
import org.testcontainers.containers.output.Slf4jLogConsumer;
import org.testcontainers.lifecycle.Startables;

import java.time.Duration;
import java.util.UUID;
import java.util.function.Consumer;


public class ApplicationUnderTestUsingTestContainers extends ApplicationUnderTest {
  private final EventuateZookeeperContainer zookeeper;
  private final EventuateKafkaContainer kafka;
  private final EventuateDatabaseContainer<?> customerServiceDatabase;
  private final EventuateDatabaseContainer<?> orderServiceDatabase; // This results in only one DB!
  private final ServiceContainer customerService
          // should rebuild
          ;
  private final ServiceContainer orderService
          // should rebuild
          ;
  private final ServiceContainer apiGatewayService;
  private final EventuateCdcContainer cdc
          // State for deleted databases is persisted in Kafka
          ;
  private final AuthorizationServerContainerForServiceContainers authorizationServer;

  public ApplicationUnderTestUsingTestContainers() {
    EventuateKafkaCluster eventuateKafkaCluster = new EventuateKafkaCluster("CustomersAndOrdersE2ETest");

    zookeeper = eventuateKafkaCluster.zookeeper;
    kafka = eventuateKafkaCluster.kafka;


    authorizationServer = new AuthorizationServerContainerForServiceContainers()
            .withNetwork(eventuateKafkaCluster.network)
            .withNetworkAliases("authorization-server")
            .withReuse(true);

    customerServiceDatabase = DatabaseContainerFactory.makeVanillaPostgresContainer()
            .withNetwork(eventuateKafkaCluster.network)
            .withNetworkAliases("customer-service-db")
            .withReuse(false);

    orderServiceDatabase = DatabaseContainerFactory.makeVanillaPostgresContainer()
            .withNetwork(eventuateKafkaCluster.network)
            .withNetworkAliases("order-service-db")
            .withReuse(false);

    customerService = new ServiceContainer("../customer-service/customer-service-main/Dockerfile", "../gradle.properties")
            .withNetwork(eventuateKafkaCluster.network)
            .withNetworkAliases("customer-service")
            .withDatabase(customerServiceDatabase)
            .withKafka(kafka)
            .dependsOn(customerServiceDatabase, kafka)
            .withReuse(false)
            .withStartupTimeout(Duration.ofSeconds(600))
            .withEnv(authorizationServer.resourceServerEnv())
            .withLogConsumer(new Slf4jLogConsumer(logger).withPrefix("SVC customer-service:"))
            .withCreateContainerCmdModifier(addUniqueSuffix("customer-service"))
    ;

    orderService = new ServiceContainer("../order-service/order-service-main/Dockerfile", "../gradle.properties")
            .withNetwork(eventuateKafkaCluster.network)
            .withNetworkAliases("order-service")
            .withDatabase(orderServiceDatabase)
            .withKafka(kafka)
            .dependsOn(orderServiceDatabase, kafka)
            .withReuse(false)
            .withStartupTimeout(Duration.ofSeconds(600))
            .withEnv(authorizationServer.resourceServerEnv())
            .withCreateContainerCmdModifier(addUniqueSuffix("order-service"))
    ;

    apiGatewayService = new ServiceContainer("../api-gateway-service/api-gateway-service-main/Dockerfile", "../gradle.properties")
            .withNetwork(eventuateKafkaCluster.network)
            .withReuse(false) // should rebuild
            .withExposedPorts(8080)
            .withEnv("ORDER_DESTINATIONS_ORDERSERVICEURL", "http://order-service:8080")
            .withEnv("CUSTOMER_DESTINATIONS_CUSTOMERSERVICEURL", "http://customer-service:8080")
//            .withEnv("SPRING_SLEUTH_ENABLED", "true")
//            .withEnv("SPRING_SLEUTH_SAMPLER_PROBABILITY", "1")
//            .withEnv("SPRING_ZIPKIN_BASE_URL", "http://zipkin:9411/")
            .withEnv("JAVA_OPTS", "-Ddebug")
            .withEnv("APIGATEWAY_TIMEOUT_MILLIS", "1000")
//            .withEnv(authorizationServer.resourceServerEnv())
            .withEnv(authorizationServer.clientEnv())
            .withLogConsumer(new Slf4jLogConsumer(logger).withPrefix("SVC api-gateway-service:"))
            .withCreateContainerCmdModifier(addUniqueSuffix("api-gateway-service"))

    ;

    cdc = new EventuateCdcContainer()
            .withKafkaCluster(eventuateKafkaCluster)
            .withTramPipeline(customerServiceDatabase)
            .withTramPipeline(orderServiceDatabase)
            .dependsOn(customerService, orderService)
            .withReuse(false);



  }

  private static @NotNull Consumer<CreateContainerCmd> addUniqueSuffix(String containerName) {
    return cmd -> cmd.withName(containerName + "-" + UUID.randomUUID());
  }

  @Override
  public void start() {
    Startables.deepStart(cdc, apiGatewayService, authorizationServer).join();
  }

  private void startContainer(EventuateGenericContainer<?> container) {
    String name = container.getFirstNetworkAlias();

    Slf4jLogConsumer logConsumer2 = new Slf4jLogConsumer(logger).withPrefix("SVC " + name + ":");
    System.out.println("============ Starting " + container.getClass().getSimpleName() + "," + container);
    container.start();
    System.out.println("============ Started " + container.getClass().getSimpleName() + "," + container);
    container.followOutput(logConsumer2);

  }

  @Override
  public int getCustomerServicePort() {
      return customerService.getFirstMappedPort();
  }

  @Override
  public int getApigatewayPort() {
      return apiGatewayService.getFirstMappedPort();
  }

  @Override
  public int getOrderServicePort() {
      return orderService.getFirstMappedPort();
  }

  public int getAuthorizationServerPort() {
    return authorizationServer.getFirstMappedPort();
  }

  @Override
  boolean exposesSwaggerUiForBackendServices() {
    return true;
  }

  @Override
  public String getJwt() {
    return authorizationServer.getJwt();
  }



}
