#!/usr/bin/env python
"""
        Author - Gabriel Starczewski
        https://www.linkedin.com/in/gabriel-star-tester
"""

import os, sys,subprocess
from flask import Flask, request
from flask_basicauth import BasicAuth

app = Flask(__name__)
#that is not meant ot secure anything just prevent scanners from keeping port
app.config['BASIC_AUTH_USERNAME'] = 'j'
app.config['BASIC_AUTH_PASSWORD'] = 'j'
app.config['BASIC_AUTH_FORCE'] = True


@app.route('/restart/<version>/<xms>/<xmx>')
def restart(version,xms,xmx,methods=['GET']):
    pid=0
    if sys.platform == "linux" or sys.platform == "linux2":
        try:
            subprocess.call(["./startServer.sh",version,"-Xms%s -Xmx%s" %(xms,xmx)])
            f=open('jmeter.pid')
            pid=f.read()
            f.close()
        except:
            return "Error",400
        return "Node restarted with pid: %s" %pid

@app.route('/stop')
def stop(methods=['GET']):
    if sys.platform == "linux" or sys.platform == "linux2":
        try:
            subprocess.call(["./stopServer.sh"])
        except:
            return "Error",400
        return "Node stopped"



if __name__ == '__main__':
