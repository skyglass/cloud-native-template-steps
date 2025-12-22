package io.eventuate.examples.tram.sagas.ordersandcustomers.endtoendtests;

public class ApplicationUnderTestUsingKind extends ApplicationUnderTest {
  @Override
  public void start() {

  }

  @Override
  int getApigatewayPort() {
    var port = System.getenv("API_GATEWAY_PORT");
    return port != null ? Integer.parseInt(port) : 80;
  }

  @Override
  int getCustomerServicePort() {
    throw new UnsupportedOperationException();
  }

  @Override
  int getOrderServicePort() {
    throw new UnsupportedOperationException();
  }

  @Override
  boolean exposesSwaggerUiForBackendServices() {
    return false;
  }
}
