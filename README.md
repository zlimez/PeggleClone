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

#### Protocols
- `GameSystem`: Implementers must define the function `adaptScene(Collection<WorldObject>)`, processing the world objects accordingly.
- `Renderable`: Implementers have a `SpriteContainer` property to enable the UI to display the object.
- `Animated`: A protocol that extends `Renderable`. Contains a `spritesheet`, `animationSequences` and `frameRate`
- `Fadable`: A protocol that demands a `PegRB`. It has a closure `fade` that reduces the opacity of the peg object.
- `WinLoseEvaluator`: Implementers must specify the type of `ScoreSystem` associated with the evaluator and define the `evaluateGameState` function.
- `ScoreSystem`: Implementers register their responses to relevant game events that determines the score via `registerListeners`.
- `GameModeAttachment`: Couples a `ScoreSystem`, `WinLoseEvaluator` and `WorldConfig` object together defining a Game Mode e.g. _Operation Eden_. Implementers must define `setUpWorld` that sets the `GameWorld` to the state needed e.g. `ballCounter`, `civTally` is active while the `timer` is inactive in `GameWorld` for `Operation Strix` aka standard mode.

#### Pegs
`VisibleRigidBody` inherits from `RigidBody` and implements `Renderable` defining objects in the world that are physics enabled and can be display on the UI. `PegRB` is the parent of all pegs including block. It inherits from `VisibleRigidBody`

`PegRB` overrides the `RigidBody` lifecycle methods `onCollisionEnter` and `onCollisionStay` to enable peg lighting and peg removal after collision. It includes the additional property `Peg` which contains specifications of the peg being represented.

#### `Cannon`
`Cannon` is responsible for determining the initial velocity and launch location of the `CannonBall` when fired.

#### Supporting class and structs include:
- `Wall`: A `RigidBody` subclass used to bound the play area
- `BallRecycler`: A `RigidBody` subclass serving as a trigger zone that destroys the `CannonBall` when it fall below the screen and asks the `GameWorld` to remove the pegs that were hit
- `Coroutine`: Takes in a routine function to be executed and a completion callback to be executed when the routine function completes after repeated invocation in the event loop.

### Peggle Game View Model
#### `RigidBodyVM`
`RIgidBodyVM` adapts a `VisibleRigidBody` into a format compatible with `RigidBodyView`.

#### `RenderAdaptor`
**Properties**
- graphic
When player selects a new board to play, `GameBoardVM` asks `GameWorld` to reinitialize the world state with the new peg layout.

### Peggle Game View
#### `GameView`
`GameView` can be entered from `BoardView` when the player clicks on the START button on `ControlPanelView`. `GameView` takes the board state from `BoardView` and delegates `GameBoardVM` to initialize the world state accordingly. `GameView` has a subview `CannonView` that is currently static. Players can launch the cannon ball by tapping on the screen and a cannon ball will fire towards the direction, subject to the effects of gravity.


## Testing
### Unit Test


### Integration Test

