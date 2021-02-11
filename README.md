# Setup Docker for VPN

This shell script automates Docker setup to redirect traffic from containers through host's VPN. In order to access resources protected by VPN (e.g. Forti Сlient VPN) through Docker container, the latter must be set up properly. For example, this could be a Build Target in Aurora/Sailfish SDK's Build Engine that uses Docker as virtualization technology.

1. Check subnet mask for `docker0` interface:
    ```
    ip a
    ```
    If `inet 172.17.0.1/16` subnet mask is returned, follow the steps below.
2. Create `sudo vim /etc/docker/daemon.json` file and add the following config:
    ```
    {
        "bip": "172.17.0.1/24"
    }
    ```
3. Set `ACCEPT` policy for the `FORWARD` package redirection chain:
    ```
    sudo iptables --policy FORWARD ACCEPT
    ```
    **Warning**: this setting is preserver until the next system restart only, the default value for `FORWARD` package redirection chain policy is `DROP` (prohibit package redirection).
4. Stop `docker` service:
    ```
    sudo systemctl stop docker
    ```
5. Flush all chains for `nat` table:
    ```
    sudo iptables --table nat --flush
    ```
6. Install `bridge-utils` package if necessary:
    ```
    sudo apt install bridge-utils
    ```
6. Stop and remove `docker0` interface:
    ```
    sudo ifconfig docker0 down
    sudo brctl delbr docker0
    ```
7. Restart `docker` service:
    ```
    sudo systemctl restart docker
    ```
