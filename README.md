# BundleLoader

**BundleLoader** is designed to be used as a submodule within your own mod. To add it to your project, follow these steps:

1. Add the BundleLoader submodule to your project by running the following command:

```sh
git submodule add https://github.com/FlashHit/BundleLoader.git ./ext/Shared/submodules/BundleLoader
```

2. Organize your project structure as follows to make the most of this mod:

```
-   Shared
	-   BundleConfig
		-   GameModes
			-   YourGameMode.lua
		-   Levels
			-   YourLevel
				-   YourGameMode.lua
			-   YourLevel.lua
		-   Common.lua
```

Let's explore this structure in more detail. This setup supports four different types of bundle configurations:

-   **Common:** For applying the same configuration to all levels.
-   **Per Level:** For customizing configurations for specific levels.
-   **Per GameMode:** For applying configurations to all levels within a specific game mode.
-   **Per Level + GameMode:** For specifying unique configurations for a level within a specific game mode.

Here's how to decide which configuration to use:

-   Use `Common.lua` if you want the same configuration for every level.
-   Utilize the `GameModes` folder for the same configuration across all levels within a specific game mode.
-   For the same configuration across all game modes for a specific level, use the `Levels` folder and create a file with the level's name.
-   To set up a specific configuration for a level with a particular game mode, use the `Levels/YourLevel/YourGameMode.lua` structure.

The best part is that none of these files are mandatory. Everything is handled automatically, and you can mix and match these configurations as needed.

## BundleConfig Structure

A `BundleConfig` should have the following structure:

```
{
	terrainAssetName: string,  // The name of the terrain you want to use (Available for per Level and per Level + GameMode).
	superBundles: {}  // A table of superbundles passed as strings.
	bundles: {
		<Compartment>: {}  // A table of bundles passed as strings for each compartment to modify.
	}
	uiBundles: {
		<UiBundleType>: {}  // A table of UI bundles passed as strings. All UI bundles are in compartment 1.
	}
	registries: {
		<Compartment>: {}  // A table of strings with the partition name (usually the same as the bundle name) to add to their respective compartments.
	}
	exceptionLevelList: {}  // A table of strings containing levels that this config should not be applied (Available for per GameMode).
	exceptionGameModeList: {}  // A table of strings containing game modes that this config should not be applied (Available for per Level).
}
```

Here's the list of UiBundleTypes:

```lua
UiBundleTypes = {
	Unknown = 0,
	Loading = 1,
	Playing = 2,
	PreEndOfRound = 3,
	EndOfRound = 4
}
```

## Loading Different Bundles for One Level and Multiple Game Modes

If you want to use different bundles, which are located within the game compartment, for a single level and across multiple game modes, you need to add the following code into your mod:

```lua
ResourceManager:AlwaysClearGameCompartment(true)
```

This code ensures that your bundles are loaded consistently, even when switching game modes without changing the level.

## Last additional notes

This submodule also supports the submodule "LoggingClass," though it's not required. If you are not using it but want to enable Debug mode, you need to set the global variable `DEBUG` to `true`. This can be helpful for debugging and troubleshooting your project with BundleLoader.

Feel free to reach out if you have any further questions or need assistance with using BundleLoader in your project.
