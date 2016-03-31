#!/usr/bin/env python

import time
import requests
import threading

def worker(url):
    try:
        r = requests.get("http://termbin.com/"+url.strip())
        if r.status_code == 200:
            print "ok! -> ", url, r.status_code
            list_of_oks.append(url)
        else:
            print "bad", url, r.status_code
    except requests.exceptions.RequestException:
        print "they're bringing down the banhammer. Run!"
    

if __name__ == '__main__':
    list_of_oks = []
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
