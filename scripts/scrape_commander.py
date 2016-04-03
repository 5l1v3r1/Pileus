#!/usr/bin/env python

# accepts connections. the scraper will connect to the scrape_commander and
# send the filename that needs to be dealt with.
# the scrape_commander will then scp the file over, decrypt it, and deal with it

import socket
import threading
import paramiko
from ConfigParser import SafeConfigParser

def createSSHClient(server, port, user, password):
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(server, port, user, password)
    return client

# scp's over <fname> from <ip>
def worker(ip, fname):
    # read config file for scp credsu
    parser = SafeConfigParser()
    parser.read('creds.ini')
    uname = parser.get(ip, username)
    passw = parser.get(ip, password)

    ssh = createSSHClient(ip, 22, uname, passw)
    scp = SCPClient(ssh.get_transport())
    local_path = "/home/ubuntu/"
    remote_path = fname
    scp.get(local_path, remote_path)


s = socket.socket()
host = socket.gethostname()
port = 12344
s.bind((host, port))

s.listen(10)
while True:
    c, addr = s.accept()
    print 'got connection from: ', addr
    fname = c.recv(1024) # receive the filename info
    print addr[0], ":", fname 
    t = threading.Thread(target=worker, args(addr[0], fname))
    c.close()

