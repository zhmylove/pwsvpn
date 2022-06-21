#!/usr/bin/perl
# made by: KorG
# vim: ft=perl ts=4 sw=4 cc=79 :

use strict;
use warnings;
use FindBin;
use IO::Socket::UNIX;

chdir $FindBin::Bin or die "Unable to chdir to $FindBin::Bin\n";
require './config.pm';
-f './config.local.pm' and require './config.local.pm';

# Firstly check for stdin
my @stdin = <STDIN>;
exit unless @stdin;

# Split to avoid warnings
defined $PWS::Conf{PWS_SOCK} or die "PWS_SOCK must be defined!\n";
my $sock = $PWS::Conf{PWS_SOCK};

# Send events to main process
my $fh = IO::Socket::UNIX->new(Type => SOCK_STREAM(), Peer => $sock);
print $fh "$ENV{SERF_SELF_NAME}\t$ENV{SERF_EVENT}\t$_" for @stdin;
