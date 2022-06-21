# Introduction

Full-mesh modular VPN based on a cluster bus and a p2p vpn.
Initial version uses Serf as a messaging bus and Wireguard for creating p2p
tunnels.  Currently works only on FreeBSD.
A little patch for iproute2 stack needed in order to run it on GNU/Linux.
Feel free to send a PR.

# Dependencies

* devel/p5-AnyEvent
* devel/p5-AnyEvent-Subprocess
* net/wireguard
* sysutils/serf

# Quick start

1. `git clone https://github.com/zhmylove/pwsvpn`
2. Change the configuration inside config.pm or config.local.pm
    1. Set PWS\_ID to unique node ID (1..255)
    2. Set PWS\_IP to this node external IP
    3. Optionally set PWS\_JOIN to IP of some peer node
3. Open firewall ports (PWS\_BASE .. PWS\_BASE + 255)
4. If you did not specify an absoule path to event handler, then cd to pwsvpn/
5. Run pwsvpn.pl

# Configuration

Config.pm has all the comments on the configuration.  Please see EXAMPLE.md
for examples.

# Scaling

Please see lib/ contents if you want to write your own bus/vpn adapters.
PRs are very welcomed.
The main file: pwsvpn.pl has self-explanatory comments on required interfaces.

# Known issues

There is a bug in AnyEvent::Subprocess since 2015, which requires a one line
patch and unfortunately the authors of AnyEvent::Subprocess still did not fix
it.  This bug produces a warning on resent versions of Moose during startup:

```
Passing a list of values to enum is deprecated. Enum values should be wrapped
in an arrayref.
at /usr/local/lib/perl5/site_perl/AnyEvent/Subprocess/Types.pm line 42.
```

This warning does not affect pwsvpn functionality.  But if you prefer to make
a cosmetic fix, the patch is really simple:

```diff
--- /usr/local/lib/perl5/site_perl/AnyEvent/Subprocess/Types.pm.orig
+++ /usr/local/lib/perl5/site_perl/AnyEvent/Subprocess/Types.pm
@@ -39,7 +39,7 @@
 subtype CodeList, as ArrayRef[CodeRef];
 coerce CodeList, from CodeRef, via { [$_] };

-enum WhenToCallBack, qw/Readable Line/;
+enum WhenToCallBack, [qw/Readable Line/];

 1;

```
