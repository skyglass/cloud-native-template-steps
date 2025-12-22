package io.eventuate.examples.tram.sagas.ordersandcustomers.endtoendtests;

import io.eventuate.common.json.mapper.JSonMapper;
import io.eventuate.examples.common.money.Money;
import io.eventuate.examples.tram.sagas.ordersandcustomers.apigateway.api.web.GetCustomerHistoryResponse;
import io.eventuate.examples.tram.sagas.ordersandcustomers.customers.api.web.CreateCustomerRequest;
import io.eventuate.examples.tram.sagas.ordersandcustomers.customers.api.web.CreateCustomerResponse;
import io.eventuate.examples.tram.sagas.ordersandcustomers.customers.api.web.GetCustomerResponse;
import io.eventuate.examples.tram.sagas.ordersandcustomers.customers.api.web.GetCustomersResponse;
import io.eventuate.examples.tram.sagas.ordersandcustomers.orders.api.messaging.common.OrderState;
import io.eventuate.examples.tram.sagas.ordersandcustomers.orders.api.messaging.common.RejectionReason;
import io.eventuate.examples.tram.sagas.ordersandcustomers.orders.api.web.CreateOrderRequest;
import io.eventuate.examples.tram.sagas.ordersandcustomers.orders.api.web.CreateOrderResponse;
import io.eventuate.examples.tram.sagas.ordersandcustomers.orders.api.web.GetOrderResponse;
import io.eventuate.examples.tram.sagas.ordersandcustomers.orders.api.web.GetOrdersResponse;
import io.eventuate.util.test.async.Eventually;
import io.eventuate.util.test.async.EventuallyConfig;
import io.restassured.RestAssured;
import io.restassured.config.RestAssuredConfig;
import org.jetbrains.annotations.Nullable;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Configuration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

import static io.restassured.RestAssured.basic;
import static io.restassured.RestAssured.given;
import static io.restassured.config.ObjectMapperConfig.objectMapperConfig;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes = CustomersAndOrdersEndToEndTest.Config.class, webEnvironment = SpringBootTest.WebEnvironment.NONE)
public class CustomersAndOrdersEndToEndTest {

    private static final Logger logger = LoggerFactory.getLogger(CustomersAndOrdersEndToEndTest.class);

    private static final ApplicationUnderTest applicationUnderTest = ApplicationUnderTest.make();

    @Configuration
    public static class Config {

    }

    private final Money creditLimit = new Money("15.00");
    private final Money orderTotalUnderCreditLimit = new Money("12.34");
    private final Money orderTotalOverCreditLimit = new Money("123.40");

    private static final String CUSTOMER_NAME = "John";

    @Value("${host.name}")
    private String hostName;


    @BeforeClass
    public static void startContainers() {
        Eventually.setDefaults(EventuallyConfig.builder().withIterations(100).build());
        applicationUnderTest.start();
        RestAssured.config = RestAssuredConfig.config().objectMapperConfig(objectMapperConfig().jackson2ObjectMapperFactory(
                (cls, charset) -> JSonMapper.objectMapper
        ));
    }

    @Before
    public void setup() {
        RestAssured.baseURI = applicationUnderTest.getApiGatewayBaseURI(hostName);
        RestAssured.port = applicationUnderTest.getApigatewayPort();
        RestAssured.authentication = basic("user", "password");
    }

    @Test
    public void shouldGetCustomers() {
        assertNotNull(get("/orders", GetCustomersResponse.class));

    }

    @Test
    public void shouldGetOrder() {
        assertNotNull(get("/orders", GetOrdersResponse.class));
    }
    @Test
    public void shouldApprove() {
        CreateCustomerResponse createCustomerResponse = createCustomer();

        assertCustomerHasCreditLimit(createCustomerResponse.getCustomerId());

        CreateOrderResponse createOrderResponse = createOrder(createCustomerResponse.getCustomerId(), orderTotalUnderCreditLimit);

        assertOrderState(createOrderResponse.getOrderId(), OrderState.APPROVED, null);
    }

    @Nullable
    private CreateOrderResponse createOrder(Long customerId, Money orderTotal) {
        return post("/orders", new CreateOrderRequest(customerId, orderTotal), CreateOrderResponse.class);
    }

    @Nullable
    private CreateCustomerResponse createCustomer() {
        return post("/customers", new CreateCustomerRequest(CUSTOMER_NAME, creditLimit), CreateCustomerResponse.class);
    }

