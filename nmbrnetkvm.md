# Setting up a bridged network for KVM guests
This will work with either networkd or NetworkManager as a resolver. In fact, this is the _only_ way to do bridged KVM
(libvirtd) networking with NetworkManager.

If you're using NetworkManager (on a desktop or laptop, for example) on your KVM host, follow [these instructions](https://gist.github.com/plembo/f7abd2d9b6f76e7afdece02dae7e5097) to set up a bridge interface.

Once you have the host bridge set up, proceed as follows:

1. Create a bridge network device inside KVM. Edit and save the below text as file host-bridge.xml:
```xml
<network>
   <name>host-bridge</name>
   <forward mode="bridge"/>
   <bridge name="br0"/>
</network>
```
Then execute these commands (as a user in the libvirt group):

```bash
$ virsh net-define host-bridge.xml
$ virsh net-start host-bridge
$ virsh net-autostart host-bridge
```
2. Make it possible for hosts outside of KVM to talk to your bridged guest by making the following changes on the KVM host.

Load the br_netfilter module:
```bash
$ sudo modprobe br_netfilter
```

Persist on reboot by creating /etc/modules-load.d/br_netfilter.conf:
```bash
$ sudo echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf
```

Create /etc/sysctl.d/10-bridge.conf:
```bash
# Do not filter packets crossing a bridge
net.bridge.bridge-nf-call-ip6tables=0
net.bridge.bridge-nf-call-iptables=0
net.bridge.bridge-nf-call-arptables=0
```

Apply the config now:
```bash
$ sudo sysctl -p /etc/sysctl.d/10-bridge.conf
```

Check result:
```bash
$ sudo sysctl -a | grep "bridge-nf-call"
```

3. Configure the guest to use host-bridge.
Open up the Virtual Machine Manager and then select the target guest. Go to the NIC device. The drop down for
"Network Source" should now include a device called "Virtual netowrk 'host-bridge'". The "Bridge network device
model" will be "virtio" if that's your KVM configuration's default.

Select that "host-bridge" device.

If you inspect the guest's XML (by using ```virsh dumplxml guestname```), it shoud look something like this:

```xml
<interface type='network'>
   <mac address='52:54:8b:d9:bf:a2'/>
   <source network='host-bridge'/>
   <model type='virtio'/>
   <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
</interface>'
```
Be sure to save your changes!

4. Go up to your router and add a DHCP reservation and DNS mapping for the guest (assuming you want a dynamic address and
want to be able to easily find the guest later). Otherwise, be prepared to manually configure networking on the guest.

5. Start (or restart) the guest.