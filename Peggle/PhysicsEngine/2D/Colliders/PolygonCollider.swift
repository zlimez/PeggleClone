//
//  PolygonCollider.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

struct PolygonCollider: Collider {
    let stdVertices: [Vector2]
    let isBox: Bool

    static func getEdgeNormals(vertices: [Vector2], isBox: Bool) -> Set<Vector2> {
        let numVertices = vertices.count
        var normals = Set<Vector2>()
        let primeVertices = isBox ? numVertices / 2 : numVertices

        for i in 0..<primeVertices {
            let curr = vertices[i]
            let next = vertices[(i + 1) % numVertices]
            let edge = Vector2(x: next.x - curr.x, y: next.y - curr.y)
            let normal = edge.getNormal()
            normals.insert(normal)
        }

        return normals
    }

    func testCollision(
        transform: Transform,
        otherCollider: CircleCollider,
        otherTransform: Transform
    ) -> ContactPoints {
        otherCollider.testCollision(transform: otherTransform, otherCollider: self, otherTransform: transform).reverse
    }

    func testCollision(
        transform: Transform,
        otherCollider: PolygonCollider,
        otherTransform: Transform
    ) -> ContactPoints {
        let transformedVertices = stdVertices.map {
            Vector2.elementMultiply(a: $0, b: transform.scale)
                .rotateBy(transform.rotation) + transform.position
        }
        let transformedOtherVertices = otherCollider.stdVertices.map {
            Vector2.elementMultiply(a: $0, b: otherTransform.scale)
                .rotateBy(otherTransform.rotation) + otherTransform.position
        }

        let allNormals = PolygonCollider.getEdgeNormals(vertices: transformedVertices, isBox: isBox)
            .union(PolygonCollider.getEdgeNormals(
                vertices: transformedOtherVertices,
                isBox: otherCollider.isBox)
            )

        var normal = Vector2.zero
        var depth = CGFloat.infinity
        var minA = CGFloat.infinity, minB = CGFloat.infinity, maxA = -CGFloat.infinity, maxB = -CGFloat.infinity
        var minVertices: [Vector2] = [], maxVertices: [Vector2] = []
        var minFromA = false, minFromB = false

        for axis in allNormals {
            let criticalVerticesA = PolygonCollider.projectVertices(
                vertices: transformedVertices,
                axis: axis,
                min: &minA,
                max: &maxA
            )
            let criticalVerticesB = PolygonCollider.projectVertices(
                vertices: transformedOtherVertices,
                axis: axis,
                min: &minB,
                max: &maxB
            )

            if minA >= maxB || minB >= maxA {
                return ContactPoints.noContact
            }

            let axisDepth = min(maxB - minA, maxA - minB)

            if axisDepth < depth {
                depth = axisDepth
                normal = axis

                if axisDepth == maxB - minA {
                    maxVertices = criticalVerticesB.1
                    minVertices = criticalVerticesA.0
                    minFromA = true
                    minFromB = false
                } else {
                    maxVertices = criticalVerticesA.1
                    minVertices = criticalVerticesB.0
                    minFromB = true
                    minFromA = false
                }
            }
        }

        var pointA = Vector2.zero, pointB = Vector2.zero

        if !minFromA && !minFromB {
            fatalError("Min should either be from colliders")
        }

        if minFromA && minFromB {
            fatalError("There should only be one min")
        }

        PolygonCollider.getContactPoints(
            pointA: &pointA,
            pointB: &pointB,
            normal: normal,
            depth: depth,
            minVertices: minVertices,
            maxVertices: maxVertices,
            minFromA: minFromA
        )

        let direction = PolygonCollider.findCenter(transformedOtherVertices)
            - PolygonCollider.findCenter(transformedVertices)
        if Vector2.dotProduct(a: direction, b: normal) < 0 {
            normal *= -1
        }

        return ContactPoints(pointA: pointA, pointB: pointB, normal: normal, depth: depth, hasCollision: true)
    }

