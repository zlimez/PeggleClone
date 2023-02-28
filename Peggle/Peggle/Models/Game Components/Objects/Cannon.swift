//
//  Cannon.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

class Cannon: WorldObject, Animated {
    let idleSprite = "cannon-static"
    var spriteSheet = ["cannon-static", "cannon-fire"]
    var animateSequences = ["fire": [0, 1]]
    var frameRate: Float = 12

    var spriteContainer = SpriteContainer(sprite: "cannon-static", unitWidth: 150, unitHeight: 150)

    var x: CGFloat { transform.position.x }
    var y: CGFloat { transform.position.y }
    var spriteOpacity: CGFloat { spriteContainer.opacity }
    var spriteWidth: CGFloat { transform.scale.x * spriteContainer.unitWidth }
    var spriteHeight: CGFloat { transform.scale.y * spriteContainer.unitHeight }
    var rotation: CGFloat { transform.rotation }

    let cannonSpeed: CGFloat
    // In radians
    let rotationSpeed: CGFloat
    // Relative to cannon position facing downwards
    let spawnOffset: CGFloat
    var onCannonFired: [(CannonBall) -> Void] = []
    var cannonReady = true
    // ranges from -pi to pi
    private var targetAim = Vector2.zero
    private static let acceptableRotationMargin: CGFloat = 0.001

    init(
        cannonPosition: Vector2,
        spawnOffset: CGFloat,
        cannonSpeed: CGFloat = 600,
        rotationSpeed: CGFloat = CGFloat.pi / 2
    ) {
        self.spawnOffset = spawnOffset
        self.cannonSpeed = cannonSpeed
        self.rotationSpeed = rotationSpeed
        super.init(Transform(cannonPosition))
    }

    lazy var makeFireAnimation: () -> (Double) -> Bool = {
        [unowned self] in
        guard let activeAnimSequence = animateSequences["fire"] else {
            fatalError("No anim sequence found for cannon")
        }

        var animCompleted = false
        var rotationCompleted = false
        var frameTimer: Double = 0
        var framePointer = -1
        func rotateAndFire(deltaTime: Double) -> Bool {
            if rotationCompleted {
                if animCompleted {
                    // returned to idle sprite fire cannon ball
                    let initVelocity = targetAim * cannonSpeed
                    let ballSpawnPoint = Transform(transform.position + targetAim * spawnOffset)
                    let cannonBall = CannonBall(launchTransform: ballSpawnPoint, initVelocity: initVelocity)

                    for response in onCannonFired {
                        response(cannonBall)
                    }
                    return true
                }
                // iterate through fire animation
                if frameTimer <= 0 {
                    framePointer += 1
                    animCompleted = framePointer >= activeAnimSequence.count
                    spriteContainer.sprite = animCompleted ? idleSprite : spriteSheet[activeAnimSequence[framePointer]]
                    frameTimer = 1 / Double(frameRate)
                }

                frameTimer -= deltaTime
                return false
            }
            let currAim = Vector2.up.rotateBy(transform.rotation)
            if abs(currAim.x - targetAim.x) <= Cannon.acceptableRotationMargin {
                rotationCompleted = true
                return false
            }

            let rotateDir = Math.sign(currAim.x - targetAim.x)
            let angleBetween = Vector2.angle(from: currAim, to: targetAim)
            transform.rotation += min(rotationSpeed * deltaTime, abs(angleBetween)) * CGFloat(rotateDir)
            // Should always be kept between 0 and 2pi
            transform.rotation = transform.rotation >= 0 ? transform.rotation : CGFloat.pi * 2 + transform.rotation
            return false
        }

        return rotateAndFire
    }

    func fireCannonAt(_ targetPoint: Vector2) {
        if !cannonReady {
            return
        }

        cannonReady = false
        targetAim = (targetPoint - transform.position).normalize
        // Cannon should not fire downwards
        if targetAim.y < 0 {
            return
        }

        guard let activeGameBoard = GameWorld.activeGameBoard else {
            fatalError("No active board")
        }

        activeGameBoard.addCoroutine(Coroutine(
            routine: makeFireAnimation(),
            onCompleted: activeGameBoard.removeCoroutine
        ))
    }
}

class CannonBall: VisibleRigidBody {
    static let defaultRadius: CGFloat = 25
    static let defaultMass: CGFloat = 1
    static let defaultMaterial = Material(restitution: 0.75)
    var spookCharge = 0

    init(
        launchTransform: Transform,
        initVelocity: Vector2,
        radius: CGFloat = CannonBall.defaultRadius,
        mass: CGFloat = CannonBall.defaultMass,
        material: Material = CannonBall.defaultMaterial
    ) {
        let spriteContainer = SpriteContainer(
            sprite: "ball",
            unitWidth: radius * 2,
            unitHeight: radius * 2
        )
        super.init(
            bodyType: BodyType.dynamic,
            material: material,
            collider: CircleCollider(radius),
            spriteContainer: spriteContainer,
            transform: launchTransform,
            mass: mass,
            initVelocity: initVelocity
        )
    }
    
    override func onCollisionEnter(_ collision: Collision) {
        if let pegRb = collision.rbB as? PegRB {
            GameWorld.activeGameBoard?.onBallHitPeg.forEach { response in response(pegRb) }
        }
    }
}
