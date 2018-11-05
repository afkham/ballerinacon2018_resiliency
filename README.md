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
curl http://localhost:9090/transaction
```

### Output

Initiator
```
2018-11-05 18:13:57,112 INFO  [] - Initiating transaction...
2018-11-05 18:13:57,120 INFO  [ballerina/transactions] - Created transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027
2018-11-05 18:13:57,753 INFO  [ballerina/transactions] - Registered remote participant: ab398519-35a3-4fe8-a983-56cf95512468:1 for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027
2018-11-05 18:13:58,122 INFO  [ballerina/transactions] - Registered remote participant: 059b3890-32ac-42a1-be3f-a64556dd907a:1 for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027
2018-11-05 18:13:58,237 INFO  [] - Got response from bizservice
2018-11-05 18:13:58,241 INFO  [ballerina/transactions] - Running 2-phase commit for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027:1
2018-11-05 18:13:58,248 INFO  [ballerina/transactions] - Preparing remote participant: ab398519-35a3-4fe8-a983-56cf95512468:1
2018-11-05 18:13:58,250 INFO  [ballerina/transactions] - Preparing remote participant: 059b3890-32ac-42a1-be3f-a64556dd907a:1
2018-11-05 18:13:58,272 INFO  [ballerina/transactions] - Remote participant: 059b3890-32ac-42a1-be3f-a64556dd907a:1 prepared
2018-11-05 18:13:58,284 INFO  [ballerina/transactions] - Remote participant: ab398519-35a3-4fe8-a983-56cf95512468:1 prepared
2018-11-05 18:13:58,286 INFO  [ballerina/transactions] - Notify(commit) remote participant: http://10.100.1.182:60453/balcoordinator/participant/2pc/1
2018-11-05 18:13:58,286 INFO  [ballerina/transactions] - Notify(commit) remote participant: http://10.100.1.182:60455/balcoordinator/participant/2pc/1
2018-11-05 18:13:58,300 INFO  [ballerina/transactions] - Remote participant: ab398519-35a3-4fe8-a983-56cf95512468:1 committed
2018-11-05 18:13:58,303 INFO  [ballerina/transactions] - Remote participant: 059b3890-32ac-42a1-be3f-a64556dd907a:1 committed
```
Participant 1
```
2018-11-05 18:13:57,579 INFO  [] - Received update stockquote request2
2018-11-05 18:13:57,590 INFO  [ballerina/transactions] - Registering for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027:1 with coordinator: http://10.100.1.182:60454/balcoordinator/initiator/1/register
2018-11-05 18:13:57,757 INFO  [ballerina/transactions] - Registered with coordinator for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027
2018-11-05 18:13:57,758 INFO  [] - Update stock quote request received. symbol:AMZN, price:244.4755702024119
2018-11-05 18:13:58,235 INFO  [] -
2018-11-05 18:13:58,276 INFO  [ballerina/transactions] - Prepare received for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027:1
2018-11-05 18:13:58,277 INFO  [ballerina/transactions] - Prepared transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027
2018-11-05 18:13:58,294 INFO  [ballerina/transactions] - Notify(commit) received for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027:1
```

Participant 2
```
2018-11-05 18:13:57,868 INFO  [ballerina/transactions] - Registering for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027:1 with coordinator: http://10.100.1.182:60454/balcoordinator/initiator/1/register
2018-11-05 18:13:58,136 INFO  [ballerina/transactions] - Registered with coordinator for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027
Inserted count:1
2018-11-05 18:13:58,211 INFO  [] -
2018-11-05 18:13:58,266 INFO  [ballerina/transactions] - Prepare received for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027:1
2018-11-05 18:13:58,267 INFO  [ballerina/transactions] - Prepared transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027
2018-11-05 18:13:58,294 INFO  [ballerina/transactions] - Notify(commit) received for transaction: b6f8c604-f40e-41a5-93cd-6f0fa599e027:1
##### Committed: b6f8c604-f40e-41a5-93cd-6f0fa599e027:1
```