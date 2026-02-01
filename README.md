# RTLSDR Docker Image

## Supported Tags and Architectures

This RTLSDR image supports the following tags for various platforms, such as Linux, Raspberry Pi, Pine64, etc.:

- [`latest`](https://github.com/legacycode-docker/rtlsdr-docker/blob/latest/Dockerfile) 

This image supports the following architectures:

- `amd64` - For most desktop processors
- `armv7` - For 32-bit ARM images (e.g., Raspbian on Raspberry Pi 1, 2, 3, and 4)
- `arm64` - For 64-bit ARM images (e.g., Armbian on Pine64, etc.)
- `386` - For legacy desktop processors

## Tools Included

This Docker image contains a build of RTLSDR. The following programs are included:

- `rtl_adsb`
- `rtl_biast`
- `rtl_eeprom`
- `rtl_fm`
- `rtl_power`
- `rtl_sdr`
- `rtl_tcp`
- `rtl_test`

## Examples

You can run any RTLSDR command on your Docker host. To run the container in interactive mode, use the following command:

```shell
docker run -it --network host --device [YOUR_DVBT_DEVICE] legacycode/rtlsdr rtl_tcp -a [YOUR_HOST_IP] -p [YOUR_HOST_PORT]
```

If your Docker host is running on the IP address `192.168.0.1` and you want to use TCP port `1234` with your DVB-T stick at `/dev/bus/usb`, use the following command:

```shell
docker run -it --network host --device /dev/bus/usb legacycode/rtlsdr rtl_tcp -a 192.168.0.1 -p 1234
```

To listen on all interfaces (which allows connections from other machines), you can use `-a 0.0.0.0` in your command:

```shell
docker run -it --network host --device /dev/bus/usb legacycode/rtlsdr rtl_tcp -a 0.0.0.0 -p 1234
```

Docker Compose:

```yaml
services:
  rtlsdr:
    image: legacycode/rtlsdr  # The Docker image to use
    command: rtl_tcp -a 0.0.0.0 -p 1234  # The command to run inside the container
    network_mode: host  # Use the host network
    devices:
      - /dev/bus/usb  # Mount the USB device
    restart: unless-stopped  # Restart policy
```

After executing this command, use SDR# (SDRSharp) to connect to your Docker RTL_TCP server at IP `192.168.0.1` (or any reachable IP) and port `1234`.

## Troubleshooting

### "Kernel driver is active" Error

If you see this error when running the container:

```
Kernel driver is active, or device is claimed by second instance of librtlsdr.
In the first case, please either detach or blacklist the kernel module
(dvb_usb_rtl28xxu), or enable automatic detaching at compile time.

usb_claim_interface error -6
Failed to open rtlsdr device #0.
```

The Linux kernel automatically loads the `dvb_usb_rtl28xxu` driver (for DVB-T reception) when it detects your RTL-SDR device. This driver claims the USB device before librtlsdr can access it.

**Solution:** Blacklist the kernel driver on your **host system** (not inside the container).

1. Create a blacklist file:

   ```bash
   sudo tee /etc/modprobe.d/blacklist-rtlsdr.conf <<EOF
   blacklist dvb_usb_rtl28xxu
   blacklist rtl2832
   blacklist rtl2830
   EOF
   ```

2. Unload the driver (or reboot):

   ```bash
   sudo rmmod dvb_usb_rtl28xxu
   ```

3. Run the container again.

## Contribute

Feel free to contribute! You can find this project on [GitHub](https://github.com/legacycode-docker/rtlsdr-docker)!

## License Information

This [Dockerfile](https://github.com/legacycode-docker/rtlsdr-docker) is provided under the [MIT License](https://github.com/legacycode-docker/rtlsdr-docker/blob/latest/LICENSE.md).

License information about RTLSDR can be found in the [official repository](https://osmocom.org/projects/rtl-sdr/repository/revisions/master/entry/COPYING).

The Docker images are based on the [Debian Docker image](https://hub.docker.com/_/Debian). Refer to the official [Debian Docker image](https://hub.docker.com/_/Debian) page for license information.
