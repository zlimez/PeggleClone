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
_Note: For Operation Strix, there must be at least one orange or green peg in the level (hostile peg) for meaningul gameplay._

### Rotation and Scaling
1. Layout several pegs and blocks in the level designer at least one of each type.
2. Tap on a peg, a scaling and rotation panel should appear below.
3. If the peg is circular, the panel should have radius and rotation sliders.
4. If the peg is non-circular, the panel should have width, height and rotation sliders.
5. Move the rotation slider, the peg should rotate accordingly.
6. Move the radius/width/height slider, the peg/block should scale accordingly.
7. If radius/width/height/rotation stops reacting to their sliders, the peg should be colliding with the board boundaries or other pegs.
8. Repeat 2-7 for each peg type.
9. Save the board under "Slider test"
10. Reset the board.
11. Load "Slider test", the board should reappear.
12. Press Start, the game board should match the design board.
13. Fire cannon balls at the transformed pegs, the collision response should match the graphics.

### Peg variants + Cannon ball
**Boom Peg**

<img src="https://user-images.githubusercontent.com/39835365/223088562-72727087-2dee-44ed-ab53-7836183ee243.png" height="80" width="80">

**Loid Peg (aka zombie peg)**

<img src="https://user-images.githubusercontent.com/39835365/223155768-e97e0abb-183b-4674-bf51-2521dc87d076.png" height="80" width="80">

**Bond Peg (aka spooky peg)**

<img src="https://user-images.githubusercontent.com/39835365/223155804-909ade16-3d24-4b7f-bfbb-19b234457daf.png" height="80" width="80">

**Franky Peg (aka chance peg)**

<img src="https://user-images.githubusercontent.com/39835365/223155827-addd22b4-fd7c-4178-8580-49352a702b33.jpg" height="80" width="80">

**Cannon Ball**

<img src="https://user-images.githubusercontent.com/39835365/223155862-5176ba95-57f0-42f8-976f-c785ae1733ed.png" height="80" width="80">

**Confuse Peg**

<img src="https://user-images.githubusercontent.com/39835365/223156093-f161dbec-3ae8-4a29-837b-9f4e7f43b4c9.png" height="80" width="80">

1. Layout some blue pegs, along with orange and green pegs.
2. Fire the cannon at the blue pegs.
3. Upon first collision with a cannon ball or dynamic loid peg the blue peg should light up.
4. Upon second collision with a cannon ball or dynamic loid peg the blue peg should turn grey.
5. If in _Operation Strix_ game mode, the civilian death tally at the bottom left corner of the play screen should increment by one.
6. When the ball and all dynamic loid pegs exit the screen, the greyed pegs should fade and be removed.

1. Layout a boom peg, near another orange, green, blue or spooky peg, and near another boom peg.
2. Have at least one orange peg on the board such that you can Start playing the level in _Operation Strix_ game mode.
3. Fire the cannon ball at the boom peg/pegs. The boom peg should explode. The explosion raius visually should be 5 times of that of the boom peg in question.
4. If another boom peg is caught in the explosion, it should explode too triggering a chain reaction of sort.
5. If any orange, green, blue or bond peg is caught in the explosion. They should fade immediately.
6. If a dynamic loid peg or cannon ball is caught in the explosion, their trajectory should be affected realistically by an impulse.
7. Back to step 1, scale the boom peg the explosion radius should scale accordingly for steps 4-6.
8. If _Operation Strix_ or _Operation Eden_ is chosen, the score line of the pegs should reflect the civilian and hostile pegs removed.
9. If _Operation Gigi__ is chosen, hitting the boom peg should result in game loss.
10. _Note: Multiple boom peg explosions successively can accelerate dynamic bodies such as loid peg and cannon ball to a speed that collision detection fails for object below a threshold size_

1. Layout two or more bond pegs, along with other pegs of your choice.
2. Press Start, fire the cannon ball at the bond pegs.
3. Upon any collision, you should hear a dog bark sfx being played.
4. Upon collision with the cannon ball, the bond peg sprite should change.
5. If the ball hits the bucket before exiting the screen, the bucket should act like a solid body instead of a trigger causing the ball to bounce off.
6. When the ball exits the screen, the collided pegs should not fade just yet.
7. The ball should reappear at the top of the screen at the same x-axis position.
8. Each collision with a different bond peg will grant the ball an extra "charge" for it to reappear. Each time the ball exits the screen, one of these charges is consumed.
9. Before the "charge" of the ball reaches 0, steps 4-6 should repeat. 
10. When all charges are expended and the ball exits the screen, all collided pegs accumulated through iterations should fade and be removed,
11. The scoreline if present should not be affected directly by collision with bond peg.
12. If _Operation Gigi__ is chosen, hitting the bond peg should result in game loss.

1. Layout two or more loid pegs, along with other pegs of your choice.
2. Press Start, fire the cannon ball at the loid pegs.
3. Upon collision with a cannon ball or another dynamic loid peg, the original static loid peg should become dynamic affected by gravity and the impulse from the initial impact.
4. If a loid peg collides with a hostile or civilian peg, the hostile and civilian pegs should react identically to how they react to a cannon ball.
5. A loid peg should rebound more drastically than a cannon ball upon collision.
6. Collided pegs should only fade and be removed once cannon ball (charges expended) and all dynamic loid pegs exit the screen.
7. The scoreline if presented should react to a collision between loid peg and another the same way it reacts to cannon ball and another.
8. If _Operation Gigi__ is chosen, hitting the loid peg should result in game loss.

