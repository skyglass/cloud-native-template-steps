package io.eventuate.examples.tram.sagas.ordersandcustomers.apigateway;

import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class JwtDownstreamPropagatingFilter implements GlobalFilter{
  @Override
  public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {

     return ReactiveSecurityContextHolder.getContext()
            .flatMap(ctx -> {
              Object principal = ctx.getAuthentication().getPrincipal();
              EnhancedUserDetails enhancedUserDetails = (EnhancedUserDetails) principal;
              exchange.getRequest().mutate().header("Authorization", "Bearer " + enhancedUserDetails.getAccessToken()).build();
              return chain.filter(exchange);
            });

  }
}
