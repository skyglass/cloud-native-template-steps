package io.eventuate.examples.tram.sagas.ordersandcustomers.apigateway;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;

public class EnhancedUserDetails implements UserDetails {

  private final UserDetails userDetails;
  private final String accessToken;

  public EnhancedUserDetails(UserDetails userDetails, String accessToken) {
    this.userDetails = userDetails;
    this.accessToken = accessToken;
  }

  public String getAccessToken() {
    return accessToken;
  }

  @Override
  public Collection<? extends GrantedAuthority> getAuthorities() {
    return userDetails.getAuthorities();
  }

  @Override
  public String getPassword() {
    return userDetails.getPassword();
  }

  @Override
  public String getUsername() {
    return userDetails.getUsername();
  }

  @Override
  public boolean isAccountNonExpired() {
    return userDetails.isAccountNonExpired();
  }

  @Override
  public boolean isAccountNonLocked() {
    return userDetails.isAccountNonLocked();
  }

  @Override
  public boolean isCredentialsNonExpired() {
    return userDetails.isCredentialsNonExpired();
  }

  @Override
  public boolean isEnabled() {
    return userDetails.isEnabled();
  }
}
