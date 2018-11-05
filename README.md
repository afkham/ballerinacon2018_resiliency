# ballerinacon2018_resiliency
Samples from BallerinaCon 2018 service resiliency demo

Slides: [presentation](https://docs.google.com/presentation/d/122GtDKjISe-XqX-mS2cZuWEmiuX44kFXFFqflNXB4LY/edit#slide=id.g3d940d3ef0_0_45)

## Sample 1: Timeout

### How to run
```
ballerina run 01-timeout.bal
```

```
curl http://localhost:9090/timeout
```

### Output
```
Idle timeout triggered before initiating inbound response
```

## Sample 2: Retry
### How to run
```
ballerina run 02-retry.bal
```

```
curl http://localhost:9090/retry
```

### Output
```
2018-11-05 17:22:42,319 INFO  [] - Simulating a delay...
2018-11-05 17:22:44,345 INFO  [] - Simulating a delay...
2018-11-05 17:22:47,344 ERROR [] - Error sending response from mock service : {message:"Connection between remote client and host is closed", cause:null}
2018-11-05 17:22:47,359 INFO  [] - Simulating a delay...
2018-11-05 17:22:49,354 ERROR [] - Error sending response from mock service : {message:"Connection between remote client and host is closed", cause:null}
2018-11-05 17:22:52,368 ERROR [] - Error sending response from mock service : {message:"Connection between remote client and host is closed", cause:null}
2018-11-05 17:22:52,372 INFO  [] - No delay.
```

## Sample 3: Failover
### How to run
```
ballerina run 03-failover.bal 
ballerina run 03-failover_be1.bal
ballerina run 03-failover_be2.bal
```

```
curl http://localhost:9090/failover
```

### Output
```
Mock service invoked.
```

## Sample 4: Load Balance
### How to run
```
ballerina run 04-load_balance.bal
```

Repeat:
```
curl http://localhost:9090/loadbalance
```

### Output

First run:

```
Response from mock1 service.
```

Second run:

```
Response from mock2 service.
```

Third run:

```
Response from mock3 service.
```

Fourth run:

```
Response from mock1 service.
```

## Sample 5: Circuit Breaker
### How to run
```
ballerina run 05-cct_breaker.bal
ballerina run 05-cct_breaker_be.bal
```

Repeat:
```
curl http://localhost:9090/cctbreaker
```

### Output
```
2018-11-05 17:34:41,132 INFO  [ballerina/http] - CircuitBreaker failure threshold exceeded. Circuit tripped from CLOSE to OPEN state.
2018-11-05 17:34:58,108 INFO  [ballerina/http] - CircuitBreaker reset timeout reached. Circuit switched from OPEN to HALF_OPEN state.
2018-11-05 17:34:58,771 INFO  [ballerina/http] - CircuitBreaker trial run  was successful. Circuit switched from HALF_OPEN to CLOSE state.
2018-11-05 17:35:03,131 INFO  [ballerina/http] - CircuitBreaker failure threshold exceeded. Circuit tripped from CLOSE to OPEN state.
2018-11-05 17:37:48,675 INFO  [ballerina/http] - CircuitBreaker reset timeout reached. Circuit switched from OPEN to HALF_OPEN state.
2018-11-05 17:37:50,384 INFO  [ballerina/http] - CircuitBreaker trial run  was successful. Circuit switched from HALF_OPEN to CLOSE state.
```

## Sample 6: Distributed Transactions
### How to run
```
ballerina run 06-txn_initiator.bal
ballerina run 06-txn_participant1.bal
ballerina run 06-txn_participant2.bal
```

```
curl http://localhost:9090/
```

### Output
```
Idle timeout triggered before initiating inbound response
```
