#!/usr/bin/perl
# made by: KorG
# vim: ft=perl ts=4 sw=4 cc=79 :

use strict;
use warnings;
use AnyEvent;
use FindBin;
use lib 'lib';

chdir $FindBin::Bin or die "Unable to chdir to $FindBin::Bin\n";

require './config.pm';
-f './config.local.pm' and require './config.local.pm';
%PWS::Conf = (
    PWS_JOIN => undef,
    PWS_PORT => 12300,
    PWS_PSK => 'iOzJDcQzdSErhzgTaV11kbAiUBtb7N1COAd+5JICPFQ=',
    VPN_FMT => '10.10.%d.%d/32',
    BUS_MODULE => "BUS::Serf",
    VPN_MODULE => "VPN::Wireguard",
    %PWS::Conf
);

defined $PWS::Conf{$_} or die "$_ must be defined!\n" for qw( PWS_ID PWS_IP );

# Load all the required modules
my $MOD_BUS = $PWS::Conf{BUS_MODULE};
my $MOD_VPN = $PWS::Conf{VPN_MODULE};
eval "require $_" or die $@ for ($MOD_BUS, $MOD_VPN);

## Create the vpn opbject.
# This object is used for creating/removing p2p tunnels on each membership
# change received over the bus.  This object should have a constructor:
# - new($net_fmt)
# given $net_fmt is printf() format of the VPN with first %d for source host
# ID and second %d for destination host ID, ex. "10.10.%d.%d/32"
# ... and implement such methods:
# - tunnel_up($dst_node)
# - tunnel_down($dst_node)
# - auth() -- Get AUTH tag to share with peers, used for tunnels creation
# - shutdown() -- Gracefully stop all running tunnels
# Node object is a hash:
# $node = {
#   id => $id,
#   auth => $auth,
#   ip => $ip,
# }
my $VPN = $MOD_VPN->new();

## Create the bus object.
# This object is used for membership tracking.  The bus should produce events
# on membership join and leave; it should implement a constructor which takes
# AUTH token to share inside the cluster and subroutine references for each
# event respectively, and a shutdown() subroutine to execute at exit:
# - new($id, $ip, $port, $psk, $auth, $sub_join, $sub_leave)
# - shutdown() -- Gracefully stop the bus
# Each callback receives these arguments: ($id, $ip, $auth), some of them may
# be unset.
my $BUS = $MOD_BUS->new($VPN->auth(),
    # Join callback
    sub {
        my ($id, $ip, $auth) = @_;
        my $node = { id => $id, ip => $ip, auth => $auth };
        $VPN->tunnel_up($node);
    },
    # Leave callback
    sub {
        my ($id, $ip, $auth) = @_;
        my $node = { id => $id, ip => $ip, auth => $auth };
        $VPN->tunnel_down($node);
    },
);

## Termination stuff
my $done = AnyEvent->condvar;
my $end_cb = sub {
    $VPN->shutdown();
    $BUS->shutdown();
    $done->send();
};
my @sig;
push @sig, AnyEvent->signal(signal => $_, cb => $end_cb) for qw( INT TERM );
$done->recv;
