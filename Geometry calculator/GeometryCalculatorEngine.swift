//
//  GeometryCalculatorEngine.swift
//  Geometry calculator
//
//  Created by OpenAI on 2025-02-14.
//

import Foundation

struct GeometryCalculatorEngine {
    private(set) var values: [Double?]
    private let π = Double.pi

    init(values: [Double?]) {
        self.values = values
    }

    mutating func calculate(for figure: GeometryFigure) -> [Double?] {
        switch figure.name {
        case "Square":
            calculateSquare()
        case "Rectangle":
            calculateRectangle()
        case "Triangle":
            calculateTriangle()
        case "Circle":
            calculateCircle()
        case "Parallelogram":
            calculateParallelogram()
        case "Cube":
            calculateCube()
        case "Sphere":
            calculateSphere()
        case "Cylinder":
            calculateCylinder()
        default:
            break
        }

        return values
    }

    private func hasValue(_ index: Int) -> Bool {
        values.indices.contains(index) && values[index] != nil
    }

    private mutating func calculateSquare() {
        if hasValue(0) && !hasValue(1) && !hasValue(2) {
            values[1] = 4 * values[0]!
            values[2] = pow(values[0]!, 2.0)
            return
        }
        if hasValue(1) && !hasValue(0) && !hasValue(2) {
            values[0] = values[1]! / 4.0
            values[2] = pow(values[1]!, 2.0) / 16.0
            return
        }
        if hasValue(2) && !hasValue(0) && !hasValue(1) {
            values[0] = sqrt(values[2]!)
            values[1] = values[0]! * 4.0
            return
        }
    }

    private mutating func calculateRectangle() {
        if hasValue(0) {
            if hasValue(1) {
                values[2] = 2.0 * (values[1]! + values[0]!)
                values[3] = values[0]! * values[1]!
                return
            }

            if hasValue(2) {
                values[1] = values[2]! / 2.0 - values[0]!
                values[3] = values[0]! * values[1]!
                return
            }

            if hasValue(3) {
                values[1] = values[3]! / values[0]!
                values[2] = 2.0 * (values[1]! + values[0]!)
                return
            }
        }

        if hasValue(1) {
            if hasValue(2) {
                values[0] = values[2]! / 2.0 - values[1]!
                values[3] = values[0]! * values[1]!
                return
            }

            if hasValue(3) {
                values[0] = values[3]! / values[1]!
                values[2] = 2.0 * (values[0]! + values[1]!)
                return
            }
        }

        if hasValue(2) && hasValue(3) {
            let solutions = quadraticSolve(a: 2.0, b: -1.0 * values[2]!, c: 2.0 * values[3]!)
            let realSolutions = solutions.filter { $0.isReal }
            let isIndexValid = realSolutions.indices.contains(0)
            if isIndexValid {
                values[0] = realSolutions[0].real < realSolutions[1].real ? realSolutions[0].real : realSolutions[1].real
                values[1] = realSolutions[0].real > realSolutions[1].real ? realSolutions[0].real : realSolutions[1].real
            } else {
                values[0] = 0.0
                values[1] = 0.0
            }
            return
        }
    }

    private mutating func calculateTriangle() {
        for n in 0..<3 {
            if hasValue(7) && hasValue((n + 1) % 3) && hasValue((n + 2) % 3) {
                values[n] = values[7]! - values[(n + 1) % 3]! - values[(n + 2) % 3]!
            }
        }

        if hasValue(8) && hasValue(6) {
            values[0] = values[8]! * 2.0 / values[6]!
        }

        for n in 0..<3 {
            if hasValue(3 + (n + 1) % 3) && hasValue(3 + (n + 2) % 3) {
                values[3 + n] = (180.0 - values[3 + (n + 1) % 3]!) - values[3 + (n + 2) % 3]!
            }
        }

        if hasValue(0) && hasValue(1) && hasValue(2) {
            values = triangleSolver().SSS(a: values[0]!, b: values[1]!, c: values[2]!)
            return
        }

        for n in 0..<3 {
            if hasValue((n + 2) % 3) && hasValue(3 + n) && hasValue((n + 1) % 3) {
                values = triangleSolver().SAS(input: values, center: n)
                return
            }
        }

        if hasValue(3) && hasValue(4) && hasValue(5) {
            if hasValue(0) || hasValue(1) || hasValue(2) {
                values = triangleSolver().AAAS(input: values)
                return
            }
        }

        for n in 0..<3 {
            if let value = values[n + 3], value == 90.0 {
                if hasValue(n) && hasValue((n + 1) % 3) {
                    values[(n + 2) % 3] = sqrt(pow(values[n]!, 2.0) - pow(values[(n + 1) % 3]!, 2.0))
                    values = triangleSolver().SSS(a: values[0]!, b: values[1]!, c: values[2]!)
                    return
                }
                if hasValue(n) && hasValue((n + 2) % 3) {
                    values[(n + 1) % 3] = sqrt(pow(values[n]!, 2.0) - pow(values[(n + 2) % 3]!, 2.0))
                    values = triangleSolver().SSS(a: values[0]!, b: values[1]!, c: values[2]!)
                    return
                }
            }
        }

        var a1: Double?
        var a2: Double?
        var A1: Double?
        var A2: Double?
        var leftTriangle: [Double] = []
        var rightTriangle: [Double] = []

        if hasValue(6) && hasValue(4) {
            A1 = triangleSolver().findThirdAngle(d1: 90.0, d2: values[4]!)
            leftTriangle = triangleSolver().AAAS(input: [nil, nil, values[6], A1, values[4], Optional(90.0)])
            values[2] = leftTriangle[2]
            a1 = leftTriangle[0]
        }

        if hasValue(6) && hasValue(5) {
            A2 = triangleSolver().findThirdAngle(d1: 90.0, d2: values[5]!)
            rightTriangle = triangleSolver().AAAS(input: [nil, nil, values[6], A2, values[5], Optional(90.0)])
            values[1] = rightTriangle[1]
            a2 = rightTriangle[0]
        }

        if hasValue(6) && hasValue(2) {
            a1 = sqrt(pow(values[2]!, 2.0) - pow(values[6]!, 2.0))
            leftTriangle = triangleSolver().SSS(a: a1!, b: values[6]!, c: values[2]!)
            values[4] = leftTriangle[4]
            A1 = leftTriangle[3]
            a1 = leftTriangle[0]
        }

        if hasValue(6) && hasValue(1) {
            a1 = sqrt(pow(values[1]!, 2.0) - pow(values[6]!, 2.0))
            rightTriangle = triangleSolver().SSS(a: a1!, b: values[1]!, c: values[6]!)
            values[5] = rightTriangle[5]
            A2 = rightTriangle[3]
            a2 = rightTriangle[0]
        }

        if let a1, let a2 {
            values[0] = a1 + a2
        }

        if let A1, let A2 {
            values[3] = A1 + A2
        }

        if hasValue(1) && hasValue(2) && hasValue(0) {
            values = triangleSolver().SSS(a: values[0]!, b: values[1]!, c: values[2]!)
        }
    }

