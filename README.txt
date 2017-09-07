SSH = secure shell
    software-based approach to network security
    SSH creates a channel for running a shell on a remote computer
    end-to-end encryption between 2 systems
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
    authentication agent program = authenticate you securely without having to type passwords

    put special, non-secure public key files into remote computer accounts
    on local machine invoke ssh-agent program (runs in the background)
    choose the key you will need for login
    load the key into the agent using ssh-add program

    private key
        closely guarded secret 
        only I have it
        SSH client uses it to prove ID to servers

    public key
        place into remote machines
        during connection the SSH client and server check if public and private key match

ssh-agent
    program that keeps private keys in memory and provides auth services to SSH clients
    preload agent with private keys at the beginning of login session
    allows remote servers to have access to local ssh-agent
    agent forwarding  = ssh from one machine to another and agent connection follows along the way

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

sftp
    uses SSH protected channel for data transfer
    multiple commands for copying files can be invoked within a single session

known hosts
    the first time you log into a new remote machine it may report its never seen the machine before
    protects against man-in-the-middle attacks
    each SSH server has a secret unique ID = host key = IDs itself to the client
    the first time you connect to the remote host a public counterpart of the host key gets copied + stored to local machine
    each time you connect to remote machine SSH client checks the remote host ID using the public key

config file
    client config file is divided into sections
    each section contains settings for 1 remote host or set of related remote hosts

    Host
        Host begins a new section followed by host specification
        can be hostname
            Host server.example.com
        can be IP address
            Host 123.61.4.10
        can be nickname
            Host aws
        or wildcard pattern
            Host *
    
    multiple matches
        if you want some settings applied to all remote hosts create Host *
        first section in the file = settings take precedence over any others 
        last section = default configuration if not specified in an earlier section

when in doubt use ssh -v verbose option

proxy
    proxy = intermediary that forwards requests from client to other servers
    SSH is usually proxied for security
        ex: allow authenticated users to SSH through firewalls
    
    sometimes you can only access a remote server via intermediary server (aka jump box)
    use ProxyCommand to connect to another host via jump box as if the connection were direct using ssh
        ~/.ssh/config
        host jumpbox 
            some info...
        host remoteserver
            # specify the command to use to connect with the remote server
            # %h will be replaced with the HostName for the remote server
            ProxyCommand    ssh jumpbox nc %h 22

    netcat (nc) 
        command is needed to set and establish a TCP pipe between intermediate jump box and remote server
        used to read and write network connections directly

SOCKS
    connect with an intermediate machine using SOCKS proxy
    SOCKS is an application-layer network proxing system supported by SSH
    essentially SOCKS server acts as a middle man between 2 other servers and passes data between the 2 servers

    SOCKS5
        authentication
            proxy can apply access control and user logging 
        naming support
            don't need to specify IP address because they often change (ex: AWS elastic IP)
            instead specify (name, port) and SOCKS5 will resolve to the right IP

    SSH uses SOCKS
        as a normal SOCKS client
            middle man
        as a SOCKS server in conjunction with port forwarding
            this allows for dynamic forwarding 
            SOCKS clients can reach any TCP socket on the other side of an SSH connection through a single forward port

    dynamic forward
        $ ssh -D1080 server
        or 
        ~/.ssh/config
        host server
            DynamicForward 1080

port forwarding
