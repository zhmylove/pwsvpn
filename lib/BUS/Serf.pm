#!/usr/bin/perl
# made by: KorG
# vim: ft=perl ts=4 sw=4 cc=79 :

package BUS::Serf;

use strict;
use warnings;
use AnyEvent;
use AnyEvent::Subprocess;
use AnyEvent::Socket;

%PWS::Conf = (
    # Path to event socket
    BUS_SOCK => "/tmp/pws.sock",

    # Path to event handler
    BUS_HANDLER => "./event.pl",

    %PWS::Conf
);

my ($end) = 0;

sub _process_event {
    my ($event, $join_cb, $leave_cb) = @_;

    my ($me, $type, $dst, $dst_ip, $role, $tags) = split /\t/, $event;

    return if $me eq $dst;

    my %tags = map { split /=/, $_, 2 } split /,/, $tags;

    if ($type eq "member-join") {
        $join_cb->($tags{ID}, $dst_ip, $tags{AUTH});
    } elsif ($type eq "member-failed" or $type eq "member-leave") {
        $leave_cb->($tags{ID}, $dst_ip, $tags{AUTH});
    }
}

sub new {
    my ($pkg, $auth, $join_cb, $leave_cb) = @_;
    my ($id, $ip, $port, $psk, $join) = @PWS::Conf{qw( PWS_ID PWS_IP PWS_PORT
        PWS_PSK PWS_JOIN )};

    my $command = qq(serf agent -node=n$id -bind=$ip:$port -tag=ID=$id ) .
    qq(-tag=AUTH=$auth -encrypt=$psk -event-handler=$PWS::Conf{BUS_HANDLER});

    $command .= " -join=$join" if defined $join;

    my ($job, $chld);
    $job = AnyEvent::Subprocess->new(
        delegates => ['StandardHandles'],
        on_completion => sub { return if $end; $chld = $job->run(); },
        code => sub {
            exec split /\s+/, $command;
            die "Unable to exec in child: $!";
        },
    );
    $chld = $job->run();

    my $srv = tcp_server "unix/", $PWS::Conf{BUS_SOCK}, sub {
        my $w; $w = AnyEvent::Handle->new(fh => $_[0],
            on_read => sub {
                $_[0]->push_read(line => sub {
                    _process_event($_[1], $join_cb, $leave_cb);
                });
            },
            on_eof => sub { undef $w },
        );
    };

    bless { job => $job, chld => $chld, srv => $srv }, $pkg;
}

sub shutdown {
    my ($self) = @_;
    $end = 1;
    $self->{chld}->kill(2);
    delete $self->{srv};
}

"FreeBSD";