1. Layout two or more Franky pegs, along with other pegs of your choice.
2. Press Start, fire the cannon ball at the franky pegs.
3. There is a 1/3 chance that a franky peg will react to a collision with a loid peg or cannon ball
4. The peg sprite should change followed by fade and removal if a reaction is triggered.
5. A reaction should grant you a free ball.
6. The scoreline if present should not be affected directly by collision with franky peg.
7. If _Operation Gigi__ is chosen, hitting the bond peg should result in game loss.

1. Layout two or more confuse pegs, along with other pegs of your choice.
2. Press Start, fire the cannon ball at the confuse pegs.
3. Upon collision with a loid peg, the board should rotate by 180 degrees.
4. Multiple collisions with a confuse peg within the same cannon shot would not trigger further flipping.
5. Across different shots, however, collision with confuse pegs should trigger board flip.
6. The confuse peg should fade and be removed once cannon ball and all dynamic loid pegs exit the screen.
7. 6. The scoreline if present should not be affected directly by collision with confuse peg.
8. If _Operation Gigi__ is chosen, hitting the bond peg should result in game loss.

### Game Mode
1. Head to level designer, tap on the picker _Operation Strix_, a drop down an additional two options _Operation Eden_ and _Operation Gigi_ should be visible.
2. Select _Operation Gigi_, a subview should appear that allows you to adjust the number of balls.
3. Repeat 1-2 at level selection view.

1. Either via one of the levels in selection view or from level designer, select _Operation Strix_ and press Start.
2. Play the game. There should be a ball count on the top right corner, a tombstone icon indicating the number of civilian death over allowed civilian death at the bottom left corner and a score at the bottom right corner.
3. Hitting a blue more than twice should case civiliam death tally to increase by one.
4. Score update should occur after every cannon shot completes. Orange peg rewards 150 base points, green peg rewards 500 base points, blue peg deducts 150. Actual change in score should be amplified for a longer net streak.
5. If civilian death exceeds the allowed death, a game loss pop up should emerge.
6. If ballcount reaches 0 and not all orange and green pegs are cleared, a game loss pop up should emerge.
7. If all green and blue pegs are cleared before ball count reaches 0 and the 5 is not violated, a game win pop up with your final score should emerge.
8. Repeat steps 1-7 with a drastically different board layout, the allowed civilian death and number of balls given should change sensibly.

1. Either via one of the levels in selection view or from level designer, select _Operation Eden_ and press Start.
2. Play the game. There should timer in the middle of the top bar counting down. There should be a target score and score at the bottom right corner.
3. Score calculation should be identical to that of _Operation Strix_.
4. If the target score is reached before the timer expires, a game won popup with your score should emerge.
5. If 4 never evaluates to true by the time the timer expires the game lost popup with your score should emerge.
6. Repeat steps 1-5 with a drastically different board layout, the timer start time and target score should change sensibly.

1. Either via one of the levels in selection view or from level designer, select _Operation Gigi_.
2. Provide the number of balls to clear.
3. The moment the ball collides with a peg excluding blocks, a game lost popup should appear.
4. If all balls are cleared without hitting a peg excluding blocks, a game won popup should appear.
5. Repeat steps 1-4 with different ball count input, the same criteria should apply.

### Level Saving and Pre-Loaded Levels
1. There should be three pre-loaded levels arranged in no particular order: "Orphanage", "Assassin?!" and "Find Gigi" available at the level selection view.
2. Go to level designer, layout a board of pegs save it under "Befriend Damien".
3. Head to the selection view, "Befriend Damien" should be added to the list of available levels.
4. Play "Befriend Damien" in any game mode, the game board should match that of the design.
5. Load one of the pre-loaded levels into level designer, adjust the peg and block layout.
6. Go to selection view, start the pre-loaded level you just changed, the changes should be reflected.
7. Exit the app, clear the window.
8. Start the app again, and head to selection view and start the pre-loaded level you changed again, the changes should remain.

1. Try the pre-loaded levels across various devices, the game area should be appropriately letter boxed.
2. Each peg should be scaled without distortion and preserve the same relative layout.

## Reflection
There were some shortcomings of my previous design. First, after the feedback from ps3, I realized none of my game specific classes should have inherited rigidbody cause that results in tight coupling of the game engine and physics engine. Although it did not impede my development, it does present concerns on the independence of my peggle game engine. Secondly, I did not abstract out the concept of shapes for peg in PS2. Then I limited pegs to circular objects. As such, to accomodate for triangles and blocks I had to remove the concept of radius from the peg and add a wrapper around peg consisting of a shaped collider for level designer to support collision detection Lastly, related to the first point if I have decoupled my game objects away from rigidbody, I will likely have a mapper that translate collision between two rigidobjects in the physics world to one between peggle game objects. This would allow me to create a custom parent classes for peggle game objects. As such I can add in support to group gameobjects under another gameobject recursively, which would make confuse peg implementation alot neater by simply rotating a parent gameobject of all pegs on the board.

The technical debt I had to clean up was to move event loop out of the peggle game engine which increasingly looks like a God class through my development. In addition, related to my second point in the paragraph above, I had to tweak my model and move the concept of shape elsewhere.

If I get to redo the application, first and foremost I will have opted into POP a lot earlier. Towards the end as there were more and more variants that shared behaviours yet does not conform completely to a sense of hierarchy, the overriding implementation becomes nasty. Though I did made an effort to refactor some bits into protocols such `Fadable`, `Animated` more could be done. 
