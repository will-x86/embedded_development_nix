# 🛠 Embedded Dev with Nix, Neovim, and Flakes

> **Purpose**: Code, flash, and debug embedded projects *without spending hours configuring nix* (love you nix)


---

## 📚 Contents

1. [Global Config & Permissions](#global-config--permissions)
2. [ESP-IDF (ESP32)](#esp-idf-esp32)
3. [PlatformIO (ESP32S3)](#platformio-esp32s3)
4. [Arduino Plugin + Boards](#arduino-plugin--boards)
5. [Adafruit Feather RP2040 (USB Host)](#adafruit-feather-rp2040-usb-host)

# Groups and non-flake settings:

My configuration.nix has:

```
    udev.packages = [
      pkgs.platformio-core
      pkgs.platformio-core.udev
    ];
```

I also am in the "dialout" group:

```
  users.users.will.extraGroups = [
    "dialout" # home-manager
  ];
```

# ESP-IDF

Usage:

```
idf.py create-project "esp-idf"
```

Atm I have a permission issue, to fix this I do:

```
sudo chmod 755 "esp-idf"
```

```
cd "esp-idf"
```

For testing I like to change "esp-idf/main/main.c" to:

```c
#include <stdio.h>

void app_main(void)
{
    printf("hello world\n");
}
```

To set the esp target, run:

```
idf.py set-target esp32s3
```

Change to your specific esp-32 though obviously

### Build:

```
idf.py build
```

### Flash:

```
idf.py flash
```

### Monitor:

_Cannot flash whilst monitor is open, use Ctrl+] to close_

```
idf.py monitor
```

Should get a result like:

```

I (226) spi_flash: detected chip: gd
I (228) spi_flash: flash io: dio
W (231) spi_flash: Detected size(8192k) larger than the size in the binary image header(2048k). Using the size in the binary image header.
I (243) sleep_gpio: Configure to isolate all GPIO pins in sleep state
I (249) sleep_gpio: Enable automatic switching of GPIO sleep configuration
I (256) main_task: Started on CPU0
I (266) main_task: Calling app_main()
hello world
I (266) main_task: Returned from app_main()
```

# Platform IO ( esp32s3 )

I personally use this extension:

```
https://github.com/anurag3301/nvim-platformio.lua
```

So my steps are a little different, but you will do:

Seach for board via:

```
pio boards | grep esp32s3
```

```
mkdir "pio-esp32s3"
cd "pio-esp32s3"
pio project init -b "seeed_xiao_esp32s3" --ide vim --sample-code --project-dir "pio-esp32s3"
```

Run via:

```
pio run --target upload
```

If you get static binary error, please ensure "platformio-core" is _not_ installed

Fix neovim errors via:

```
pio run -t compiledb
```

Though this personally doesn't work for all of them for me...

# below is broken

So we do:
add this line to pio-esp32s3/platformio.ini

```
extra_scripts = pre:extra_script.py

```

Then add to pio-esp32s3/extra-script.py:

```
import os
Import("env")

# include toolchain paths
env.Replace(COMPILATIONDB_INCLUDE_TOOLCHAIN=True)

# override compilation DB path
env.Replace(COMPILATIONDB_PATH="compile_commands.json")
```

# Arduino plugin

If you go into arduino_uno you'll see there's a uno file, but the CLI is a bit of a ballache to use

So I'm using:
[This plugin](https://github.com/yuukiflow/Arduino-Nvim/)
You'll see there's a few requirements, the djjson, lsp, etcetc.

~~I won't go into too much detail, but set it up as the repo says, and set arduino_language_server up like this: ( at least for me ) ~~


~~```lua~~
~~ lspconfig.arduino_language_server.setup({~~
~~ capabilities = capabilities,~~
~~ on_attach = on_attach,~~
~~ })~~
~~```~~

Originally I used this code:

```nix
let
  arduino-nvim = pkgs.fetchFromGitHub {
    owner = "yuukiflow";
    repo = "arduino-nvim";
    rev = "main";
    sha256 = "sha256-WTFbo5swtyAjLBOk9UciQCiBKOjkbwLStZMO/0uaZYg=";
  };
in
.....
    ".config/nvim/lua/Arduino-Nvim" = {
      source = arduino-nvim;
      recursive = true;
    };
```

This doesn't work as the plugin has hardcoded this:

```lua
        cmd = {
            "arduino-language-server",
            "-cli", "arduino-cli",
            "-cli-config", "$HOME/.arduino15/arduino-cli.yaml",
            "-clangd", "/usr/bin/clangd",
            "-fqbn", board,
        },
```

So I ended up cloning the repo for my home manager config, then decided to delete the .git file ( as lovely jubbly home manager doesn't want to source git repos)
Then changed the lsp.lua file where the require....arduino_langage_server.setup.. is to:

```lua
        cmd = {
            "arduino-language-server",
            "-cli", "arduino-cli",
            "-cli-config", "$HOME/.arduino15/arduino-cli.yaml",
            "-clangd",
		    vim.fn.exepath("clangd"),
            "-fqbn", board,
        },
```

This reason being, is this hard-coded clangd path meant the lsp was failing - see my [Dotfiles](https://github.com/will-x86/nixos-dotfiles) if you wanna

MAKE SURE to delete the .git and if you did a git add to your hmoe manager repo, do a git rm --cached -r PATH TO ARDUINO-NVIM
If the repo is a submodule, it will not be moved by home manager

I ran some commands to initialise as I got an error:
( Though the first two are done via the flake now :) )

```
arduino-cli config init
arduino-cli core update-index
arduino-cli core install arduino:avr
```

View the bindings for this library on the github repo [Here](https://github.com/yuukiflow/Arduino-Nvim/blob/main/remap.lua)

Now that that's working we'll move onto the adafruit one :)

# Adafruit feather rp2040 usb-a host thing ( using arduino )

I had many issues with platform IO as it doesn't technically support RP2040, you have to use some other core for it, so arduino is much easier

I'll be using this cheat sheet:
https://www.woolseyworkshop.com/2019/04/14/arduino-command-line-cheatsheet/
And this guide for the usb pasthrough-ness:
https://learn.adafruit.com/adafruit-feather-rp2040-with-usb-type-a-host/usb-host-device-info

```
mkdir adafruit_rp2040                                                                                          main     
cd adafruit_rp2040
```

```

arduino-cli lib search "Adafruit TinyUSB"                                                                                                                                                                                                                    main     
Name: "Adafruit TinyUSB Library"
  Author: Adafruit
  Maintainer: Adafruit <info@adafruit.com>
  Sentence: TinyUSB library for Arduino
......... Etc etc 
```


Install via:
```
arduino-cli lib install "Adafruit TinyUSB Library"@2.1.0                                                                                                                                                                                                     main     
```

Same again, search for pio USB:
```
arduino-cli lib search "Pio USB"                                                                                      main     
Name: "Pico PIO USB"
  Author: sekigon-gonnoc
  ... etcet c
```

Install:
```
arduino-cli lib install "Pico PIO USB"                                                                                      main     
```

Then I ran a uh:
```
arduino-cli lib upgrade
```


Now gotta select the board, I had to install the board manager for RP2040 etc via: ( https://learn.adafruit.com/adafruit-feather-rp2040-with-usb-type-a-host/arduino-ide-setup ) 
```
arduino-cli config add board_manager.additional_urls https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
```

Then run:
```
arduino-cli core update-index                                                                                         main     

Downloading index: package_index.tar.bz2 downloaded
Downloading index: package_adafruit_index.json downloaded
Downloading index: package_rp2040_index.json downloaded
Downloading index: package_index.tar.bz2 dow
```

I also did a cheeky:
```
arduino-cli core install rp2040:rp2040                                                                               
```

Then after we list our boards via:
```
 arduino-cli board listall  | grep adafruit
 ```

We can find the:
 Adafruit Feather RP2040 USB Host     rp2040:rp2040:adafruit_feather_usb_host

Now, via neovim we press <Leader>ab and search for our board, once that's done, our board should be selected!

I tried to compile but had some issues, so I added this to the flake.nix:
```
libudev-zero
export LD_LIBRARY_PATH="${pkgs.libudev-zero}/lib:${pkgs.systemd}/lib:$LD_LIBRARY_PATH"
```

( It's already in there, no need for you to do it ) 


I also added picotool to the flake.nix here, but that's alr done 

I made the makefile in adafruit_rp2040/Makefile as the built in cmopiler and builder for the neovim plugin doesn't allow for our custom usbstack compile command we have

make upload and make compile work!
MUST BE IN BOOTLOADER MODE
```
embedded_development_nix/adafruit_rp2040 ❯ make upload                                                                                                          main     
arduino-cli upload --fqbn rp2040:rp2040:adafruit_feather_usb_host:freq=120,usbstack=tinyusb .
Resetting /dev/ttyACM0
Converting to uf2, output size: 119296, start address: 0x2000
Scanning for RP2040 devices
Flashing /run/media/will/RPI-RP2 (RPI-RP2)
Wrote 119296 bytes to /run/media/will/RPI-RP2/NEW.UF2
Flashing /var/run/media/will/RPI-RP2 (RPI-RP2)
Wrote 119296 bytes to /var/run/media/will/RPI-RP2/NEW.UF2
New upload port: /dev/ttyACM0 (serial)
```

At this point I copied the example code, then went to the git repo to get usbh_helper.h and compiled again ( via `make compile` and `make upload` ) 

IT WORKED. 
```
ashing /run/media/will/RPI-RP2 (RPI-RP2)
Wrote 223744 bytes to /run/media/will/RPI-RP2/NEW.UF2
Flashing /var/run/media/will/RPI-RP2 (RPI-RP2)
Wrote 223744 bytes to /var/run/media/will/RPI-RP2/NEW.UF2
New upload port: /dev/ttyACM0 (serial)
```

After a cheeky monitor command and plugging in my keyboard:
```

embedded_development_nix/adafruit_rp2040 ❯ arduino-cli monitor                                                                                                  main     
Using default monitor configuration for board: rp2040:rp2040:adafruit_feather_usb_host
Monitor port settings:
  baudrate=9600
  bits=8
  dtr=on
  parity=none
  rts=on
  stop_bits=1

Connecting to /dev/ttyACM0. Press CTRL-C to exit.
Device removed, address = 1
No device connected (except hub)
Device attached, address = 1
Device 1: ID 0d62:910e
Device Descriptor:
  bLength             18
  bDescriptorType     1
  bcdUSB              0200
  bDeviceClass        0
  bDeviceSubClass     0
  bDeviceProtocol     0
  bMaxPacketSize0     8
  idVendor            0x0d62
  idProduct           0x910e
  bcdDevice           3302
  iManufacturer       0
  iProduct            2     HP USB Business Slim Keyboard
  iSerialNumber       0
  bNumConfigurations  1
Device 1: ID 0d62:910e  HP USB Business Slim Keyboard
```
SHE WORKS !!!! 

