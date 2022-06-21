%PWS::Conf = (
    ## At least you have to specify
    # My ID in the cluster
    #PWS_ID => 1,

    # My external IP
    #PWS_IP => '172.23.0.1',

    # Optionally specify existing peer node to join the cluster
    #PWS_JOIN => '172.23.0.2',

    # The port for clustering and the base port for wgX (up to PWS_PORT + 256)
    #PWS_PORT => 12300,

    # Pre-shared key for starting the cluster
    #PWS_PSK => 'UFdTVlBOIHdhcyBjcmVhdGVkIGJ5IFpITVlMT1ZFIQo=',

    # This format is used for p2p VPN addresses (note /32)
    #VPN_FMT => '10.10.%d.%d/32',

    ## From pwsvpn.pl
    # Module of BUS
    #BUS_MODULE => "BUS::Serf",

    # Module of VPN
    #VPN_MODULE => "VPN::Wireguard",

    ## From lib/BUS/Serf.pm
    # Path to event socket
    #BUS_SOCK => "/tmp/pws.sock",

    # Path to event handler script
    #BUS_HANDLER => "./event.pl",

    ## From lib/VPN/Wireguard.pm
    # Base number of X for wgX interfaces
    #WG_BASE => 1000,

    # This directory is used for wgX private keys
    #WG_KEYDIR => "/tmp/pwsvpn/",
);

13;
