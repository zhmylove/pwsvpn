# Example 1. Simple configuration of 4 nodes

## Node 1

```
# cat config.local.pm
%PWS::Conf = (
    %PWS::Conf,
    PWS_ID => 1,
    PWS_IP => '172.23.0.1',
);
13;
```

## Node 2

```
# cat config.local.pm
%PWS::Conf = (
    %PWS::Conf,
    PWS_ID => 2,
    PWS_IP => '172.23.0.2',
    PWS_JOIN => '172.23.0.1',
);
13;
```

## Node 3

```
# cat config.local.pm
%PWS::Conf = (
    %PWS::Conf,
    PWS_ID => 3,
    PWS_IP => '172.23.0.3',
    PWS_JOIN => '172.23.0.2',
);
13;
```

## Node 4

```
# cat config.local.pm
%PWS::Conf = (
    %PWS::Conf,
    PWS_ID => 4,
    PWS_IP => '172.23.0.4',
    PWS_JOIN => '172.23.0.2',
);
13;
```

## Produced full mesh:

```
    +--------------------+     +--------------------+
    | Node 1             |     | Node 2             |
    |wg1002(10.10.2.1/32)|     |wg1001(10.10.1.2/32)|
    |wg1003(10.10.3.1/32)|-----|wg1003(10.10.3.2/32)|
    |wg1004(10.10.4.1/32)|     |wg1004(10.10.4.2/32)|
    +--------------------\     /--------------------+
               |          \   /           |
               |           \ /            |
               |            X             |
               |           / \            |
               |          /   \           |
    +--------------------/     \--------------------+
    | Node 3             |     | Node 4             |
    |wg1001(10.10.3.3/32)|-----|wg1001(10.10.1.4/32)|
    |wg1002(10.10.3.3/32)|     |wg1002(10.10.2.4/32)|
    |wg1004(10.10.4.3/32)|     |wg1003(10.10.3.4/32)|
    +--------------------+     +--------------------+
```

## Ping from Node 1 to peers:

```
# ping 10.10.1.2 # node 2
# ping 10.10.1.3 # node 3
# ping 10.10.1.4 # node 4
```

# Future work

Add quagga support to atomatically configure RIP with explicit neighbors.
