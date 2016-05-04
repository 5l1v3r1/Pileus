from Crypto.Cipher import AES
import base64
import sys

__ENC_KEY__ = ""
__IV__ = ""

def pad(msg):
	return msg + str((16 - (len(msg) % 16)) * '\0')

def encrypt(msg):
    msg = pad(msg)
    encryption_suite = AES.new(__ENC_KEY__, AES.MODE_CBC, __IV__)
    return base64.b64encode(encryption_suite.encrypt(msg))

def decrypt(msg):
    decryption_suite = AES.new(__ENC_KEY__, AES.MODE_CBC, __IV__)
    return decryption_suite.decrypt(base64.b64decode(msg))

if __name__ == '__main__':

	if sys.argv[1] == '-e':
		msg = raw_input("What would you like to encrypt?(Plain text): ")
		print encrypt(msg)
	elif sys.argv[1] == '-d':
		msg = raw_input("What would you like to decrypt?(Base64 encoded AES256): ")
		print decrypt(msg)
	else:
		print "Args: -[ed] encrypt or decrypt"
		sys.exit(1)
	
	sys.exit(0)

