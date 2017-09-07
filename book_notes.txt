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

TCP (transmission control protocol)
    transport mechanism for many application level internal protocols 
    acts like a 2 way pipe
    either side may write any number of bytes at any time to the pipe
    bytes are guaranteed to be delivered unaltered and in order at the other side

    when a program establishes a TCP connection to a service the program needs 2 pieces of info
        IP address of destination machine
        way to ID the service = port number

        IP + port # = socket
        SSH connection is between the source socket and the destination socket

    target port number is standardized
        ex: SSH connects to port 22
    source port number is not
        neither the client nor the server cares which source port # is used by the client

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

    SSH can use SOCKS
        as a normal SOCKS client
        as a SOCKS server in conjunction with port forwarding
            this allows for dynamic forwarding 
            SOCKS clients can reach any TCP socket on the other side of an SSH connection through a single forward port

    dynamic forward
        $ ssh -D1080 server
        or 
        ~/.ssh/config
        host server
            DynamicForward 1080

port forwarding/tunneling
    reroutes TPC/IP connection to pass through SSH connection

    ex: out of the office but want to access the internal server in the office
        the Verve network is connected to the internet 
            but network firewall blocks incoming connections to most ports 
        the firewall allows SSH 
            SSH can provide secure tunnel on a local port to the port on the remote server
        $ ssh -L 3002:localhost:119 server
            establish a secure connection from TCP port 3002 on my local machine to TCP port 119 on the server 
            need to configure browser on local machine to connect to port 3002 on local machine

    forwarding occurs at application level not network level
        SSH intercepts a service request from a program on one side of the SSH connection >
        sends it across the encrypted connection >
        delivers to intended recipient

    aka tunneling because SSH provides a secure tunnel through which other TCP/IP connections may pass

    local forwarding
        -L specifies that the given port on the local client side host is to be forwarded 
        to the given host and port on the remote side

        ssh -L sourcePort:forwardToHost:onPort remoteServer

        connect with ssh to remoteServer
        forward all connection attempts to the local sourcePort on port onPort to machine forwardToHost 
        which can be reached from the remoteServer machine

        ex: ssh -L 80:localhost:80 superserver

        a connection made to local port 80 is to be forwarded to port 80 on superserver
        that means if someone connects to your computer with a web browser 
        they get the response of the web server running on superserver
        I have no webserver running on my local machine

        ex: IMAP server running on machine S and email reader on home machine H
        want to secure connection using SSH

        IMAP uses TCP port 143 = IMAP server listens for connections on port 143 on the server machine
        need to choose a local port on H machine (random number) and forward to remote socket 
        let's use 2001

        $ ssh -L2001:localhost:143 S

        ssh will forward connections from (localhost,2001) on local machine to (S,143) on remote server

        will then log you into S server
        SSH session has also forwarded TCP port 2001 on H to port 143 on S
        this forwarding continues until you log out of the session
        to make use of the tunnel the final step is to tell your email reader on H to use the forwarded port

        path of connection
            1. email reader on home machine H sends data to local port 2001
            2. the local SSH client on H reads port 2001, encrypts data, and sends via SSH connection to SSH server on S
            3. SSH server on S decrypts the data and sends it to IMAP server listening on port 143 on S
            4. data is sent back from the IMAP server on S to home machine H by the same process in reverse

    remote forwarding
        -R specifies that the given port on the remote server is to be forwarded to the given host and port on the local side

        ssh -R sourcePort:forwardToHost:onPort localMachine

        connect with SSH to localMachine
        forward all connection attempts to remote sourcePort to port onPort on the machine forwardToHost
        which can be reached from your local machine

        ex: ssh -R 80:localhost:80 tinyserver

        a connection made to port 80 of tinyserver is to be forwarded to port 80 on your local machine
        that means if someone connects to the small server with a web browser 
        they get the response of the web server running on your local machine
        tinyserver has no webserver running but people connecting to tinyserver think so

        ex: logged into server machine S with IMAP server running 
        can create a secure tunnel for remote clients to reach the IMAP server on port 143
        this time the TCP client is remote, the server is local, and forward connection is initiated from remote machine

        $ ssh -R2001:localhost:143 H

        SSH will forward connections from (localhost,143) on remote server to (H,2001) on home machine

dynamic port forwarding
    how can I tunnel my web browser over SSH?

    we want to redirect the web browswer over SSH without fussing with the URL
    most browsers have this feature - a proxy
    set the browser's HTTP proxy to our SSH-forwarded port localhost:8080
    this means it will always connect to our forwarded port in response to any HTTP URL we provide
    the browser assumes this port leads to a proxy server that knows how to get the content for the 
    web servers we seek so the browser does not have to connect with the web servers directly

    dynamic forwarding / SOCKS forwarding
        browser can communicate dynamically with SSH itself
        telling it to forward the correct web server for each url the browser handles 

        do not need to specify destination socket 
        just the local port to be forwarded
        this is because the destination is determined dynamically 
        only the client needs to support dynamic forwarding in its configuration
    
    how this works:
        1. user types foo:1234 into the browser 
        2. the browser connects to the SSH SOCKS proxy on localhost:1080 and
        asks for the connection to foo:1234 using the SOCKS protocol
        3. in response the SSH client associates the browser's connection with a new 
        direct-tcpip channel in the existing SSH session
        4. SSH client and server get out of the way and the browser is connected to the desired web server
