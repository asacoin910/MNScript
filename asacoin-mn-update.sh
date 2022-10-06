#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'asacoind' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop asacoind${NC}"
        asacoin-cli stop
        sleep 30
        if pgrep -x 'asacoind' > /dev/null; then
            echo -e "${RED}asacoind daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 asacoind
            sleep 30
            if pgrep -x 'asacoind' > /dev/null; then
                echo -e "${RED}Can't stop asacoind! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your Asacoin Masternode Will be Updated To The Latest Version v1.0.1 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'asacoinauto.sh' | crontab -

#Stop asacoind by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/asacoin*
mkdir ASACOIN_1.0.1
cd ASACOIN_1.0.1
wget https://github.com/asacoin910/asacoin/releases/download/1.0.1/asacoin-1.0.1-linux.tar.gz
tar -xzvf asacoin-1.0.1-linux.tar.gz
mv asacoind /usr/local/bin/asacoind
mv asacoin-cli /usr/local/bin/asacoin-cli
chmod +x /usr/local/bin/asacoin*
rm -rf ~/.asacoin/blocks
rm -rf ~/.asacoin/chainstate
rm -rf ~/.asacoin/sporks
rm -rf ~/.asacoin/peers.dat
cd ~/.asacoin/
wget https://github.com/asacoin910/asacoin/releases/download/1.0.1/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.asacoin/bootstrap.zip ~/ASACOIN_1.0.1


# add new nodes to config file
sed -i '/addnode/d' ~/.asacoin/asacoin.conf

echo "addnode=155.138.231.93
addnode=45.76.253.180
addnode=155.138.210.180
addnode=45.76.252.37" >> ~/.asacoin/asacoin.conf

#start asacoind
asacoind -daemon

printf '#!/bin/bash\nif [ ! -f "~/.asacoin/asacoin.pid" ]; then /usr/local/bin/asacoind -daemon ; fi' > /root/asacoinauto.sh
chmod -R 755 /root/asacoinauto.sh
#Setting auto start cron job for Asacoin  
if ! crontab -l | grep "asacoinauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/asacoinauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"
