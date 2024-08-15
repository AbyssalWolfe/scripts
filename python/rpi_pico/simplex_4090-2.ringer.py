import _thread
import os
import socket

import network
from dotenv import load_dotenv
from machine import Pin
from utime import sleep

load_dotenv()

led = Pin(25, Pin.OUT)
relay = Pin(6, Pin.OUT)
relay(0)

ring = False


def init_wifi():
	wlan = network.WLAN(network.STA_IF)
	wlan.active(True)
	wlan.ifconfig(
		(
			os.getenv("WIFI_IP"),
			os.getenv("WIFI_NETMASK"),
			os.getenv("WIFI_GATEWAY"),
			os.getenv("WIFI_DNS"),
		)
	)
	wlan.connect(os.getenv("WIFI_SSID"), os.getenv("WIFI_PASSWORD"))
	while not wlan.isconnected():
		print("Waiting for connection...")
		sleep(1)
	ip = wlan.ifconfig()[0]
	print(f"Connected on {ip}")


def listen():
	global ring

	address = (os.getenv("WIFI_IP"), 80)
	connection = socket.socket()
	connection.bind(address)
	connection.listen(1)

	while True:
		client = connection.accept()[0]
		request = client.recv(1024)
		request = str(request)
		try:
			request = request.split()[1]
		except IndexError:
			pass
		if request == "/start":
			ring = True
		elif request == "/stop":
			ring = False
		client.close()


def ringer():
	while True:
		led.toggle()
		if ring:
			relay(1)
			sleep(0.5)
			relay(0)
		sleep(1)


try:
	init_wifi()
	_thread.start_new_thread(ringer, ())
	listen()
except KeyboardInterrupt:
	machine.reset()
