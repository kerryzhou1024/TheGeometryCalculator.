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
    GeometryFigure(name: "Square", fields: ["Side Length", "Perimeter", "Area"]),
    GeometryFigure(name: "Rectangle", fields: ["Length", "Width", "Perimeter", "Area"]),
    GeometryFigure(name: "Triangle", fields: ["Side A", "Side B", "Side C", "∠A", "∠B", "∠C", "Height", "Perimeter", "Area"]),
    GeometryFigure(name: "Circle", fields: ["Radius", "Diameter", "Circumference", "Area"]),
    GeometryFigure(name: "Parallelogram", fields: ["Base", "Side", "Height", "Perimeter", "Area"]),
    GeometryFigure(name: "Cube", fields: ["Edge Length", "Total Edge Length", "Base Area", "Surface Area", "Volume"]),
    GeometryFigure(name: "Sphere", fields: ["Radius", "Diameter", "Surface Area", "Volume"]),
    GeometryFigure(name: "Cylinder", fields: ["Radius", "Height", "Base Area", "Lateral Area", "Total Surface Area"])
]
