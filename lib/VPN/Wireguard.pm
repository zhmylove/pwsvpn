#!/usr/bin/perl
# made by: KorG
# vim: ft=perl ts=4 sw=4 cc=79 :

package VPN::Wireguard;

use strict;
use warnings;

%PWS::Conf = (
    # Base number of X for wgX interfaces
    WG_BASE => 1000,

    # This directory is used for wgX private keys
    WG_KEYDIR => "/tmp/pwsvpn/",

    %PWS::Conf
);

# Storage of running tunnels
my %running;

sub new {
    my ($pkg) = @_;
    my ($id, $port, $fmt) = @PWS::Conf{qw( PWS_ID PWS_PORT VPN_FMT )};

    umask 0077;
    my $keydir = $PWS::Conf{WG_KEYDIR};

    -d $keydir or mkdir $keydir or die "Error creating keys directory:" .
        "$keydir. $!\n";

    my $keyfile = "$keydir/privkey";
    qx(wg genkey > "$keyfile");
    die "Error creating wg key\n" if $! >> 8;

    chomp(my $pubkey = qx(wg pubkey < "$keyfile"));
    die "Error getting wg public key\n" if $! >> 8;

    bless {
        id => $id,
        base => $port,
        fmt => $fmt,
        priv => $keyfile,
        pub => $pubkey
    }, $pkg;
}

sub auth {
    my ($self) = @_;
    $self->{pub};
}

sub tunnel_up {
    my ($self, $dst) = @_;

    my $iface = "wg" . ($PWS::Conf{WG_BASE} + $dst->{id});
    my $net = sprintf $self->{fmt}, $dst->{id}, $self->{id};
    my $peer = $dst->{ip};
    my $peer_net = sprintf $self->{fmt}, $self->{id}, $dst->{id};
    my $peer_port = $self->{base} + $self->{id};
    my $listen_port = $self->{base} + $dst->{id};

    qx(ifconfig "$iface" destroy 2>/dev/null);

    qx(ifconfig "$iface" create $net);
    warn "Error creating $iface\n" if $! >> 8;

    qx(route add "$peer_net" -iface "$iface");
    warn "Error adding route to $peer_net on $iface\n" if $! >> 8;

    qx(wg set "$iface" private-key $self->{priv} listen-port "$listen_port" \\
    peer "$dst->{auth}" allowed-ips 0.0.0.0/0 endpoint "$peer:$peer_port");
    warn "Error setting options on $iface\n" if $! >> 8;

    qx(ifconfig "$iface" up);
    warn "Error enabling tunnel $iface\n" if $! >> 8;

    $running{$dst->{id}} = $dst;
}

sub tunnel_down {
    my ($self, $dst) = @_;
    my $iface = "wg" . ($PWS::Conf{WG_BASE} + $dst->{id});
    qx(ifconfig "$iface" destroy 2>/dev/null);
    delete $running{$dst->{id}};
}

sub shutdown {
    my ($self) = @_;
    $self->tunnel_down($running{$_}) for keys %running;
}

"FreeBSD";