    private <T> T post(String path, Object body, Class<T> responseClasz) {
        return given()
                .when()
                .contentType("application/json")
                .body(body)
                .post(path)
                .then()
                .log().ifValidationFails()
                .statusCode(200)
                .extract()
                .body().as(responseClasz);
    }

    private void assertCustomerHasCreditLimit(long id) {
        GetCustomerResponse customer = get("/customers/{id}", GetCustomerResponse.class, id);

        assertEquals(creditLimit, customer.getCreditLimit());

    }

    private static <T> T get(String path, Class<T> responseClasz, Object... pathParams) {
        return given()
                .when()
                .get(path, pathParams)
                .then()
                .log().ifValidationFails()
                .statusCode(200)
                .extract()
                .body().as(responseClasz);
    }

    private static void getExpectingNotFound(String path, Object... pathParams) {
        given()
                .when()
                .get(path, pathParams)
                .then()
                .log().ifValidationFails()
                .statusCode(404);
    }

    @Test
    public void shouldRejectBecauseOfInsufficientCredit() {
        CreateCustomerResponse createCustomerResponse = createCustomer();

        CreateOrderResponse createOrderResponse = createOrder(createCustomerResponse.getCustomerId(), orderTotalOverCreditLimit);

        assertOrderState(createOrderResponse.getOrderId(), OrderState.REJECTED, RejectionReason.INSUFFICIENT_CREDIT);
    }

    @Test
    public void shouldRejectBecauseOfUnknownCustomer() {

        CreateOrderResponse createOrderResponse = createOrder(Long.MAX_VALUE, new Money("123.40"));

        assertOrderState(createOrderResponse.getOrderId(), OrderState.REJECTED, RejectionReason.UNKNOWN_CUSTOMER);
    }

    @Test
    public void shouldSupportOrderHistory() {

        CreateCustomerResponse createCustomerResponse = createCustomer();

        CreateOrderResponse createOrderResponse = createOrder(createCustomerResponse.getCustomerId(), orderTotalUnderCreditLimit);

        Eventually.eventually(() -> {
            GetCustomerHistoryResponse customerResponse = getOrderHistory(createCustomerResponse.getCustomerId());

            assertEquals(creditLimit.getAmount().setScale(2), customerResponse.getCreditLimit().getAmount().setScale(2));
            assertEquals(createCustomerResponse.getCustomerId(), customerResponse.getCustomerId());
            assertEquals(CUSTOMER_NAME, customerResponse.getName());
            assertEquals(1, customerResponse.getOrders().size());

            assertEquals((Long) createOrderResponse.getOrderId(), customerResponse.getOrders().get(0).getOrderId());
            assertEquals(OrderState.APPROVED, customerResponse.getOrders().get(0).getOrderState());
        });
    }

    @Nullable
    private GetCustomerHistoryResponse getOrderHistory(Long customerId) {
        return get("/customers/{id}/orderhistory", GetCustomerHistoryResponse.class, customerId);
    }

    private void assertOrderState(Long id, OrderState expectedState, RejectionReason expectedRejectionReason) {
        Eventually.eventually(() -> {
            GetOrderResponse order = get("/orders/{id}", GetOrderResponse.class, id);
            assertEquals(expectedState, order.getOrderState());
            assertEquals(expectedRejectionReason, order.getRejectionReason());
        });
    }

    public void shouldHandleOrderHistoryQueryForUnknownCustomer() {
        getExpectingNotFound("/customers/{id}/orderhistory", System.currentTimeMillis());
    }

    @Test
    public void testSwaggerUiUrls() throws IOException {
        testSwaggerUiUrl(applicationUnderTest.getApigatewayPort());

        if (applicationUnderTest.exposesSwaggerUiForBackendServices()) {
            testSwaggerUiUrl(applicationUnderTest.getCustomerServicePort());
            testSwaggerUiUrl(applicationUnderTest.getOrderServicePort());
        }
    }

    private void testSwaggerUiUrl(int port) throws IOException {
        assertUrlStatusIsOk(String.format("http://%s:%s/swagger-ui/index.html", hostName, port));
    }

    private void assertUrlStatusIsOk(String url) throws IOException {
        HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
        if (connection.getResponseCode() != 200)
            Assert.fail(String.format("Expected 200 for %s, got %s", url, connection.getResponseCode()));
    }

}