#!/usr/bin/python

import requests
import re
import json
from time import sleep

repos = []
print "[+] Gathering Repositories"
for i in range(1,100):
	r = requests.get("https://github.com/search?o=desc\&p=" + str(i) + "\&q=soundcloud_client_id\&ref=simplesearch\&s=indexed\&type=Code")

	s = re.compile("[/]\w*[/]\w*/blob/")
	match = s.findall(r.text)

	for j in range(0, len(match)):
		match[j] = match[j].rstrip('/blob/')
		repos.append(match[j][1:len(match[j])])

	repos = list(set(repos))

	sleep(1)
	
print "[+] Done Gathering Repositories"
print "[+] Searching Repositories for API Keys"

keys = []
for i in range(0, len(repos)):
	#Change auth token in header of request
	r = requests.get("https://api.github.com/search/code?q=soundcloud_client_id+in:file+repo:" + str(repos[i]), headers={"Accept":"application/vnd.github.v3.text-match+json", "Authorization":"token CHANGEME"})
	webJson = r.json()

	try:
		containsAPI = webJson['items'][0]['text_matches'][0]['fragment']
	except Exception as e:
		pass


	s = re.compile("([a-z]|[0-9]){32}")
	match = s.search(containsAPI)

	if match is not None:
		keys.append(containsAPI[match.start():match.end()])
		print "[*] Key Found"
	

keys = list(set(keys))
with open("keys.txt", 'w+') as KEYS:
	for item in keys:
		KEYS.write(item + '\n')



