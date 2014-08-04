# Role classification and staging
Roles beyond Mafia and Villager have yet to be implemented, but the game engine is built to support these classes of roles by using a priority queue and sorting by the integer assignments of action priorities found in role class definitions. (*/roles*)

Roles belong to  one of 5 classes, in descending priority.

**Class A** Modifiers
* They add a modification, temporary or persistent, to another player.

**Class B** Protectors
* They protect another player from death or status effects. i.e. Doctors

**Class C** Aggressor
* They visit players and either kill, or apply negative effects.

**Class D** Investigator
* They collect data and generate reports after all previous classes have been resolved. i.e. Lookout

At night, actions are resolved in stages.

**Stage 1** Non-visit pre-effectors
* Actions that are left-over from the previous day.
* They resolve in the following order
    1. Effects from those that died previous day.
    2. Day actions that have effect on following night.
    3. Night actions that are non-visit but must occur before

**Stage 2** Visits
* Any action that visits another player. They are resolved based on their class priorities.
* If an effector is dead when their action is about to be resolved, their action does not resolve successfully.


**Stage 3** Non-visit post-effectors
* Any actions that do not visit another player, but have an effect at night that resolves after visit actions.
* These resolve simultaneously. This means that actions resolve regardless of whether another Stage 3 action affects it or not.


