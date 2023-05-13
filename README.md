# Introduction

These Open Computers (OC) scripts will automatically tier-up, stat-up, and spread (duplicate) crops for you. Open Computers is a very powerful yet complicated mod using custom scripts written in lua, but fear not. I have made everything here as straight forward as possible to help you get your crop bot running in no time.

# Bare Minimum Components

Obtaining these components will require access to EV circuits and epoxid (late HV). This is because you need an internet card to pull the scripts from GitHub (it is possible to create all the files manually and then copy and paste the code from GitHub, but that is not recommended). The CPU and Graphics Card can be replaced by a single APU if you feel so inclined. Both inventory upgrades are necessary.

- OC Electronics Assembler
- OC Charger
- Tier 3 Computer Case
- Central Processing Unit (Tier 2)
- Graphics Card (Tier 1)
- Redstone Card (Tier 1)
- Memory (Tier 2)
- EEPROM (Lua BIOS)
- Hard Disk Drive (Tier 1, 1MB)
- Inventory Controller Upgrade
- Inventory Upgrade
- Screen (Tier 1)
- Keyboard
- Geolyzer
- Disk Drive
- Internet Card
- OpenOS (Operating System)

Lastly, you need a Transvector Binder and Transvector Dislocator which requires some progression in Thaumcraft. However, it is not too deep and completely doable if you are already able to make EV circuits and epoxid. Transvector Dislocator can be found under "Thaumic Tinkerer" and requires the following prerequisites on the same tab: Transvector Interface and Smokey Quartz. You will also need to complete research on Mirror Magic under "Artifice." For more information, visit https://gtnh.miraheze.org/wiki/Thaumcraft_Research_Cheatsheet.

# Building the Robot

1. Insert the computer case into the OC Electronics Assembler which can be powered directly by any GT cable
2. Shift-click all of the parts into the computer case except the OpenOS floppy disk
3. Click assemble and wait until it completes
4. Rename the robot in an anvil
5. Place the robot down on the OC Charger which can also be powered directly by any GT cable
6. Insert the OpenOS floppy disk in the disk slot of the robot and press the power button
7. Follow the commands on the screen "install" --> "Y" --> "Y" (Note: The OpenOS floppy disk is no longer needed in the robot afterwards)
8. Copy the following line of code into the robot (middle-click to paste) and hit enter

        wget https://raw.githubusercontent.com/DylanTaylor1/ic2-crop-automation/main/install.lua

9. Install the rest of the scripts by entering:

        ./install

10. Edit the config (not recommended, but check it out) by entering:

        edit config.lua

11. Place the Spade and Transvector Binder into the last and second to last slot of the robot, respectively. Crop sticks will go in the third, but it is not required to put them in yourself. An axe or mattock can also be placed into the tool slot of the robot (optional) to speed up destroying crops. See image below.

![Robot Inventory](media/Robot_Inventory.png?)

# Building the Farms

First off, it is recommended to set everything up in a Jungle or Swamp biome at Y=130 as that will give you the highest humidity and air quality stats. This is most easily done in a personal dimension which you earn as a quest reward from reaching the moon. Do not place any solid blocks above the farm as that will reduce the air quality. All of the machines on the surface are waterproof so do not worry about the rain. Use vanilla dirt because that will allow you to grow crops that require a particular block underneath, and boost the nutrient stat of your crops. The whole farm will fit into a single chunk for easy chunk loading. See image below.

![Farm Top](media/Farm_Top.png?)

First note the orientation of the robot sitting atop the OC charger. It must face up towards the right-most column of the working farm. If the crop stick chest is ever empty, the robot will run into errors and the script will crash. In the image, I have a trash can on the other side of the crop stick chest because I do not want any drops beyond the target crop, but this can be a second chest if you do want random drops. The blank farmland is for the transvector dislocator which should be facing it. You can tell which direction the transvector dislocator is facing by the side that is animated. The last spot is for a crop-matron which is optional and one y-level lower than the rest of the blocks. It is just to hydrate most of the crops to help them grow a little faster.

The location of the water MUST be exactly as seen in the photo (underneath all five sea lantern slabs). At a minimum, there MUST be a block above the water in the working farm. The block can be literally anything, even a lilypad will work, so long as there is something. However, I recommend using some sort of light source to help crops grow at night. Nothing needs to be above the water blocks on the storage farm, but it is more aesthetic if they all match.

