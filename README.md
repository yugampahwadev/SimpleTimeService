# SimpleTimeService

This repository contains a simple Python web server that returns a JSON response with the current timestamp and the IP address of the visitor. The server is built using Python's built-in http.server module and runs in a Docker container.

**Features**<br>
Returns a JSON response with the following structure when accessed at the / URL path<br>
<br>

**Prerequisites**<br>
Docker installed on your machine.<br>
A stable internet connection to pull the image from Docker Hub.<br>
<br>
**Pull the Docker Image from Docker Hub**<br>
docker pull ypahwa/python-web-server:latest<br>
<br>
**Run the Docker Container**<br>
docker run -p 8080:8080 ypahwa/python-web-server:latest<br>
<br>
**Access the Web Server**<br>
http://localhost:8080<br>
