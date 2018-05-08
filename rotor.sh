#!/bin/bash
#apt-get install tor lsof tmux -y --force-yes
NAME="Rotor Daemon"
killall tor
mv /etc/tor/torrc /etc/tor/torrc.bak
mv /etc/proxychains.conf /etc/proxychains.conf.bak
tmux kill-session -t "$NAME"
tmux new-session -s "$NAME" -n "Tor daemons" -d

cat << EOF > /etc/proxychains.conf
random_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
socks5	127.0.0.1	9050
socks5	127.0.0.1	9051
socks5	127.0.0.1	9052
socks5	127.0.0.1	9053
EOF

for i in $(seq 0 3);
do

	cat << EOF > /etc/tor/torrc.$i
    	SocksPort 905$i # Default: Bind to localhost:9050 for local connections.
	DataDirectory /var/lib/tor.0
	ControlPort 915$i
    	EOF

	tmux new-window -n "Tor daemon n°$i"
	echo "Launching Tor instance..."
	echo "Tor$i on port 905$i"
	tmux send -t "Tor daemon n°$i" "tor -f /etc/tor/torrc.$i" ENTER
done
echo "4 Tor instances created from port 9050 to 9053"
echo "To kill those daemons, use magic !!!"
echo "No, just kidding ! killall tor"
lsof -i
tmux atta -t "$NAME"
