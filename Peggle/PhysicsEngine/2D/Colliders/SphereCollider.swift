//
//  SphereCollider.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

struct SphereCollider: Collider {
    let standardRadius: CGFloat
    
    func testCollision(transform: Transform, otherCollider: SphereCollider, otherTransform: Transform) -> ContactPoints {
        let scaledRadius = standardRadius * transform.scale.x
        let otherScaledRadius = otherCollider.standardRadius * otherTransform.scale.x
        let centerSeparation = otherTransform.position - transform.position
        
        if (pow(scaledRadius + otherScaledRadius, 2) < centerSeparation.sqrMagnitude) {
            return ContactPoints.noContact
        }
        
        let pointA = transform.position + centerSeparation * (scaledRadius / centerSeparation.length)
        let pointB = otherTransform.position - centerSeparation * (otherScaledRadius / centerSeparation.length)
        let normal = (pointB - pointA).normalize
        let depth = (pointB - pointA).length
        return ContactPoints(pointA: pointA, pointB: pointB, normal: normal, depth: depth, hasCollision: true)
    }
    
    func testCollision(transform: Transform, otherCollider: PolygonCollider, otherTransform: Transform) -> ContactPoints {
        let transformedVertices = otherCollider.stdVertices.map { Vector2.elementMultiply(a: $0, b: otherTransform.scale).rotateBy(otherTransform.rotation) + otherTransform.position }
        let center = transform.position
        let scaledRadius = standardRadius * transform.scale.x
        let normals = PolygonCollider.getEdgeNormals(transformedVertices)
        
        var normal = Vector2.zero
        var depth = CGFloat.infinity
        var minA = CGFloat.infinity, minB = CGFloat.infinity, maxA = -CGFloat.infinity, maxB = -CGFloat.infinity
        // To aid contact point solving
        var minFromCircle: Bool = false
        var minFromPolygon: Bool = false
        
        for axis in normals {
            SphereCollider.projectCircle(center: transform.position, radius: scaledRadius, axis: axis, min: &minA, max: &maxA)
            _ = PolygonCollider.projectVertices(vertices: transformedVertices, axis: axis, min: &minB, max: &maxB)
            
            if minA >= maxB || minB >= maxA {
                return ContactPoints.noContact
            }
            
            let axisDepth = min(maxB - minA, maxA - minB)

            if (axisDepth < depth) {
                depth = axisDepth
                normal = axis
                
                if axisDepth == maxB - minA {
                    minFromCircle = true
                } else {
                    minFromPolygon = true
                }
            }
        }
        
        if !minFromCircle && !minFromPolygon {
            fatalError("Min should either be from colliders")
        }
        
        if minFromCircle && minFromCircle {
            fatalError("There should only be one min")
        }
        
        
        var pointA = Vector2.zero
        var pointB = Vector2.zero
        
        if minFromCircle {
            pointA = transform.position - normal * scaledRadius
            pointB = pointA + normal * depth
        } else {
            pointA = transform.position + normal * scaledRadius
            pointB = pointA - normal * depth
        }
        
        let otherCenter = PolygonCollider.findArithmeticMean(transformedVertices)
        let direction = otherCenter - center

        if Vector2.dotProduct(a: direction, b: normal) < 0 {
            normal = normal * -1
        }
        
        return ContactPoints(pointA: pointA, pointB: pointB, normal: normal, depth: depth, hasCollision: true)
    }
    
    static func projectCircle(center: Vector2, radius: CGFloat, axis: Vector2, min: inout CGFloat, max: inout CGFloat) {
        let projectedCenter = Vector2.dotProduct(a: center, b: axis)
        min = projectedCenter - radius
        max = projectedCenter + radius
    }
    
    func testCollision(transform: Transform, otherCollider: BoxCollider, otherTransform: Transform) -> ContactPoints {
        testCollision(transform: transform, otherCollider: otherCollider.polygonizedCollider, otherTransform: otherTransform)
    }

    func testCollision(transform: Transform, otherCollider: Collider, otherTransform: Transform) -> ContactPoints {
        if transform.scale.x != transform.scale.y || otherTransform.scale.x != otherTransform.scale.y {
            fatalError("Sphere's x and y transform should have identical scales")
        }
        
        return otherCollider.testCollision(transform: otherTransform, otherCollider: self, otherTransform: transform).reverse
    }
}
