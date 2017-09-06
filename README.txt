SSH = secure shell
    software-based approach to network security
    SSH creates a channel for running a shell on a remote computer with end-to-end encryption between 2 systems
    when data is sent by a computer to the network 
        SSH automatically encrypts (scrambles) it
    when data reaches the intended recipient 
        SSH automatically decrypts (unscrambles) it
    SSH clients communicate with SSH servers over encrypted network connections
    SSH server program 
        typically installed and run by system admin
    SSH client programs 
        typically on other computers
        make requests to SSH server
        ex: please send me a file

SSH is a protocol 
    specification of how to conduct secure communication over the network
    authentication
        reliably determine someone’s ID
        if you try to log into an account on a remote computer SSH asks for proof of ID
    encryption
        scrambles data so that it is only readable by intended participants 
    data integrity 
        guarantees data travelling over the network arrives unaltered 

SSH keys
    small blob of bits that uniquely ID SSH user
    using key with authentication agent program allows SSH to authenticate you securely without having to type passwords

    put special, non-secure public key files into remote computer accounts
    on local machine invoke ssh-agent program (runs in the background)
    choose the key you will need for login
    load the key into the agent using ssh-add program

port forwarding/tunneling
    reroutes TPC/IP connection to pass through SSH connection
    ex: out of the office but want to access the internal server in the office
    the Verve network is connected to the internet but network firewall blocks incoming connections to most ports 
    the firewall allows SSH > SSH can provide secure tunnel on a local port to the port on the remote server
    $ ssh -L 3002:localhost:119 server
    establish a secure connection from TCP port 3002 on my local machine to TCP port 119 on the server 
    need to configure browser on local machine to connect to port 3002 on local machine

file transfer with scp
    scp name-of-source name-of-destination
    $ scp pat@shell.ips.com:printme.pdf pleaseprintme.pdf
    transfers file on remote shell.ips.com machine called printme.pdf to local machine
    filename from source machine doesn’t have to match destination machine
    known hosts 

