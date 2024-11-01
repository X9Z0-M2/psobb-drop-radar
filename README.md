## PSOBB Drop Radar Addon

Drop Radar will simplify shifting through piles of monomates, sol atomizers, and other useless drops by providing real-time directional indication to the valuable ones. 

_Some psobb clients may also have minimap dots for rare drops and even allow you to customize which drops show up. This adds on top of that with more intuitive right/left directions to item drops_

![alt text](./img/RadarDemo1.gif)

_Click Image to Watch_

_Note: for Phantasy Star Online: Blue Burst_

### Installation
* Recommended Process: [Semi-Automatic Updating](./docs/Semi-Automatic_Updating.md)

* Quick Install:
    1. Using standard git features you may clone, or choose to download as a .zip file.
        * Extract .zip

    2. Place "Drop Radar" folder inside the "addons" folder where all the other psobb addons are.
        * Note: all files; *init.lua*, *configuration.lua* must be inside "Drop Radar"
        * *options.lua* file should be created if you make a settings change to store them.
            * To use of the pre-configured huds rename that file to *options.lua*
            * i.e. rename `example1_options.lua` -> `options.lua`


### Configuration
This is straight-forward if you're at all used to other psobb lua addons utilizing imgui.
- Load up the game, and join or create a party to, and enter into an easy combat zone where you're not likely to die.
- Press ` (*backtick char*) to open addon menu, if it isn't already.
    - This is typically the same key as ~ (*tilde key*) on the keyboard, directly below esc (escape key).
- Click "Drop Radar" on the Main Menu to bring up the configuration menu.
- Double click the "Drop Radar - Configuration" window to expand it fully, if it isn't already.
- You'll now see all the various options and can adjust the hud size, position, and drop heights you'd like each type of drop to have. (*slide over to 0 to remove visibility*)

![alt text](./img/SettingsMenu3.gif)


---
### Sample Config Files

#### example1_options.lua

![alt text](./img/example1_options.gif)

*Note: Item Textbox NOT Included in the radar addon! For visibility purposes only!*

