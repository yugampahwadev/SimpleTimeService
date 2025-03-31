import http.server
import json
from datetime import datetime
import socket

class SimpleHTTPRequestHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            ip_address = self.client_address[0]
            response_data = {
                "timestamp": timestamp,
                "ip": ip_address
            }
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode())
        else:
            self.send_response(404)
            self.end_headers()

server_address = ('', 8080)
httpd = http.server.HTTPServer(server_address, SimpleHTTPRequestHandler)
print("Server running on port 8080...")
httpd.serve_forever()