    static func getContactPoints(
        pointA: inout Vector2,
        pointB: inout Vector2,
        normal: Vector2,
        depth: CGFloat,
        minVertices: [Vector2],
        maxVertices: [Vector2],
        minFromA: Bool
    ) {
        if minVertices.isEmpty || maxVertices.isEmpty {
            fatalError("There should be at least one vertice in min and max vertices")
        }

        if minVertices.count > 2 || maxVertices.count > 2 {
            fatalError("Polygon is mal-defined with colinear vertices")
        }

        if minVertices.count == 1 {
            if minFromA {
                pointA = minVertices[0]
                pointB = pointA + normal * depth
            } else {
                pointB = minVertices[0]
                pointA = pointB + normal * depth
            }
        } else if maxVertices.count == 1 {
            if minFromA {
                pointB = maxVertices[0]
                pointA = pointB - normal * depth
            } else {
                pointA = maxVertices[0]
                pointB = pointA - normal * depth
            }
        } else {
            // Special case where the intersecting area has a pair of parallel sides
            if minFromA {
                let possiblePointB = minVertices[0] + normal * depth
                let nextPossiblePointB = minVertices[1] + normal * depth
                if LineUtils.checkPointInLineSegment(
                    lineStart: maxVertices[0],
                    lineEnd: maxVertices[1],
                    checkedPoint: possiblePointB
                ) {
                    pointA = minVertices[0]
                    pointB = possiblePointB
                } else if LineUtils.checkPointInLineSegment(
                    lineStart: maxVertices[0],
                    lineEnd: maxVertices[1],
                    checkedPoint: nextPossiblePointB
                ) {
                    pointA = minVertices[1]
                    pointB = nextPossiblePointB
                } else {
                    fatalError("SAT implementation erroreneous")
                }
            } else {
                let possiblePointA = minVertices[0] + normal * depth
                let nextPossiblePointA = minVertices[1] + normal * depth
                if LineUtils.checkPointInLineSegment(
                    lineStart: maxVertices[0],
                    lineEnd: maxVertices[1],
                    checkedPoint: possiblePointA
                ) {
                    pointB = minVertices[0]
                    pointA = possiblePointA
                } else if LineUtils.checkPointInLineSegment(
                    lineStart: maxVertices[0],
                    lineEnd: maxVertices[1],
                    checkedPoint: nextPossiblePointA
                ) {
                    pointB = minVertices[1]
                    pointA = nextPossiblePointA
                } else {
                    fatalError("SAT implementation erroreneous")
                }
            }
        }
    }

    static func findCenter(_ vertices: [Vector2]) -> Vector2 {
        var sumX: CGFloat = 0
        var sumY: CGFloat = 0

        for vertice in vertices {
            sumX += vertice.x
            sumY += vertice.y
        }

        return Vector2(x: sumX / CGFloat(vertices.count), y: sumY / CGFloat(vertices.count))
    }

    // Returns tuple of min - max vertices
    static func projectVertices(
        vertices: [Vector2],
        axis: Vector2,
        min: inout CGFloat,
        max: inout CGFloat
    ) -> ([Vector2], [Vector2]) {
        // If the axis is based on edge of pplygon that contains this vertice,
        // there will be two vertices in either minVertice or maxVertice
        var minVertice: [Vector2] = []
        var maxVertice: [Vector2] = []
        min = CGFloat.infinity
        max = -CGFloat.infinity

        for vertice in vertices {
            let proj = Vector2.dotProduct(a: vertice, b: axis)

            if proj < min {
                min = proj
                minVertice.removeAll()
                minVertice.append(vertice)
            } else if proj == min {
                minVertice.append(vertice)
            }

            if proj > max {
                max = proj
                maxVertice.removeAll()
                maxVertice.append(vertice)
            } else if proj == max {
                maxVertice.append(vertice)
            }
        }

        return (minVertice, maxVertice)
    }

    func testCollision(transform: Transform, otherCollider: BoxCollider, otherTransform: Transform) -> ContactPoints {
        testCollision(
            transform: transform,
            otherCollider: otherCollider.polygonizedCollider,
            otherTransform: otherTransform
        )
    }

    func testCollision(transform: Transform, otherCollider: Collider, otherTransform: Transform) -> ContactPoints {
        otherCollider.testCollision(transform: otherTransform, otherCollider: self, otherTransform: transform).reverse
    }
}
