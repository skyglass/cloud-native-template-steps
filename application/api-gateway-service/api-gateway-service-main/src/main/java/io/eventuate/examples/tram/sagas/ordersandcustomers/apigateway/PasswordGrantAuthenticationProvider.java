package io.eventuate.examples.tram.sagas.ordersandcustomers.apigateway;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.ReactiveAuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Collections;
import java.util.Map;

public class PasswordGrantAuthenticationProvider implements ReactiveAuthenticationManager {

  private final WebClient webClient;

  public PasswordGrantAuthenticationProvider(WebClient webClient) {
    this.webClient = webClient;
  }

  @Value("${api.gateway.token.endpoint}")
  private String tokenEndpoint;

  @Override
  public Mono<Authentication> authenticate(Authentication authentication) {
    String username = authentication.getName();
    String password = (String) authentication.getCredentials();

    MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
    formData.add("grant_type", "password");
    formData.add("username", username);
    formData.add("password", password);

    // Send the POST request
    Mono<ResponseEntity<Map<String, String>>> response = webClient.post()
            .uri(tokenEndpoint)
            .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_FORM_URLENCODED_VALUE)
            .headers(headers -> headers.setBasicAuth("messaging-client", "secret"))
            .body(BodyInserters.fromFormData(formData))
            .retrieve()
            .toEntity(new ParameterizedTypeReference<>() {
            });

    // Print the response
    response.subscribe(System.out::println);

    return response.map(r ->
    {
      User userDetails = new User(username, password, true, true,
              true, true, Collections.emptyList());
      return new UsernamePasswordAuthenticationToken(new EnhancedUserDetails(userDetails, r.getBody().get("access_token")), password, Collections.emptyList());
    });
  }
}
