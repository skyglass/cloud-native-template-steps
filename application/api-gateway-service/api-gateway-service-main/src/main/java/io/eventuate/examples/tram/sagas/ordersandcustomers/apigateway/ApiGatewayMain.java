package io.eventuate.examples.tram.sagas.ordersandcustomers.apigateway;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.tools.agent.ReactorDebugAgent;

@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
@EnableWebFluxSecurity
public class ApiGatewayMain {

  @Bean
  public SecurityWebFilterChain filterChain(ServerHttpSecurity http) throws Exception {
    return http.authorizeExchange(authz -> {
      authz.pathMatchers("/actuator/**").permitAll()
              .pathMatchers("/swagger**", "/swagger-ui/**", "/v3/api-docs/**").permitAll()
              .pathMatchers("/**").authenticated();
    }).httpBasic(Customizer.withDefaults())
            .csrf(ServerHttpSecurity.CsrfSpec::disable)
    .build();
  }

  @Bean
  public PasswordGrantAuthenticationProvider myUserDetailsAuthenticationProvider(WebClient webClient) {
    return new PasswordGrantAuthenticationProvider(webClient);
  }

  public static void main(String[] args) {
    ReactorDebugAgent.init();
    SpringApplication.run(ApiGatewayMain.class, args);
  }
}