    private mutating func calculateCircle() {
        if hasValue(0) {
            values[1] = values[0]! * 2.0
            values[2] = values[1]! * π
            values[3] = pow(values[0]!, 2.0) * π
            return
        }
        if hasValue(1) {
            values[0] = values[1]! / 2.0
            values[2] = values[1]! * π
            values[3] = pow(values[0]!, 2.0) * π
            return
        }
        if hasValue(2) {
            values[1] = values[2]! / π
            values[0] = values[1]! / 2.0
            values[3] = pow(values[0]!, 2.0) * π
            return
        }
        if hasValue(3) {
            values[0] = sqrt(values[3]! / π)
            values[1] = values[0]! * 2.0
            values[2] = values[1]! * π
            return
        }
    }

    private mutating func calculateParallelogram() {
        if hasValue(0) && hasValue(1) {
            values[3] = 2.0 * (values[0]! + values[1]!)
        }
        if hasValue(1) && hasValue(2) {
            values[4] = values[1]! * values[2]!
        }
        if hasValue(4) && hasValue(1) && !hasValue(2) {
            values[2] = values[4]! / values[1]!
        }
        if hasValue(3) && hasValue(0) && !hasValue(1) {
            values[1] = values[3]! / 2.0 - values[0]!
        }
    }

    private mutating func calculateCube() {
        if hasValue(0) {
            values[1] = 12.0 * values[0]!
            values[2] = pow(values[0]!, 2.0)
            values[3] = 6.0 * values[2]!
            values[4] = pow(values[0]!, 3.0)
            return
        }

        if hasValue(1) {
            values[0] = values[1]! / 12.0
            values[2] = pow(values[0]!, 2.0)
            values[3] = 6.0 * values[2]!
            values[4] = pow(values[0]!, 3.0)
            return
        }

        if hasValue(2) {
            values[0] = sqrt(values[2]!)
            values[1] = 12.0 * values[0]!
            values[3] = 6.0 * values[2]!
            values[4] = pow(values[0]!, 3.0)
            return
        }

        if hasValue(3) {
            values[2] = values[3]! / 6.0
            values[0] = sqrt(values[2]!)
            values[1] = 12.0 * values[0]!
            values[4] = pow(values[0]!, 3.0)
            return
        }

        if hasValue(4) {
            values[0] = pow(values[4]!, 1.0 / 3.0)
            values[1] = 12.0 * values[0]!
            values[2] = pow(values[0]!, 2.0)
            values[3] = 6.0 * values[2]!
            return
        }
    }

    private mutating func calculateSphere() {
        if hasValue(0) {
            values[1] = values[0]! * 2.0
            values[2] = 4.0 * π * pow(values[0]!, 2.0)
            values[3] = 4.0 / 3.0 * π * pow(values[0]!, 3.0)
            return
        }

        if hasValue(1) {
            values[0] = values[1]! / 2.0
            values[2] = 4.0 * π * pow(values[0]!, 2.0)
            values[3] = 4.0 / 3.0 * π * pow(values[0]!, 3.0)
            return
        }

        if hasValue(2) {
            values[0] = sqrt(values[2]! / (4.0 * π))
            values[1] = values[0]! * 2.0
            values[3] = 4.0 / 3.0 * π * pow(values[0]!, 3.0)
            return
        }

        if hasValue(3) {
            values[0] = pow((values[3]! * 3.0) / (4.0 * π), 1.0 / 3.0)
            values[1] = values[0]! * 2.0
            values[2] = 4.0 * π * pow(values[0]!, 2.0)
            return
        }
    }

    private mutating func calculateCylinder() {
        if hasValue(0) && hasValue(1) {
            values[2] = pow(values[0]!, 2.0) * π
            values[3] = values[1]! * 2.0 * values[0]! * π
            values[4] = 2.0 * values[2]! + values[3]!
            return
        }
    }
}
