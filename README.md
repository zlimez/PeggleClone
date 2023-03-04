# CS3217 Problem Set 4

**Name:** Chiu Chi Kuan

**Matric No:** A0234100E

## Developer Guide
### Physics Engine
The Physics Engine supports 2D objects only.

There are four main components in the Physics Engine:
- `Physics World`
- `Colliders`
- `RigidBody`
- `Solvers`

Other classes and structs include:
1. `Transform`: Defines the position, scale and z-axis rotation of a 2D object
2. `WorldObject`: Consists of a `Transform` property.
3. `Collision`: Consists of the `ContactPoints` of the collision and the two bodies involved in the collision
4. `Material`: Consists of only one attribute as for now, restitution, which affects the response of the body after a collision

#### `Physics World`
Physics world can be seen as the environment of which all physics enabled bodies run in. Environment wide effects such as gravity and drag are applied here. It maintains a collections of bodies (`RigidBody`). At every step, it checks for collision between the bodies, resolves the collision, and updates their position, velocity accordingly.

**Method**

`step(deltaTime)` - Forwards the state of the world by deltatime, applying gravity, drag, resolving collision and update each bodies' position in the time slice

#### `Colliders`
There are three types of colliders supported,
1. `CircleCollider` - Defined by a radius
2. `BoxCollider` - Defined by the half width and half height of the rectangle
3. `PolygonCollider` - Defined by the vertices of the polygon

A collider defines the physical outline of the object it is attached to. The main function of a collider object is to `testCollision` against another collider. Each concrete collider pair type, e.g. `CircleCollider` and `BoxCollider`, `PolygonCollider` and `PolygonCollider` runs an algorithm to determine if two collider objects have collided and if so return a `ContactPoints` object that contains the position of the contacts points, the normal and depth of the collision.

