//
//  ContentView.swift
//  Geometry calculator
//
//  Created by OpenAI on 2025-02-14.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedFigure = geometryFigures.first!
    @State private var inputStrings: [String] = Array(repeating: "", count: geometryFigures.first?.fields.count ?? 0)
    @State private var results: [Double?] = Array(repeating: nil, count: geometryFigures.first?.fields.count ?? 0)

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ShapePreviewCard(figure: selectedFigure, values: previewInputValues)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }

                Section("Shape") {
                    Picker("Figure", selection: $selectedFigure) {
                        ForEach(geometryFigures) { figure in
                            Text(figure.name).tag(figure)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedFigure) { newValue in
                        inputStrings = Array(repeating: "", count: newValue.fields.count)
                        results = Array(repeating: nil, count: newValue.fields.count)
                    }
                }

                Section("Inputs & Results") {
                    ForEach(selectedFigure.fields.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(selectedFigure.fields[index])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                TextField("Value", text: binding(for: index))
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(maxWidth: 140)
                            }
                            if let result = results[safe: index] {
                                Text("Result: \(formatNumber(result))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section {
                    Button("Calculate") {
                        calculate()
                    }
                }
            }
            .navigationTitle("Geometry Calculator")
        }
    }

    private var previewInputValues: [Double?] {
        inputStrings.map { Double($0) }
    }

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: {
                inputStrings[safe: index] ?? ""
            },
            set: { newValue in
                if inputStrings.indices.contains(index) {
                    inputStrings[index] = newValue
                }
            }
        )
    }

    private func calculate() {
        let inputs = inputStrings.map { Double($0) }
        var engine = GeometryCalculatorEngine(values: inputs)
        results = engine.calculate(for: selectedFigure)
        inputStrings = results.map { value in
            guard let value else { return "" }
            return formatNumber(value)
        }
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}

private struct ShapePreviewCard: View {
    let figure: GeometryFigure
    let values: [Double?]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Shape Preview")
                .font(.headline)
                .padding(.horizontal)

            GeometryReader { proxy in
                let frame = CGRect(origin: .zero, size: proxy.size)
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.08), Color.indigo.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))

                    ShapePreviewCanvas(figure: figure, values: values)
                        .padding(24)
                }
                .frame(width: frame.width, height: frame.height)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal)

            Text("Scale is auto-adjusted to keep proportions precise.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding(.vertical, 4)
    }
}

private struct ShapePreviewCanvas: View {
    let figure: GeometryFigure
    let values: [Double?]

