Minetest 0.4 Mod: Worldedit++
=============================
by PilzAdam

Descripton
----------
Worldedit++ adds commands to Minetest to easily set/modify thousands of nodes.
All commands require the "worldedit" privilege.
The commands are executed step by step, wich means that the server does not lag
at all if a Worldedit++ command is running. It is still 100% playable.
If a player starts a command it gets enqueued into the serverqueue, and it will
be started if the commands in front of it are finished. This makes it easy to
use on multiplayer servers.
Every player can only have one command at the same time, wich is either running,
waiting or paused. Position 1 & 2 and the selected node are also saved per
player. They can't be changed while a command is running, waiting or paused.
Currently supported commands are:
 - /wpp
    - no parameters
    - prints information about positions, nodes and commands
      of the player
 - /p#
    - optional parameter: <X>,<Y>,<Z>
    - # is either 1, 2 or 2
    - sets position # for the player to the player position or x,y,z if
      specified
 - /p#a
    - parameter: <X>,<Y>,<Z>
    - # is either 1, 2 or 2
    - adds given vector to position #
 - /p#p
    - no parameters
    - # is either 1, 2 or 2
    - sets position # to the next punched node by the player
    - call it again if you don't want to change it anymore
 - /select
    - optional param: nodename
    - sets the node for the player
    - uses wielditem if nodename isnt specified
 - /setarea
   - optional parameter: nodename
   - sets the region specified by position 1 & 2 to the the selected node
   - selects the wielditem if no node is selected
   - nodename will be selected if given
 - /stop
   - no parameters
   - stops the running command of the player or removes the command for the
     serverqueue
 - /pause
   - no parameters
   - pauses the running command of the player
 - /continue
   - no parameters
   - continues the paused command of the player
 - /replace
   - optional parameter: nodename or nodename nodename
   - replaces the given node with the selected node in the region specified by
     position 1 & 2
   - uses wielditem if nodename isnt specified
   - selects second nodename if given
 - /fixlight
   - no parameters
   - fixes light in the region specified by position 1 & 2 by digging air in it
   - NOTE: this might cause lag and take longer than the ETA printed at the
           beginning
 - /dig
   - no parameters
   - digs nodes in region specified by position 1 & 2
   - NOTE: this might cause lag and take longer than the ETA printed at the
           beginning
 - /marker
   - parameter: "on" or "off"
   - select whether markers at position 1 & 2 should be shown or not
 - /load
   - parameter: filename (without ".we" or ".wem" extention)
   - loads the nodes and places them in the world with position 1 as origin from
     <worlddirectory>/schems/<filename>.we, also tries <filename>.wem
   - currently only the latest version of the schemes from Worldedit is
     supported
 - /save
   - parameter: filename (without ".we" extention)
   - saves nodes in region specified by position 1 & 2 to
     <worlddirectory>/schems/<filename>.we
   - files can't be overwritten
   - NOTE: Writing the file might cause lag

License
-------
Sourcecode: WTFPL
Textures: WTFPL
