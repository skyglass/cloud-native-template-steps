package io.eventuate.examples.tram.sagas.ordersandcustomers.customers.domain;

import io.eventuate.examples.common.money.Money;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

public class CustomerService {

  private CustomerRepository customerRepository;

  public CustomerService(CustomerRepository customerRepository) {
    this.customerRepository = customerRepository;
  }

  @Transactional
  public Customer createCustomer(String name, Money creditLimit) {
    Customer customer  = new Customer(name, creditLimit);
    return customerRepository.save(customer);
  }

  public void reserveCredit(long customerId, long orderId, Money orderTotal) throws CustomerCreditLimitExceededException {
    Customer customer = customerRepository.findById(customerId).orElseThrow(CustomerNotFoundException::new);
    customer.reserveCredit(orderId, orderTotal);
  }

  public List<Customer> findAll() {
    return StreamSupport.stream(customerRepository.findAll().spliterator(), false).collect(Collectors.toList());
  }

  public Optional<Customer> findById(long customerId) {
    return customerRepository.findById(customerId);
  }
}
