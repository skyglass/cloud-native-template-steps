package io.eventuate.examples.tram.sagas.ordersandcustomers.customers.web;

import io.eventuate.common.testcontainers.PropertyProvidingContainer;
import io.eventuate.examples.springauthorizationserver.testcontainers.AuthorizationServerContainerForLocalTests;
import io.eventuate.examples.tram.sagas.ordersandcustomers.customers.domain.CustomerService;
import io.restassured.RestAssured;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import static io.restassured.RestAssured.given;
import static io.restassured.RestAssured.oauth2;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ContextConfiguration(classes=CustomerWebIntegrationTest.Config.class)
@RunWith(SpringJUnit4ClassRunner.class)
public class CustomerWebIntegrationTest {

  @LocalServerPort
  private int port;

  public static AuthorizationServerContainerForLocalTests authorizationServer = new AuthorizationServerContainerForLocalTests()
          .withReuse(true);


  @DynamicPropertySource
  static void startAndProvideProperties(DynamicPropertyRegistry registry) {
    PropertyProvidingContainer.startAndProvideProperties(registry, authorizationServer);
  }

  @Configuration
  @EnableAutoConfiguration(exclude = {DataSourceAutoConfiguration.class})
  @Import({CustomerWebConfiguration.class})
  public static class Config {
  }

  @MockBean
  private CustomerService customerService;

  @Before
  public void setup() {
    RestAssured.port = port;
    RestAssured.authentication = oauth2(authorizationServer.getJwt());
  }

  @Test
  public void shouldGetCustomers() {
    given().when()
            .log().all()
            .get("/customers")
            .then()
            .statusCode(200);

  }

}
