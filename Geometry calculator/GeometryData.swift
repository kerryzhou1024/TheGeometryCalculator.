//
//  GeometryData.swift
//  Geometry calculator
//
//  Created by OpenAI on 2025-02-14.
//

import Foundation

struct GeometryFigure: Identifiable, Hashable {
    let name: String
    let fields: [String]

    var id: String { name }
}

let geometryFigures: [GeometryFigure] = [
    GeometryFigure(name: "Square", fields: ["a", "Perimeter", "Area"]),
    GeometryFigure(name: "Rectangle", fields: ["a", "b", "Perimeter", "Area"]),
    GeometryFigure(name: "Triangle", fields: ["a", "b", "c", "∠A", "∠B", "∠C", "height", "Perimeter", "Area"]),
    GeometryFigure(name: "Circle", fields: ["radius", "diameter", "Circumference", "Area"]),
    GeometryFigure(name: "Parallelogram", fields: ["a", "b", "height", "Perimeter", "Area"]),
    GeometryFigure(name: "Cube", fields: ["a", "Perimeter", "Bottom area", "Surface area", "Volume"]),
    GeometryFigure(name: "Sphere", fields: ["radius", "diameter", "surface area", "Volume"]),
    GeometryFigure(name: "Cylinder", fields: ["r", "h", "Bottom Area", "Side Area", "Total Area"])
]
