package io.eventuate.examples.tram.sagas.ordersandcustomers.customers.web;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.web.SecurityFilterChain;

import java.util.List;
import java.util.stream.Collectors;

@Configuration
@EnableWebSecurity
public class SecurityConfig  {

  private final String serviceRole = "USER";

  public SecurityConfig() {
  }

  @Bean
  public JwtAuthenticationConverter jwtAuthenticationConverter() {
    JwtAuthenticationConverter jwtConverter = new JwtAuthenticationConverter();
    jwtConverter.setJwtGrantedAuthoritiesConverter(jwt -> {
      List<String> roles = jwt.getClaim("authorities");
      return roles != null ? roles.stream()
              .map(SimpleGrantedAuthority::new)
              .collect(Collectors.toList())
              : null;
    });
    return jwtConverter;
  }


  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http.authorizeHttpRequests(authz -> {
      authz.requestMatchers("/actuator/**").permitAll()
              .requestMatchers("/swagger**", "/swagger-ui/**", "/v3/api-docs/**").permitAll()
              .requestMatchers("/**").hasRole(serviceRole);

    }).oauth2ResourceServer(configurer -> {
      configurer.jwt(jwtConfigurer -> jwtConfigurer.jwtAuthenticationConverter(jwtAuthenticationConverter()));
    }).build();
  }
}


