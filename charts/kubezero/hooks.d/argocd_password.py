#!/usr/bin/env python3

import bcrypt
import random
import string

chars_fixed = string.ascii_letters + string.digits
passwd = "".join(random.choice(chars_fixed) for x in range(15))

salt = bcrypt.gensalt()
hashed = bcrypt.hashpw(passwd.encode('utf-8'), salt)

print("{}:{}".format(passwd, hashed.decode('utf-8')))
