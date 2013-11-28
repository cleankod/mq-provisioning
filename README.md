IBM WebSphere MQ provisioning
===============

Some shell scripts for provisioning WebSphere MQ. Works with Vagrant and Linux (Debian).

These provisioning scripts are going to:

1. Setup the virtual machine using Vagrant.
1. Install all required packages for Debian.
1. Install WebSphere MQ product (if it is not already installed).
1. Install a rc.d script to start MQ automatically during system boot.
1. Setup all environment for MQ to run.
1. Import all of the MQSC configuration files and run them, creating queue managers if necessary.
1. Start queue managers and their objects, required to connect to the queue manager.


## Prerequisites
### WebSphere MQ
In order to install the WebSphere MQ, you need to have the installation files from IBM. They are either provided by IBM or can be downloaded from their website as trial (90 days) version.

After acquiring the installation package, extract the following files:

1. MQSeriesRuntime
2. MQSeriesServer
3. MQSeriesSDK
4. MQSeriesClient
5. MQSeriesJava
6. MQSeriesSamples
7. MQSeriesMan

### MQ startup script
This script is a part of Support Pac.

## Setup
You need to provide the files:

1. MQ setup packages go to ```./install/```
1. MQSC configuration scripts go to: ```./mqsc/```
    * Each of the MQSC configuration files should contain a configuration of only one queue manager.
    * A queue manager is going to be created for each MQSC file. The name of the queue manager is going to be taken from the MQSC filename, without the extension (ABC001.mqsc will create a queue manager named ABC001).
1. In the ```./configure.sh``` file, remove the proxy variable init if you do not use one.
## Running
Go to the provisioning scripts directory and issue:

    vagrant up
