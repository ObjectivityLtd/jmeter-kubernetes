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
    if sys.platform == "linux" or sys.platform == "linux2":
        try:
            subprocess.call(["./startServer.sh",version,"-Xms%s -Xmx%s" %(xms,xmx)])
        except:
            return "Error",400
        return "Node restarted"

@app.route('/stop')
def stop(methods=['GET']):
    if sys.platform == "linux" or sys.platform == "linux2":
        try:
            subprocess.call(["./stopServer.sh"])
        except:
            return "Error",400
        return "Node stopped"



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
