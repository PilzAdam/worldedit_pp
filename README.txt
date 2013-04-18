Minetest 0.4 Mod: Worldedit++
=============================
by PilzAdam

Descripton
----------
Worldedit++ adds commands to Minetest to easily set thousands of nodes. Most of
them require the "worldedit" privilege.
The commands are executed step by step, wich means that the server does not lag
at all if a Worldedit++ command is running. It still 100% playable.
If a player starts a command it gets enqueued into the serverqueue, and it will
be started if the commands in front of it are executed. This makes it easy to
use on multiplayer servers.
Every player can only have one command at the same time, wich is either running,
waiting or paused. Position 1 & 2 and the selected are also saved per player.
Currently supported commands are:
 - /wpp:
    - no parameters
    - prints information about positions, nodes and commands
      of the player
 - /p1:
    - optional parameter: <X>,<Y>,<Z>
    - sets position 1 for the player to the player position or x,y,z if
      specified
 - /p2:
    - sets position 2 for the player
    - see /p1
 - /select
    - optional param: nodename
    - sets the node for the player
    - uses wielditem if nodename isnt specified
 - /set
   - no parameters
   - sets the region specified by position 1 & 2 to the the selected node
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
   - parameter: nodename
   - replaces the given node with the selected node in the region specified by
     position 1 & 2
 - /fixlight
   - no parameters
   - fixes light in the region specified by position 1 & 2 by digging air in it
   - NOTE: this might cause lag and take longer than the ETA printed at the
           start

License
-------
Sourcecode: WTFPL
