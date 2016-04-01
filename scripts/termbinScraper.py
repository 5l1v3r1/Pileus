#!/usr/bin/env python

import sys
import time
import requests
import threading

# Checks to see if the URL found contains 'hi there', which is the testing 
# identifier. If it does, write to a file so it can be processed by something else
def checker(r, url):
    if 'hi there' in r.text:
        print "[+] Match Found!"
        f = open("found_"+url.strip(), 'w')
        f.write(r.text)

def worker(url):
    try:
        r = requests.get("http://termbin.com/"+url.strip())
        if r.status_code == 200:
            print "ok! -> ", url, r.status_code
            list_of_oks.append(url)

            # starts a thread to check the found page for our identifier
            t = threading.Thread(target=checker, args=(r,url))
            t.start()
        else:
            print "bad", url, r.status_code
    except requests.exceptions.RequestException:
        print "they're bringing down the banhammer. Run!"
    

if __name__ == '__main__':
    list_of_oks = [] # wow this needs a better name. 
    # _s has the wordlist start at 's'
    with open('_s') as f:
        urls = f.readlines()

    for i in xrange(len(urls)):
        # They have 'rate limiting' and this seems to be the magic number delay
        time.sleep(.01)
        t = threading.Thread(target=worker, args=(urls[i],))
        t.start()
    
    while(True):
        if threading.activeCount() == 1:
            print '-' * 25
            print 'done'
            print list_of_oks
            sys.exit(0)
