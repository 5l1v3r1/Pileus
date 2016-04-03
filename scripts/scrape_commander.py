#!/usr/bin/env python

# accepts connections. the scraper will connect to the scrape_commander and
# send the filename that needs to be dealt with.
# the scrape_commander will then scp the file over, decrypt it, and deal with it

import socket

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
    c.close()

