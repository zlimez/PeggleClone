//
//  SphereCollider.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

struct CircleCollider: Collider {
    let standardRadius: CGFloat

    init(_ standardRadius: CGFloat) {
        self.standardRadius = standardRadius
    }

    func testCollision(
        transform: Transform,
        otherCollider: CircleCollider,
        otherTransform: Transform
    ) -> ContactPoints {
        let scaledRadius = standardRadius * transform.scale.x
        let otherScaledRadius = otherCollider.standardRadius * otherTransform.scale.x
        let centerSeparation = otherTransform.position - transform.position

        if pow(scaledRadius + otherScaledRadius, 2) < centerSeparation.sqrMagnitude {
            return ContactPoints.noContact
        }

        let pointA = transform.position + centerSeparation * (scaledRadius / centerSeparation.length)
        let pointB = otherTransform.position - centerSeparation * (otherScaledRadius / centerSeparation.length)
        let normal = (pointA - pointB).normalize
        let depth = (pointA - pointB).length
        return ContactPoints(pointA: pointA, pointB: pointB, normal: normal, depth: depth, hasCollision: true)
    }

    func testCollision(
        transform: Transform,
        otherCollider: PolygonCollider,
        otherTransform: Transform
    ) -> ContactPoints {
        let transformedVertices = otherCollider.stdVertices.map {
            Vector2.elementMultiply(a: $0, b: otherTransform.scale)
                .rotateBy(otherTransform.rotation) + otherTransform.position
        }
        let center = transform.position
        let scaledRadius = standardRadius * transform.scale.x
        let normals = PolygonCollider.getEdgeNormals(vertices: transformedVertices, isBox: otherCollider.isBox)

        var normal = Vector2.zero, depth = CGFloat.infinity
        var minA = CGFloat.infinity, minB = CGFloat.infinity, maxA = -CGFloat.infinity, maxB = -CGFloat.infinity
        // To aid contact point solving
        var minFromCircle = false, minFromPolygon = false

        for axis in normals {
            CircleCollider.projectCircle(
                center: transform.position,
                radius: scaledRadius,
                axis: axis,
                min: &minA,
                max: &maxA
            )
            _ = PolygonCollider.projectVertices(vertices: transformedVertices, axis: axis, min: &minB, max: &maxB)

            if minA >= maxB || minB >= maxA {
                return ContactPoints.noContact
            }

            let axisDepth = min(maxB - minA, maxA - minB)
            if axisDepth < depth {
                depth = axisDepth
                normal = axis

                if axisDepth == maxB - minA {
                    minFromCircle = true
                    minFromPolygon = false
                } else {
                    minFromPolygon = true
                    minFromCircle = false
                }
            }
        }

        if !minFromCircle && !minFromPolygon {
            fatalError("Min should either be from colliders")
        }

        if minFromCircle && minFromPolygon {
            fatalError("There should only be one min")
        }

        var pointA = Vector2.zero, pointB = Vector2.zero
        if minFromCircle {
            pointA = transform.position - normal * scaledRadius
            pointB = pointA + normal * depth
        } else {
            pointA = transform.position + normal * scaledRadius
            pointB = pointA - normal * depth
        }

        let otherCenter = PolygonCollider.findCenter(transformedVertices)
        let direction = otherCenter - center
        if Vector2.dotProduct(a: direction, b: normal) < 0 {
            normal *= -1
        }

        return ContactPoints(pointA: pointA, pointB: pointB, normal: normal, depth: depth, hasCollision: true)
    }

    static func projectCircle(center: Vector2, radius: CGFloat, axis: Vector2, min: inout CGFloat, max: inout CGFloat) {
        let projectedCenter = Vector2.dotProduct(a: center, b: axis)
        min = projectedCenter - radius
        max = projectedCenter + radius
    }

    func testCollision(transform: Transform, otherCollider: BoxCollider, otherTransform: Transform) -> ContactPoints {
        testCollision(
            transform: transform,
            otherCollider: otherCollider.polygonizedCollider,
            otherTransform: otherTransform
        )
    }

    func testCollision(transform: Transform, otherCollider: Collider, otherTransform: Transform) -> ContactPoints {
        if transform.scale.x != transform.scale.y || otherTransform.scale.x != otherTransform.scale.y {
            fatalError("Circle's x and y transform should have identical scales")
        }

        return otherCollider.testCollision(
            transform: otherTransform,
            otherCollider: self,
            otherTransform: transform
        ).reverse
    }
}