    var body: some View {
        Canvas { context, size in
            let bounds = CGRect(origin: .zero, size: size)
            let stroke = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)

            switch figure.name {
            case "Square":
                drawRectangleShape(in: bounds, width: value(at: 0), height: value(at: 0), context: &context, stroke: stroke)
            case "Rectangle":
                drawRectangleShape(in: bounds, width: value(at: 0), height: value(at: 1), context: &context, stroke: stroke)
            case "Triangle":
                drawTriangle(in: bounds, a: value(at: 0), b: value(at: 1), c: value(at: 2), context: &context, stroke: stroke)
            case "Circle":
                drawCircle(in: bounds, radius: value(at: 0), context: &context, stroke: stroke)
            case "Parallelogram":
                drawParallelogram(in: bounds, a: value(at: 0), b: value(at: 1), height: value(at: 2), context: &context, stroke: stroke)
            case "Cube":
                drawCube(in: bounds, side: value(at: 0), context: &context, stroke: stroke)
            case "Sphere":
                drawSphere(in: bounds, radius: value(at: 0), context: &context, stroke: stroke)
            case "Cylinder":
                drawCylinder(in: bounds, radius: value(at: 0), height: value(at: 1), context: &context, stroke: stroke)
            default:
                break
            }
        }
    }

    private func value(at index: Int, fallback: Double = 1) -> Double {
        guard values.indices.contains(index), let raw = values[index], raw > 0 else {
            return fallback
        }
        return raw
    }

    private func drawRectangleShape(in rect: CGRect, width: Double, height: Double, context: inout GraphicsContext, stroke: StrokeStyle) {
        let fitted = fitRect(contentWidth: width, contentHeight: height, in: rect)
        let path = Path(roundedRect: fitted, cornerRadius: min(fitted.width, fitted.height) * 0.07)
        context.fill(path, with: .linearGradient(Gradient(colors: [.mint.opacity(0.45), .teal.opacity(0.12)]), startPoint: fitted.origin, endPoint: CGPoint(x: fitted.maxX, y: fitted.maxY)))
        context.stroke(path, with: .color(.teal), style: stroke)
    }

    private func drawCircle(in rect: CGRect, radius: Double, context: inout GraphicsContext, stroke: StrokeStyle) {
        let diameter = radius * 2
        let fitted = fitRect(contentWidth: diameter, contentHeight: diameter, in: rect)
        let path = Path(ellipseIn: fitted)
        context.fill(path, with: .radialGradient(Gradient(colors: [.cyan.opacity(0.55), .blue.opacity(0.10)]), center: CGPoint(x: fitted.midX, y: fitted.midY), startRadius: 0, endRadius: fitted.width / 2))
        context.stroke(path, with: .color(.blue), style: stroke)
    }

    private func drawTriangle(in rect: CGRect, a: Double, b: Double, c: Double, context: inout GraphicsContext, stroke: StrokeStyle) {
        var sideA = a
        var sideB = b
        var sideC = c

        if sideA + sideB <= sideC || sideB + sideC <= sideA || sideC + sideA <= sideB {
            sideA = 3
            sideB = 4
            sideC = 5
        }

        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: sideC, y: 0)

        let x = (pow(sideB, 2) + pow(sideC, 2) - pow(sideA, 2)) / (2 * sideC)
        let ySquared = max(0, pow(sideB, 2) - pow(x, 2))
        let point3 = CGPoint(x: x, y: sqrt(ySquared))

        let points = [point1, point2, point3]
        let fittedPoints = fitPoints(points, in: rect)

        var path = Path()
        path.move(to: fittedPoints[0])
        path.addLine(to: fittedPoints[1])
        path.addLine(to: fittedPoints[2])
        path.closeSubpath()

        context.fill(path, with: .linearGradient(Gradient(colors: [.orange.opacity(0.5), .red.opacity(0.15)]), startPoint: fittedPoints[2], endPoint: CGPoint(x: rect.midX, y: rect.maxY)))
        context.stroke(path, with: .color(.orange), style: stroke)
    }

    private func drawParallelogram(in rect: CGRect, a: Double, b: Double, height: Double, context: inout GraphicsContext, stroke: StrokeStyle) {
        let safeHeight = max(0.5, min(height, b))
        let horizontalOffset = sqrt(max(0, b * b - safeHeight * safeHeight))
        let points = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: a, y: 0),
            CGPoint(x: a + horizontalOffset, y: safeHeight),
            CGPoint(x: horizontalOffset, y: safeHeight)
        ]
        let fitted = fitPoints(points, in: rect)

        var path = Path()
        path.move(to: fitted[0])
        path.addLine(to: fitted[1])
        path.addLine(to: fitted[2])
        path.addLine(to: fitted[3])
        path.closeSubpath()

        context.fill(path, with: .linearGradient(Gradient(colors: [.purple.opacity(0.42), .indigo.opacity(0.16)]), startPoint: fitted[0], endPoint: fitted[2]))
        context.stroke(path, with: .color(.indigo), style: stroke)
    }

    private func drawCube(in rect: CGRect, side: Double, context: inout GraphicsContext, stroke: StrokeStyle) {
        let s = max(side, 1)
        let depth = s * 0.35

        let front = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: s, y: 0),
            CGPoint(x: s, y: s),
            CGPoint(x: 0, y: s)
        ]
        let back = front.map { CGPoint(x: $0.x + depth, y: $0.y - depth) }
        let all = front + back
        let fitted = fitPoints(all, in: rect)
        let fittedFront = Array(fitted[0..<4])
        let fittedBack = Array(fitted[4..<8])

        var frontPath = Path()
        frontPath.addLines(fittedFront + [fittedFront[0]])
        context.fill(frontPath, with: .color(.green.opacity(0.22)))
        context.stroke(frontPath, with: .color(.green), style: stroke)

        var topPath = Path()
        topPath.move(to: fittedBack[0])
        topPath.addLine(to: fittedBack[1])
        topPath.addLine(to: fittedFront[1])
        topPath.addLine(to: fittedFront[0])
        topPath.closeSubpath()
        context.fill(topPath, with: .color(.green.opacity(0.34)))
        context.stroke(topPath, with: .color(.green), style: stroke)

        var sidePath = Path()
        sidePath.move(to: fittedBack[1])
        sidePath.addLine(to: fittedBack[2])
        sidePath.addLine(to: fittedFront[2])
        sidePath.addLine(to: fittedFront[1])
        sidePath.closeSubpath()
        context.fill(sidePath, with: .color(.green.opacity(0.14)))
        context.stroke(sidePath, with: .color(.green), style: stroke)

        for index in 0..<4 {
            var connector = Path()
            connector.move(to: fittedFront[index])
            connector.addLine(to: fittedBack[index])
            context.stroke(connector, with: .color(.green), style: stroke)
        }
    }

    private func drawSphere(in rect: CGRect, radius: Double, context: inout GraphicsContext, stroke: StrokeStyle) {
        let diameter = radius * 2
        let fitted = fitRect(contentWidth: diameter, contentHeight: diameter, in: rect)

        let body = Path(ellipseIn: fitted)
        context.fill(body, with: .radialGradient(Gradient(colors: [.pink.opacity(0.48), .purple.opacity(0.12)]), center: CGPoint(x: fitted.midX - fitted.width * 0.15, y: fitted.midY - fitted.height * 0.2), startRadius: 2, endRadius: fitted.width * 0.6))
        context.stroke(body, with: .color(.purple), style: stroke)

        let equatorRect = fitted.insetBy(dx: fitted.width * 0.06, dy: fitted.height * 0.30)
        let equator = Path(ellipseIn: equatorRect)
        context.stroke(equator, with: .color(.purple.opacity(0.55)), style: StrokeStyle(lineWidth: 2))
    }

    private func drawCylinder(in rect: CGRect, radius: Double, height: Double, context: inout GraphicsContext, stroke: StrokeStyle) {
        let w = radius * 2
        let h = max(height, 0.5)
        let fitted = fitRect(contentWidth: w, contentHeight: h, in: rect)
        let ellipseHeight = max(16, fitted.width * 0.2)

        let bodyRect = CGRect(x: fitted.minX, y: fitted.minY + ellipseHeight / 2, width: fitted.width, height: max(1, fitted.height - ellipseHeight))
        let topRect = CGRect(x: fitted.minX, y: bodyRect.minY - ellipseHeight / 2, width: fitted.width, height: ellipseHeight)
        let bottomRect = CGRect(x: fitted.minX, y: bodyRect.maxY - ellipseHeight / 2, width: fitted.width, height: ellipseHeight)

        let bodyPath = Path(CGRect(x: bodyRect.minX, y: bodyRect.minY, width: bodyRect.width, height: bodyRect.height))
        context.fill(bodyPath, with: .linearGradient(Gradient(colors: [.blue.opacity(0.18), .cyan.opacity(0.45), .blue.opacity(0.18)]), startPoint: CGPoint(x: bodyRect.minX, y: bodyRect.midY), endPoint: CGPoint(x: bodyRect.maxX, y: bodyRect.midY)))

        context.stroke(Path(ellipseIn: topRect), with: .color(.blue), style: stroke)

        var side = Path()
        side.move(to: CGPoint(x: bodyRect.minX, y: bodyRect.minY))
        side.addLine(to: CGPoint(x: bodyRect.minX, y: bodyRect.maxY))
        side.move(to: CGPoint(x: bodyRect.maxX, y: bodyRect.minY))
        side.addLine(to: CGPoint(x: bodyRect.maxX, y: bodyRect.maxY))
        context.stroke(side, with: .color(.blue), style: stroke)

        context.stroke(Path(ellipseIn: bottomRect), with: .color(.blue.opacity(0.55)), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
    }

    private func fitRect(contentWidth: Double, contentHeight: Double, in rect: CGRect) -> CGRect {
        let safeWidth = max(contentWidth, 0.001)
        let safeHeight = max(contentHeight, 0.001)

        let xScale = rect.width / safeWidth
        let yScale = rect.height / safeHeight
        let scale = min(xScale, yScale) * 0.9

        let finalWidth = safeWidth * scale
        let finalHeight = safeHeight * scale

        return CGRect(
            x: rect.midX - finalWidth / 2,
            y: rect.midY - finalHeight / 2,
            width: finalWidth,
            height: finalHeight
        )
    }

    private func fitPoints(_ points: [CGPoint], in rect: CGRect) -> [CGPoint] {
        guard !points.isEmpty else { return [] }

        let minX = points.map(\.x).min() ?? 0
        let maxX = points.map(\.x).max() ?? 1
        let minY = points.map(\.y).min() ?? 0
        let maxY = points.map(\.y).max() ?? 1

        let fittedRect = fitRect(contentWidth: maxX - minX, contentHeight: maxY - minY, in: rect)

        let scaleX = fittedRect.width / max(0.001, maxX - minX)
        let scaleY = fittedRect.height / max(0.001, maxY - minY)

        return points.map { point in
            CGPoint(
                x: fittedRect.minX + (point.x - minX) * scaleX,
                y: fittedRect.maxY - (point.y - minY) * scaleY
            )
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ContentView()
}
