# Purpose of this project

To code, flash, etc embedded projects without having to spend hours configuring nix ( love you nix )

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