Collision detection that involves a `PolygonCollider` is based on the [Separation Axis Theorem](https://en.wikipedia.org/wiki/Hyperplane_separation_theorem). `BoxCollider` is considered a special case of `Polygon Collider`. The properties of a collider need not be changed when an object scales, rotates or transforms in any way. The collider bounds adjusts according to the `Transform` of the body it is attached to.

#### `RigidBody`
A `RigidBody` inherits from a `WorldObject` but is physics enabled through the following properties:
- `material`
- `velocity`
- `mass`
- `collider`

The top three properties translates to their real world counter parts. The collider defines the physical bounds of the body, enabling the `RigidBody` to react to collisions. The `velocity` of the `RigidBody` can be changed by applying force or impulse via `applyForce` and `applyImpulse` respectively.

A special property `isTrigger` converts the `RigidBody` from a solid impassable object to a trigger zone.

There are six lifecycle methods for `RigidBody`:
1. `onCollisionEnter`: Invoked when this body just collides with another body (both are solid bodies)
2. `onTriggerEnter`: Same as `onCollisionEnter` (Either one or both of the colliding bodies are trigger zones)
3. `onCollisionStay`: Invoked for the duration that the other colliding body have yet to separate (both are solid bodies)
4. `onTriggerStay`: Same as `onCollisionStay` (Either one or both of the colliding bodies are trigger zones)
5. `onCollisionExit`: Invoked when the other colliding body just separated from this body (both are solid bodies)
6. `onTriggerExit`: Same as `onTriggerExit` (Either one or both of the colliding bodies are trigger zones)

#### `Solvers`
`Solvers` are responsible for collision resolution. There are currently two solvers:
- `PositionSolver`: Separates the two colliding bodies by moving each by the least possible distance
- `ImpulseSolver`: Applies impulse of the two colliding `RigidBody` accounting for the momentum and material

### Peggle Game Engine
The peggle game engine is built atop of the Physics Engine with added utilities to support the Peggle gameplay. There are three core components in the peggle game engine:
- `GameWorld`
- `RenderAdaptor`
- `EventLoop`

#### `GameWorld`
`GameWorld` is powered by its `physicsWorld` property. `GameWorld` asks `physicsWorld` to resolve the physical states of all the physics enabled objects (`RigidBody`) in the world. `GameWorld` is the environment where all game objects interact, specifically the pegs, the cannon ball, and the invisible walls along the top, left and right boundaries of the world. 

**`Properties`**
- `pegRemovalTimeInterval`: The time threshold where a peg will be prematurely removed after prolonged contact with a `CannonBall` or `LoidPeg` (Zombie peg).
- `pegRemovalHitCount`: Once a peg has been hit by a `CannonBall` or `LoidPeg` for this number of times, it will be removed prematurely.
- `collidedPegBodies`: A `Set` of `NormalPeg` that have been hit during on peggle shot iteration, waiting to be faded then removed after the shot completes.
- `allPegBodies`: A `Set` of all pegs and blocks in the world. (Block is considered a peg, as there is no behaviour difference except the score which is actually handles externally via `GameModeAttachment`)`
- `graphicObjects`: All world objects that will be rendered onto the display.
- `gameModeAttachment`: A `GameModeAttachment` activates and deactivates selected properties such as `timer`, `ballCounter`, `civTally` etc. and configures a corresponding `ScoreSystem` and `WinLoseEvaluator` to support the game mode chosen by the player.
- `eventLoop`: The `EventLoop` that will advance the world state forward.
- `coroutines`: A `Set` of coroutine to be executed at every step that affects the world state.
- `playState`: The play state of the game, whether it is has been won, lost, in progress etc..
- `onStepComplete`: An `Array` of closures that take in a `Collection` of `WorldObjects` and process them accordingly.

**`Methods`**
- `step(deltaTime)`: Advances the state of the world by delta time, executing the `physicsWorld` update, coroutines in the `Coroutine` set, asking the `gameModeAttachment` to evaluate the world to check if the game has been won, lost or is still in progress.
- `addObject(WorldObject)`: Adds a `WorldObject` to the world. There are several overloaded methods with the same name but increasing specificity. Purpose is to add an object to all the data structures relevant to the components the object. For instance, if the gameobject is `Renderable`, the added object is inserted into the `graphicObjects` set.
- `startSimulation()`: Asks the `eventLoop` to start and advance the world forward.
- `tryFinalizeShot()`: Checks whether the next `CannonBall` can be fired (All collided pegs have faded and all ball-like objects have exited the screen)

`GameWorld` maintains the state of the world, including the bucket, the cannon ball and all the pegs on the board. Once a routine completes, it is removed from the `coroutines` set. One direct application of a `Coroutine` will be animations. `GameWorld` has a fixed dimension of `820 X 980`. To cater for different view dimensions the scaling is handled by `RenderAdaptor`.

#### `RenderAdaptor`
`RenderAdaptor` implements `GameSystem` and subscribes its `adaptScene` closure property to `onStepCompleted` closure array. The class is directly observed by the view, acting like a view model. `@Published` properties include `numOFBalls`, `prettyTimeLeft`, `civTally` etc.. As mentioned above, since the `GameWorld` is fixed size the `RenderAdaptor` determine a stretch ratio to fit the world onto the display area and applies these ratio onto `WorldObjectVM` via access from `graphicObjects` an array of `WorldObjectVM`.

`WorldObject` demands a `scaleFactor` used to stretch the position and scale of the `visibleObject`. The `scaleFactor` is assigned from `RenderAdaptor`.

#### Protocols
- `GameSystem`: Implementers must define the closure property `adaptScene(Collection<WorldObject>)`, processing the world objects accordingly.
- `Renderable`: Implementers have a `SpriteContainer` property to enable the UI to display the object.
- `Animated`: A protocol that extends `Renderable`. Contains a `spritesheet`, `animationSequences` and `frameRate`
- `Fadable`: A protocol that demands a `PegRB`. It has a closure `fade` that reduces the opacity of the peg object.
- `WinLoseEvaluator`: Implementers must specify the type of `ScoreSystem` associated with the evaluator and define the `evaluateGameState` function.
- `ScoreSystem`: Implementers register their responses to relevant game events that determines the score via `registerListeners`.
- `GameModeAttachment`: Couples a `ScoreSystem`, `WinLoseEvaluator` and `WorldConfig` object together defining a Game Mode e.g. _Operation Eden_. Implementers must define `setUpWorld` that sets the `GameWorld` to the state needed e.g. `ballCounter`, `civTally` is active while the `timer` is inactive in `GameWorld` for `Operation Strix` aka standard mode.
- `Audible`: Implementers must specify the property `audioClip`.

#### Pegs
`VisibleRigidBody` inherits `RigidBody` and implements `Renderable` defining objects that are physics enabled and displayable. `PegRB` is the parent of all pegs including blocks. It inherits `VisibleRigidBody` and possesses the function `makeFlipRotator` that returns a closure that can be wrapped into a `Coroutine` and added to `coroutines` in `GameWorld` to rotate the pegs by 180 degrees about the world center. _Note: Trivial properties and methods are omitted from the guide_.

- `NormalPeg`: A peg that is faded and removed if collided.
- `HostilePeg`: Inherits `NormalPeg` with the added property `captureReward` which could be captured by the `ScoreSystem` via events in `GameWorld`
- `CivilianPeg`: Inherits `NormalPeg` with the added property `deathPenalty` which could be captured by the `ScoreSystem` via events in `GameWorld`
- `LoidPeg`: Aka Zombie peg, when hit by a `CannonBall` turns into a pseudo cannon ball that could aid the player in clearing the hostile pegs
- `BoomPeg`: When hit by `CannonBall`, peg explodes and removes pegs in its collision radius immediately also applying an impulse onto any dynamic bodies in range.
- `ConfusePeg`: Inherits `ConfusePeg`. When hit by a `CannonBall` or dynamic `LoidPeg` would trigger `GameWorld` to rotate all static pegs and blocks by 180 degrees.
- `ChancePeg`: Implements `Fadable`. When hit has a probability of rewarding players a free ball. Once rewarded, the peg will fade.
- `BondPeg`: Aka Spooky peg. When hit by a `CannonBall` or dynamic `LoidPeg`, the peg will trigger `GameWorld` to shut the bucket and add a spook charge to the `CannonBall` which is consumed when ball exits the screen to allow the ball to reappear at the top of the screen continuing its trajectory.

#### `Cannon`
`Cannon` is responsible for determining the initial velocity and launch location of the `CannonBall` when fired. It implements `Animated` as it has a sprite progression for firing. To fire the cannon, player taps on the screen, cannon will rotate to point in that direction and fire the `CannonBall` provided the previous shot has been completed.

#### `PegMapper`
A final class that is not supposed to be instantiated. The class statically initializes the palette

#### A Bit More on Supported Game Modes
Standard game mode is titled _Operation Strix_. Objective of the player is to clear all the `Hostile pegs` namely the orange and green colored pegs without killing more than the heuristically computed number of civilians indicated at the bottom left corner of the screen. The game mode is supported by `CivilianScoreSystem` and `StandardEvaluator`.

![Simulator Screen Shot - iPad (10th generation) - 2023-03-05 at 01 44 42](https://user-images.githubusercontent.com/39835365/222921160-17245ae2-e43c-46eb-9ad3-412ea7d05bfd.png)

Beat high score mode is titled _Operation Eden_. There will be a countdown atop and a target score below. Objective is to reach the target score before the timer expires. The game mode is supported by `BaseScoreSystem` and `TimedHighScoreEvaluator`. Countdown start value and target score is again heuristically calculated.

![Simulator Screen Shot - iPad (10th generation) - 2023-03-05 at 01 45 01](https://user-images.githubusercontent.com/39835365/222921135-93ba93d6-6a98-439c-8dd8-2771eabc5400.png)

Siam mode is titled _Operation Gigi_. Players will specify the number of balls that they need to fire without hitting any peg on the screen. The game mode is supported by `NoScoreSystem` and `NoHitEvaluator`.

![Simulator Screen Shot - iPad (10th generation) - 2023-03-05 at 01 50 24](https://user-images.githubusercontent.com/39835365/222921215-224c5cae-b73e-4a51-aa3b-615753f79d2d.png)

Aside from the `ScoreSystem` and `WinLoseEvaluator`, the heuristic computation for the parameters of the first two game modes is done within `WorldConfig` via the closure property `configurer`.

`BaseScoreSystem` computes the score update by streak length and the pegs that have been hit per shot. The longer the "net streak" the higher the multiplier. Hitting civilian pegs deduct the score, and hitting hostile pegs increases the score based on the capture reward. Hence, a streak can magnify not only the plus but the minus as well if many civilians are killed by the shot.

#### Supporting class and structs include:
- `Bucket` oscillates at the bottom of the screen. If `isTrigger` is true and a `CannonBall` enters the bucket, the ball is "recycled" replenishing the ball count.
- `Wall`: A `RigidBody` subclass used to bound the play area
- `BallRecycler`: A `RigidBody` subclass serving as a trigger zone that destroys the `CannonBall` when it fall below the screen and asks the `GameWorld` to remove the pegs that were hit
- `Coroutine`: Takes in a routine function to be executed and a completion callback to be executed when the routine function completes after repeated invocation in the event loop.

### Peggle Game View
#### `GameView`
`GameView` can be entered from `BoardView` when the player clicks on the GO! button on `ControlPanelView`. `GameView` takes the board state from `BoardView` and delegates `renderAdaptor` to initialize the world state accordingly. Players can launch the cannon ball by tapping on the screen and a cannon ball will fire towards the direction, subject to the effects of gravity. `GameView` have several subviews and subview within subviews, but in essence there is the play area the top bar which hosts the timer and the ball count if either or both is required for the mode and the bottom bar which holds the civilian death tally, the target score and score stack to the right if either of them or some of them are needed.

![Simulator Screen Shot - iPad (10th generation) - 2023-03-05 at 01 44 42](https://user-images.githubusercontent.com/39835365/222921160-17245ae2-e43c-46eb-9ad3-412ea7d05bfd.png)

#### `ControlPanelView`
Similar to `GameView`, in essense `ControlPanelView` consists of a top bar, a board area where players can place the peg and a bottom bar. The top bar provides buttons for player to return to the main menu, load an existing level, save an existing level/ a new level (by the level name entered in the text field) or reset the board to an empty state. Since player can enter play mode from the level designer, there is also a picker under the text field that allows player to choose the game mode.

![Simulator Screen Shot - iPad (10th generation) - 2023-03-05 at 02 08 15](https://user-images.githubusercontent.com/39835365/222921917-6184fc5c-3459-4b9d-bfcb-5b07248f1cd3.png)

#### `MenuView`
The `MenuView` allows player to choose between going into the `SelectionView` to play a preloaded or previously designed level or going into the `BoardView` to design and possibly play a level.

![Simulator Screen Shot - iPad (10th generation) - 2023-03-05 at 02 08 20](https://user-images.githubusercontent.com/39835365/222921967-5fe66369-58c8-4ff5-b225-0ece47a3dfe9.png)

#### `SelectionView`
`SelectionView` contains rows of levels where player can select a mode from the picker and start playing by pressing the right arrow button at the end of the level row.

![Simulator Screen Shot - iPad (10th generation) - 2023-03-05 at 01 45 11](https://user-images.githubusercontent.com/39835365/222922005-6d766f87-c38f-499e-8712-c3d612fab8a5.png)

The bottom bar consists of a palette to the right, which is a collection of peg types along with a block the player can use to design a level, an information button to the right that hints at the behaviour of each peg type and a delete peg button at the right end that enables player to tap and delete any peg on the board.

### Audio
`TrackPlayer` is responsible for playing all the background music and SFX for the game. It merely provides two functions `playBGM(trackName)` and `playSFX(trackName)`. Only one bgm can be played at a time while up to 10 sfx tracks can be played on top of one another. More than that the sfx track will not be processed and emitted.

## Testing


