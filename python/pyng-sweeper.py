#!/usr/bin/python3
# "Ping sweeper", joka tekee lokitiedoston pingatuista osoitteista ja niiden statuksesta
# yrittää selvittää myös hostnamen
# Noin 200 kertaa hitaampi kuin nmap :D noh, oppipahan argparsesta ja vähän socketeista
# Paketit testattu toimivaksi tcpdumpilla ja Wiresharkilla
# Author: Antti Ollikainen, 2/2023
# Licence: GPLv3


import argparse
import ctypes
import os
import random
import select
import socket
import struct
import sys


def parse_arguments():
    program_name: str = "pyng-sweeper"
    description: str = f"Ping sweep a subnet. For example: \"{program_name} 192.168.1.0 -s 1 -e 20 -l my_logfile.txt\" \
                         pings the network from 192.168.1.1 to 192.168.1.20 and logs the results in file my_logfile.txt."

    parser = argparse.ArgumentParser(prog=program_name, description=description)

    parser.add_argument("network", type=str, metavar="network address")
    parser.add_argument("-s", type=int, choices=range(1, 255), default=1, metavar="starting octet", help="optional, defaults to 1")
    parser.add_argument("-e", type=int, choices=range(1, 255),  default=254, metavar="ending octet", help="optional, defaults to 254")
    parser.add_argument("-l", type=str, default="log_pyng_sweeper.txt", metavar="log file", help="optional, name of log file, defaults to log_pyng_sweeper.txt")
    # verbose mode oli vähän jälkiajatus ja olisi varmaan järkevämpiäkin tapoja toteuttaa, kuin läiskiä koodiin yksittäisiä if-lausekkeita
    parser.add_argument("-v", action="store_true", help="verbose mode")
    parser.add_argument("--version", action="version", version=f"{program_name} 0.0.1")
    
    args = parser.parse_args()

    return args


# Käytetty apuna calculate_checksum() ja ping()-aliohjelmien teossa:
# https://gist.github.com/pyos/10980172
# https://github.com/Akhavi/pyping/blob/master/pyping/core.py
# Tässä tapahtuu jotain mustaa magiaa bittien siirtelyä ja maskausta tarkistussumman laskemiseksi
def calculate_checksum(data):
    x = sum(x << 8 if i % 2 else x for i, x in enumerate(data)) & 0xFFFFFFFF
    x = (x >> 16) + (x & 0xFFFF)
    x = (x >> 16) + (x & 0xFFFF)

    return struct.pack("<H", ~x & 0xFFFF)


def ping(ip_address: str, verbose: bool):
    data = b""
    id: int = random.randrange(0, 65535)
    seq_number: int = 1
    timeout: int = 1

    with socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP) as connection:
        # Pakataan id ja seq_number C-kielen tietueeseen, iso H on unsinged short 0 - 65535
        id_and_seq = struct.pack("!HH", id, seq_number) 
        # ICMP-otsakkeen rakenne:
        # 8 bittiä, 8 bittiä, 16 bittiä
        # Tyyppi, koodi, tarkistussumma
        # Tyyppi 8, koodi 0 on echo request eli pingaus, mitä tässä käytetään
        # Tyyppi 0, koodi 0 on echo reply
        # Bitit 16-32: tunnus- ja järjestysnumero
        # Bitit 32 eteenpäin: loput datasta, tässä ei dataa lähetetä
        packet = b"\x08\0" + calculate_checksum(b"\x08\0\0\0" + id_and_seq) + id_and_seq

        connection.connect((ip_address, 1))
        connection.sendall(packet)
        if verbose:
            print(f"Sent packet: {packet}")
        
        while select.select([connection], [], [], timeout)[0]:
            reply = connection.recv(1024)
            if verbose:
                print(f"Received packet: {reply}")
                print(f"Length of packet: {len(reply)} bytes")
            # Vastauspakettien pitäisi olla 28 tavua pitkiä, 20 IP + 8 ICMP
            if(len(reply) < 28):
                continue
            else:
                return 0
            

def main():
    args: cls = parse_arguments()
    start: int = args.s
    end: int = args.e
    log_file: str = args.l
    log_message: str = "{:16} {:16} {:16}\n".format("Hostname:", "IP address:", "State:")
    verbose: bool = args.v

    try:
        socket.inet_aton(args.network)
    except OSError:
        print("Invalid IP address. Quitting program.")
        sys.exit(1)

    for i in range(start, end + 1):
        ip_address: list = args.network.split(".")
        ip_address: str = str(ip_address[0]) + "." + str(ip_address[1]) + "." + str(ip_address[2]) + "." + str(i)

        try:
            hostname: tuple = socket.gethostbyaddr(ip_address)
            hostname: str = hostname[0]
        except:
            hostname: str = "No hostname"

        if verbose:
            print(f"\nPinging {ip_address}")

        # Onnistunut pingaus palauttaa nollan
        if(ping(ip_address, verbose) == 0):
            if verbose:
                print("Succesful reply")
            log_message = log_message + f"{hostname:16} {ip_address:16} up\n"
        else:
            if verbose:
                print("No reply")
            log_message = log_message + f"{hostname:16} {ip_address:16} down\n"

    with open(log_file, "wt") as file:
        file.write(log_message)
    file.close()

    sys.exit(0)


if __name__ == "__main__":
    try:
        if sys.platform.startswith("linux") and os.getuid() == 0 or sys.platform.startswith("win32") and ctypes.windll.shell32.IsUserAnAdmin() != 0:
            main()
        else:
            # Raw-sokettien käsitteleminen vaatii root-oikeudet
            print("Program requires root-priviledges. Quitting program.")
            sys.exit(1)
    except KeyboardInterrupt:
        print("Program terminated with Ctrl-C.")
        sys.exit(1)
