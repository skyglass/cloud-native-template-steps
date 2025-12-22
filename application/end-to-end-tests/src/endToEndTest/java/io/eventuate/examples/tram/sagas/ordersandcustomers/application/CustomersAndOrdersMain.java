package io.eventuate.examples.tram.sagas.ordersandcustomers.application;

import io.eventuate.examples.tram.sagas.ordersandcustomers.endtoendtests.ApplicationUnderTestUsingTestContainers;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.event.EventListener;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication(excludeName = "org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration" )
@PropertySource("classpath:CustomersAndOrdersMain.properties")
@RestController
public class CustomersAndOrdersMain {

  private static ApplicationUnderTestUsingTestContainers application = new ApplicationUnderTestUsingTestContainers();

  @GetMapping(path="/")
  public String index() {

    return String.format("""
            
            API Gateway URL: http://localhost:%s/swagger-ui/index.html

            <br/>
            
            Make a request to the API gateway
            
            <br/>

            curl -u user:password http://localhost:%s/customers

            <br/>
            
            Customer Service Swagger UI: http://localhost:%s/swagger-ui/index.html  

            <br/>
            
            Order Service Swagger UI: http://localhost:%s/swagger-ui/index.html

            <br/>
            
            Get a JWT token:

            <br/>
            
            http -a messaging-client:secret --form POST http://localhost:%s/oauth2/token  client_id=messaging-client username=user  password=password grant_type=password

            <br/>
            
            Get customers: curl -H "Authorization: Bearer <JWT>" http://localhost:%s/customers  

            <br/>
            
            Get orders: curl -H "Authorization: Bearer <JWT>" http://localhost:%s/orders  
            
            
            """,
            application.getApigatewayPort(),
            application.getApigatewayPort(),
            application.getCustomerServicePort(),
            application.getOrderServicePort(),
            application.getAuthorizationServerPort(),
            application.getCustomerServicePort(),
            application.getOrderServicePort()

      );


  }

  @Autowired
  private ServletWebServerApplicationContext webServerAppCtxt;

  @EventListener(ApplicationReadyEvent.class)
  public void applicationReady() {

    System.out.printf("""
            
            
            Visit http://localhost:%s/ for more information
            
            
            """, webServerAppCtxt.getWebServer().getPort());
  }

  public static void main(String[] args) {
    application.start();

    SpringApplication.run(CustomersAndOrdersMain.class, args);
  }

}
