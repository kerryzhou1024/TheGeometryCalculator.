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

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ContentView()
}