The starting crops must be placed manually in the checkerboard pattern seen in the photo. This layout goes for all three programs. If you cannot fill the entire checkerboard to start, the absolute minimum required is two (one as the target crop and the other next to it for crossbreeding). It is not necessary to place empty crop sticks to fill the rest of the checkerboard. The target crop is used by autoStat and autoSpread to identify the crop you want to stat-up or spread to the storage farm, respectively.

![Farm Bottom](media/Farm_Bottom.png?)

Underneath the farm, you can see that there are three additional dirt blocks below each farmland, each of which add to the nutrient stat of the crop above it. For crops requiring a block underneath, that should be placed at the bottom. In this case, I have diareed planted on top which means I have one farmland --> two dirt --> one diamond block underneath each one. I do not have diamond blocks underneath the working farm because the diareed does not need to be fully grown in order to spread. For power, I am using an HV gas turbine and a super tank with some benzene (no transformer needed). This is a little overkill, but the important part is that the charger is always at 100% charging speed which you can see by hovering over it. A set-up such as this will last forever with a few hundred thousand benzene since both machines require very little EU/t. Lastly, a reservoir feeds water into the crop-matron automatically after right-clicking it with a wrench.

# Running the Programs

The first program is autoTier. This will automatically tier-up your crops, terminating once the max breeding round is reached (configurable) or the storage farm is full. A storage chest is recommended for this program. Note that unrecognized crops will be moved to the storage farm first before replacing any of the lower tier crops in the working farm. Statting-up crops during this program is a configurable option. To run, simply enter:

    autoTier

The second program is autoStat. This will automatically stat-up your crops, terminating once Gr + Ga - Re is at least 52 (configurable) for all crops on the working farm. A trash can is recommended for this program. Maximum growth and resistance are also configurable options which default to 21 and 2, respectively. To run, simply enter:

    autoStat

The third program is autoSpread. This will automatically spread (duplicate) your crops if each new Gr + Ga - Re is at least 46 (configurable), terminating once the storage farm is full. A trash can is recommended for this program. Maximum growth and resistance are also configurable options which default to 21 and 2, respectively. To run, simply enter:

    autoSpread

Fire and Forget. If you have brand new crops (ie. 1/1/1 spruce saplings) and want to automatically stat-up and start spreading:

    autoStat && autoSpread

## Other Helpful Commands

To list all of the files installed on the robot, enter

    ls

To remove any one file installed on the robot, enter

    rm <filename>

To uninstall all of the files from this repo, enter

    uninstall

## Recommended Crops

For starters, I recommend statting-up and spreading the following crops because their outputs are useful and not completely overshadowed by bees. Note that every crop has a higher chance of being discovered with specific parent combinations, but it is often easier to discover a crop from crossbreeding at the same tier. For example, diareed apparently has the highest chance of being discovered when the parents are oilberry and bobsyeruncleranks, BUT I recommend just running autoTier with all Tier 12 crops (or autoSpread with keepMutations on in the config). Crops that require a particular block underneath do not need to be fully grown in order to spread. For a full list of crops and their requirements, visit https://gtnh.miraheze.org/wiki/IC2_Crops_List.

- Stickreed for discovering other crops and sticky resin (rubber dust)
- Spruce Bonsai for all of your benzene and power needs
- Glowing Earth Coral for sunnarium and glowstone (gold and redstone)
- Sugarbeet for sugar (oxygen)
- Rape for seed oil
- Goldfish plant for fish oil
- Tearstalks for ghast tears (chlorine and sodium hydroxide)
- Enderbloom for enderpearls/endereyes
- Diareed for diamonds
- Bobsyeruncleranks for emeralds

## Thanks

My repo is a fork from https://github.com/huchenlei/auto-crossbreeding/tree/improve_autocrossbreed which was originally authored by huchenlei and improved by xyqyear. Huge props to them for getting this off the ground and allowing me to take it further.

## Notable Changes

If you are familiar with the older versions of this code then here are some notable changes that motivated me to develop this fork in the first place.

- Changed general layout to access chests more easily.
- Changed farm layout to facilitate running autoSpread immediately after autoStat.
- Added the option to use regular dirt instead of fertilized dirt for crops requiring a particular block underneath.
- Added configurable maximum growth and maximum resistance stats.
- Added configurable thresholds for autoSpread and autoStat.
- Added configurable option to stat-up crops while running autoTier.
- Added configurable option to cleanup after complete (no longer a flag).
- Added a built-in storage reset to prevent having to break the robot in order to run autoSpread or autoTier more than once.
- Added an uninstall script.
- Code is a LOT cleaner and more organized, just look at this README
- It is no longer the code's fault if any of the programs crash.

![Giant Sword](media/Giant_Sword.png?)