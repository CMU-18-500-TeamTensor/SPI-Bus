# LOOPBACK TEST

import socket

def send(bs):
    '''
    Sends a packet to the Pi to forward to the FPGA.
    NOTE: The extra bit packing is for debug ONLY
    Data in transit will always be 32-bit words!
    '''
    extend = -len(bs) % 4
    words = len(bs) // 4 + (1 if extend > 0 else 0) # number of words
    prefix = words.to_bytes(4, 'little') # get length in bytes
    msg = prefix + bs + b'\x00' * extend
    print("sending:", msg)
    sock.send(msg)

TCP_IP = "192.168.1.9"
TCP_PORT = 18500

sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_STREAM) # TCP
sock.connect((TCP_IP, TCP_PORT))

print("TCP target IP:", TCP_IP)
print("TCP target port:", TCP_PORT)

send(b'first')
data = sock.recv(1024)
print("received message:", data, len(data))

send(b'another')
data = sock.recv(1024)
print("received message:", data, len(data))


send(b'hello there')
data = sock.recv(1024)
print("received message:", data, len(data))

send(b'whats up')
data = sock.recv(1024)
print("received message:", data, len(data))

sock.close()