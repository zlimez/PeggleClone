# CS3217 Problem Set 2

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
- `GameWorldVM`
- `VisibleRigidBody`
- `Cannon`

#### `GameWorld`
`GameWorld` is powered by its `physicsWorld` property. `GameWorld` asks `physicsWorld` to resolve the physical states of all the physics enabled objects (`RigidBody`) in the world. `GameWorld` is the environment where all game objects interact, specifically the pegs, the cannon ball, and the invisible walls along the top, left and right boundaries of the world. `GameWorld` runs an event loop via `CADisplayLink`, and steps the world state forwards accordingly by the time slice advanced per loop iteration. After which, `GameWorld` askes the `renderAdaptor` in this case `GameBoardVM` to `adaptScene` such that the world state is translated to a format that can be consumed and rendered by the view (`GameView`).

In addition to stepping the `physicsWorld` forward in a loop iteration, `GameWorld` maintains a set of active coroutines that are also executed per loop iteration. Once a routine completes, it is removed from the `coroutines` set. One direct application of a `Coroutine` will be animations.

#### `VisibleRigidBody`
`VisibleRigidBody` inherits from `RigidBody` and includes a `SpriteContainer` property that contains information on how the body will be displayed -> `sprite`, sprite `width`, sprite `height` and sprite `opacity`. Subclasses of `VisibleRigidBody` include `PegRigidBody` and `CannonBall`.

`PegRigidBody` overrides the `RigidBody` lifecycle methods `onCollisionEnter` and `onCollisionStay` to enable peg lighting and peg removal after collision. It includes the additional property `Peg` which contains specifications of the peg being represented.

#### `Cannon`
`Cannon` is responsible for determining the initial velocity and launch location of the `CannonBall` when fired.

#### Supporting class and structs include:
- `RenderAdapter`: A protocol that demands its implementing classes to provide a method `adaptScene`
- `Wall`: A `RigidBody` subclass used to bound the play area
- `BallRecycler`: A `RigidBody` subclass serving as a trigger zone that destroys the `CannonBall` when it fall below the screen and asks the `GameWorld` to remove the pegs that were hit
- `Coroutine`: Takes in a routine function to be executed and a completion callback to be executed when the routine function completes after repeated invocation in the event loop.

### Peggle Game Display
#### `RigidBodyVM`
`RIgidBodyVM` adapts a `VisibleRigidBody` into a format compatible with `RigidBodyView`.

#### `GameBoardVM`
`GameBoardVM` lies between the view and the engine as stated above. It has a `@Published` property `bodyVMs` that is observed by `GameView`. `bodyVMs` is a collection of the `RigidBodyVM`.

## Design Tradeoffs
The first design tradeoff I faced was whether to implement the collection of rigidbodies in `PhysivsWorld` as an array or a set. By implementing as an array, it is easy to prevent duplicate collisions. Every body only checks collision against bodies after it in the array. However, body removal will be O(n). If implemented as a set, an auxiliary variable must be used to store all the body pairs checked to prevent collision AB and collision BA from both being registered. The benefit is the constant time body removal. Given that the number of pegs that can be fitted on screen is limited. I do not expect the linear time peg removal to stress the CPU hence I opted for the simpler but concise array approach,
