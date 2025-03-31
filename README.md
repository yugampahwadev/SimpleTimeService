# SimpleTimeService

This repository contains a simple Python web server that returns a JSON response with the current timestamp and the IP address of the visitor. The server is built using Python's built-in http.server module and runs in a Docker container.

Features
Returns a JSON response with the following structure when accessed at the / URL path

Prerequisites
Docker installed on your machine.
A stable internet connection to pull the image from Docker Hub.

Pull the Docker Image from Docker Hub
docker pull ypahwa/python-web-server:latest

Run the Docker Container
docker run -p 8080:8080 ypahwa/python-web-server:latest

Access the Web Server
http://localhost:8080
