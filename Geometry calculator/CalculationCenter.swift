//
//  CalculationCenter.swift
//  Geometry calculator
//
//  Created by Kerry Zhou on 6/5/20.
//  Copyright © 2020 Kerry Zhou. All rights reserved.
//

import Foundation

//NOTE: address alters and values(instead of using 0.0, consider to use nil as unknown values)


//MARK: data source
//figures and their elements
let figures = ["Square": ["Side Length", "Perimeter", "Area"],
               "Rectangle": ["Length", "Width", "Perimeter", "Area"],
               "Triangle":["Side A", "Side B", "Side C", "∠A", "∠B", "∠C", "Height", "Perimeter", "Area"],
               "Circle":["Radius", "Diameter", "Circumference", "Area"],
               "Cube":["Edge Length", "Total Edge Length", "Base Area", "Surface Area", "Volume"],
               "Sphere":["Radius", "Diameter", "Surface Area", "Volume"],
               "Cylinder":["Radius", "Height", "Base Area", "Lateral Area", "Total Surface Area"]
                ]

//this matches with figures's value that need π as appendix
let figuresNeedToUseπ = ["Circle":[false, false, true, true],
                          "Sphere":[false, false, true, true],
                          "Cylinder":[false, false, true, true, true]
                ]


// initialize values, the most important variable in this app
var values = [Double?]()


//true value of π
let πSpecific = 3.14159265

//update π at the very begining
var π = Double.pi

//    if result includes π
var useπValue = true

class CalculationCenter{

    
    //create "values" Array with specific number of elements
    func createNumbersForValues(figureName: String){
        var i = 0
        while i < figures[figureName]!.count {
            values.append(nil)
            i += 1
        }
    }
    
    
    
    
    
    //when ever user input new value, it trigger calculation that attempt to give results
    func startCalculation(figureName:String?){
        switch figureName {
            case "Square":
                forSquare()
            case "Rectangle":
                forRectangle()
            case "Triangle":
                forTriangle()
            case "Circle":
                updateπ()
                forCircle()
            case "Cube":
                forCube()
            case "Sphere":
                updateπ()
                forSphere()
            case "Cylinder":
                updateπ()
                forCylinder()
                
            default:
                print("could not find the figure in startCalculation")
        }
        
    }

    func updateπ(){
        if let sliderPosition = UserDefaults.standard.object(forKey: "πSilderValue") as? Double{
            π = Double(round(pow(10.0, Double(Int(sliderPosition))) * πSpecific) / pow(10.0, Double(Int(sliderPosition))))
            print(π)
        }else{
            π = 3.14
        }
        
        if let πSwitchStatus = UserDefaults.standard.object(forKey: "πSwitchStatus"){
            useπValue = πSwitchStatus as! Bool
        }else{
            useπValue = true
        }
    }
    
//check values[n] is nil
    func checkNil(n:Int) -> Bool{
        return values[n] != nil
    }

    
    //core of calculation
    //for specific shape
    func forSquare(){
        if checkNil(n: 0) && !checkNil(n: 1) && !checkNil(n: 2){
            values[1] = 4 * values[0]!
            values[2] = pow(values[0]!, 2.0)
            return
        }
        if checkNil(n: 1) && !checkNil(n: 0) && !checkNil(n: 2){
            values[0] = values[1]! / 4.0
            values[2] = pow(values[1]!, 2.0) / 16.0
            return
        }
        if checkNil(n: 2) && !checkNil(n: 0) && !checkNil(n: 1){
            values[0] = sqrt(values[2]!)
            values[1] = values[0]! * 4.0
            return
        }
    }
    
    
    func forRectangle(){
        if checkNil(n: 0){
            if checkNil(n: 1){
                values[2] = 2.0 * (values[1]! + values[0]!)
                values[3] = values[0]! * values[1]!
                return
            }
            
            if checkNil(n: 2){
                values[1] = values[2]! / 2.0 - values[0]!
                values[3] = values[0]! * values[1]!
                return
            }
            
            if checkNil(n: 3){
                values[1] = values[3]! / values[0]!
                values[2] = 2.0 * (values[1]! + values[0]!)
                return
            }
            
        }
        
        if checkNil(n: 1){
            if checkNil(n: 2){
                values[0] = values[2]! / 2.0 - values[1]!
                values[3] = values[0]! * values[1]!
                return
            }
            
            if checkNil(n: 3){
                values[0] = values[3]! / values[1]!
                values[2] = 2.0 * (values[0]! + values[1]!)
                return
            }
        }
        
        if checkNil(n: 2){
            if checkNil(n: 3){
                let solutions = quadraticSolve(a: 2.0, b: -1.0 * values[2]!, c: 2.0 * values[3]!)
                let realSolutions = solutions.filter({ $0.isReal }) // filters for only real values
                let isIndexValid = realSolutions.indices.contains(0)
                if isIndexValid   {
                    values[0] = realSolutions[0].real < realSolutions[1].real ? realSolutions[0].real: realSolutions[1].real//set the smaller one for "a"
                    values[1] = realSolutions[0].real > realSolutions[1].real ? realSolutions[0].real: realSolutions[1].real
                }else{
                    values[0] = 0.0 // set zero means it doesn't exsit (in order to trigger alters)
                    values[1] = 0.0
                }
                return

            }
        }
    }
    
    
    func forCube(){
        if checkNil(n: 0){
            values[1] = 12.0 * values[0]!
            values[2] = pow(values[0]!, 2.0)
            values[3] = 6.0 * values[2]!
            values[4] = pow(values[0]!, 3.0)
            return
        }
        
        if checkNil(n: 1){
            values[0] = values[1]! / 12.0
            values[2] = pow(values[0]!, 2.0)
            values[3] = 6.0 * values[2]!
            values[4] = pow(values[0]!, 3.0)
            return
        }
        
        if checkNil(n: 2){
            values[0] = sqrt(values[2]!)
            values[1] = 12.0 * values[0]!
            values[3] = 6.0 * values[2]!
            values[4] = pow(values[0]!, 3.0)
            return
        }
        
        if checkNil(n: 3){
            values[0] = sqrt(values[3]! / 6.0)
            values[1] = 12.0 * values[0]!
            values[2] = pow(values[0]!, 2.0)
            values[4] = pow(values[0]!, 3.0)
            return
        }
        if checkNil(n: 4){
            values[0] = pow(values[4]!, 1.0 / 3.0)
            values[1] = 12.0 * values[0]!
            values[2] = pow(values[0]!, 2.0)
            values[3] = 6.0 * values[2]!
            return
        }
    }
    
    
//    "radius","diameter", "Circumference", "Area"
    func forCircle(){
        if useπValue{
            if checkNil(n: 0){
                values[1] = values[0]! * 2.0
                values[2] = values[0]! * 2.0 * π
                values[3] = pow(values[0]!, 2.0) * π
                return
            }
            if checkNil(n: 1){
                values[0] = values[1]! / 2.0
                values[2] = values[0]! * 2.0 * π
                values[3] = pow(values[0]!, 2.0) * π
                return
            }
            if checkNil(n: 2){
                values[0] = values[2]! / (2.0 * π)
                values[1] = values[0]! * 2.0
                values[3] = pow(values[0]!, 2.0) * π
                return
            }
            if checkNil(n: 3){
                values[0] = sqrt(values[3]! / π)
                values[1] = values[0]! * 2.0
                values[2] = values[0]! * 2.0 * π
                return
            }
        }else{
            if checkNil(n: 0){
                values[1] = values[0]! * 2.0
                values[2] = values[0]! * 2.0
                values[3] = pow(values[0]!, 2.0)
                return
            }
            if checkNil(n: 1){
                values[0] = values[1]! / 2.0
                values[2] = values[0]! * 2.0
                values[3] = pow(values[0]!, 2.0)
                return
            }
            if checkNil(n: 2){
                values[0] = values[2]! / 2.0
                values[1] = values[0]! * 2.0
                values[3] = pow(values[0]!, 2.0)
                return
            }
            if checkNil(n: 3){
                values[0] = sqrt(values[3]!)
                values[1] = values[0]! * 2.0
                values[2] = values[0]! * 2.0
                return
            }
        }
    }
    
//               "Sphere":["radius", "diameter", "surface area", "Volume"]]
    func forSphere(){
        if useπValue{
            if checkNil(n: 0){
                values[1] = values[0]! * 2.0
                values[2] = 4.0 * π * pow(values[0]!, 2.0)
                values[3] = pow(values[0]!, 3.0) * π * 4.0 / 3.0
                return
                
            }
            if checkNil(n: 1){
                values[0] = values[1]! / 2.0
                values[2] = 4.0 * π * pow(values[0]!, 2.0)
                values[3] = pow(values[0]!, 3.0) * π * 4.0 / 3.0
                return
            }
            if checkNil(n: 2){
                values[0] = pow(values[2]! / 4.0 / π , 1.0 / 2.0)
                values[1] = values[0]! * 2.0
                values[3] = pow(values[0]!, 3.0) * π * 4.0 / 3.0
                return
            }
            if checkNil(n: 3){
                values[0] = pow(values[3]! / π * 3.0 / 4.0, 1.0 / 3.0)
                values[1] = values[0]! * 2.0
                values[2] = 4.0 * π * pow(values[0]!, 2.0)
                return
            }
        }else{
            if checkNil(n: 0){
                values[1] = values[0]! * 2.0
                values[2] = 4.0 * pow(values[0]!, 2.0)
                values[3] = pow(values[0]!, 3.0) * 4.0 / 3.0
                return
                
            }
            if checkNil(n: 1){
                values[0] = values[1]! / 2.0
                values[2] = 4.0 * pow(values[0]!, 2.0)
                values[3] = pow(values[0]!, 3.0) * 4.0 / 3.0
                return
            }
            if checkNil(n: 2){
                values[0] = sqrt(values[2]!  / 4.0 )
                values[1] = values[0]! * 2.0
                values[3] = pow(values[0]!, 3.0) * 4.0 / 3.0
                return
            }
            if checkNil(n: 3){
                values[0] = pow(values[3]! * 3.0 / 4.0, 1.0 / 3.0)
                values[1] = values[0]! * 2.0
                values[2] = 4.0 * pow(values[0]!, 2.0)
                return
            }
        }
    }
    
    // "Cylinder":["r", "h", "Button Area", "Side Area", "Total Area"]
    func forCylinder(){
        if useπValue{

            if checkNil(n: 0) && checkNil(n: 1){
                cylinderInit(useπ: useπValue)
                return
            }
//
            if checkNil(n: 0) && checkNil(n: 3){
                values[1] = values[3]! / values[0]! / 2.0 / π
//                values[2] = pow(values[0]!, 2.0) * π
                cylinderInit(useπ: useπValue)
                return
            }
//
            if checkNil(n: 1) && checkNil(n: 3){
                values[0] = values[3]! / values[1]! /  2
                cylinderInit(useπ: true)
//                values[2] = pow(values[0]!, 2.0) * π
//                values[4] = 2.0 * values[2]! + values[3]!
                return
            }
        }else {
            
            if checkNil(n: 0) && checkNil(n: 1){
                cylinderInit(useπ: useπValue)
                return
            }
//
            if checkNil(n: 0) && checkNil(n: 3){
                values[1] = values[3]! / values[0]! / 2.0
//                values[2] = pow(values[0]!, 2.0) * π
                cylinderInit(useπ: useπValue)
                return
            }
//
            if checkNil(n: 1) && checkNil(n: 3){
                values[0] = values[3]! / values[1]! / 2
                cylinderInit(useπ: useπValue)
//                values[2] = pow(values[0]!, 2.0) * π
//                values[4] = 2.0 * values[2]! + values[3]!
                return
            }
        }
    }
    
    
    
    
    //"Cylinder":["r", "h", "Button Area", "Side Area", "Total Area"]
    func cylinderInit(useπ:Bool){
        
        if useπ{
            values[2] = pow(values[0]!, 2.0) * π
            values[3] = values[1]! * 2.0 * values[0]! * π
            values[4] = 2.0 * values[2]! + values[3]!
            return
        }else{
            values[2] = pow(values[0]!, 2.0)
            values[3] = values[1]! * 2.0 * values[0]!
            values[4] = 2.0 * values[2]! + values[3]!
            return
        }
    }
    
    
    
    func forTriangle(){
        //if perimeter and two side is known, then we kow the other side
        for n in 0..<3{
            if checkNil(n: 7) && checkNil(n: (n + 1) % 3) && checkNil(n: (n + 2) % 3){
                values[n] = values[7]! - values[(n + 1) % 3]! - values[(n + 2) % 3]!
            }
        }
        
        // if area and height are known, then we can known the base, which is "a"
        if checkNil(n: 8) && checkNil(n: 6){
            values[0] = values[8]! * 2.0 / values[6]!
        }
        
//        //if area and two sides are known, then we know the third side
//        for n in 0..<3{
//            if checkNil(n: 8) && checkNil(n: (n + 1) % 3) && checkNil(n: (n + 2) % 3){
//
//            }
//        }
// MARK - Need quadSolver
        
        //if two angle already known, then set three
        for n in 0..<3{
            if checkNil(n: 3 + (n + 1) % 3) && checkNil(n: 3 + (n + 2) % 3){
                values[3 + n] = (180.0 - values[3 + (n + 1) % 3]!) - values[3 + (n + 2) % 3]!
                //do not return!
            }
        }
        
        // SSS
        if checkNil(n: 0) && checkNil(n: 1) && checkNil(n: 2){
            values = triangleSolver().SSS(a: values[0]!, b: values[1]!, c: values[2]!)
            return
        }
        
        //SAS
        for n in 0..<3{
            if checkNil(n: (n + 2) % 3) && checkNil(n: 3 + n) && checkNil(n: (n + 1) % 3){
                values =  triangleSolver().SAS(input: values, center:n)
                return
            }
        }
        

        
        //if AAS or ASA
        if checkNil(n: 3) && checkNil(n: 4) && checkNil(n: 5){
             if checkNil(n: 0) || checkNil(n: 1) || checkNil(n: 2){
                 values = triangleSolver().AAAS(input: values)
                 return
             }
        }

        
        //HL
        for n in 0..<3{
            if let value = values[n + 3]{
                
                if value == 90.0 && checkNil(n: n) && (checkNil(n: (n + 1) % 3)){//
                    values[(n + 2) % 3] = sqrt(pow(values[n]!, 2.0) - pow(values[(n + 1) % 3]!, 2.0))
                    values = triangleSolver().SSS(a: values[0]!, b: values[1]!, c: values[2]!)
                    return
                }
                if value == 90.0 && checkNil(n: n) && (checkNil(n: (n + 2) % 3)){
                    values[(n + 1) % 3] = sqrt(pow(values[n]!, 2.0) - pow(values[(n + 2) % 3]!, 2.0))
                    values = triangleSolver().SSS(a: values[0]!, b: values[1]!, c: values[2]!)
                    return
                }
            }
        }
        
    
        //height and one angle side angle known
        var a1:Double?, a2:Double? //sides
        var A1:Double?, A2:Double? //angles
        var leftTriangle:Array<Double>, rightTriangle:Array<Double>
        //"Triangle":["a", "b", "c", "∠A", "∠B", "∠C", "height", "Perimeter", "Area"],
        if checkNil(n: 6) && checkNil(n: 4){//height and <B
            A1 = triangleSolver().findThirdAngle(d1: 90.0, d2: values[4]!)
            leftTriangle = triangleSolver().AAAS(input: [nil, nil, values[6], A1, values[4], Optional(90.0)])
            values[2] = leftTriangle[2] //know c in large triangle
            a1 = leftTriangle[0]
        }
        
        if checkNil(n: 6) && checkNil(n: 5){//height and <C
            A2 = triangleSolver().findThirdAngle(d1: 90.0, d2: values[5]!)
            rightTriangle = triangleSolver().AAAS(input: [nil, nil, values[6], A2, values[5], Optional(90.0)])
            values[1] = rightTriangle[1] //know b in large triangle
            a2 = rightTriangle[0]
        }
        
        //if known height and one AB
        if checkNil(n: 6) && checkNil(n: 2){//height and c
            a1 = sqrt(pow(values[2]!, 2.0) - pow(values[6]!, 2.0)) as Double?
            leftTriangle = triangleSolver().SSS(a: a1!, b: values[6]!, c: values[2]!)
            values[4] = leftTriangle[4]
            A1 = leftTriangle[3]
            a1 = leftTriangle[0]
        }
        //if known height and AC
        if checkNil(n: 6) && checkNil(n: 1){//height and b
            a1 = sqrt(pow(values[1]!, 2.0) - pow(values[6]!, 2.0))
            rightTriangle = triangleSolver().SSS(a: a1!, b: values[1]!, c: values[6]!)
            values[5] = rightTriangle[5]
            A2 = rightTriangle[3]
            a2 = rightTriangle[0]
        }
        
        if a1 != nil && a2 != nil{
            values[0] = a1! + a2!
        }
        
        if A1 != nil && A2 != nil{
            values[3] = A1! + A2!
        }
        
        if checkNil(n: 1) && checkNil(n: 2) && checkNil(n: 0){
            values = triangleSolver().SSS(a: values[0]!, b: values[1]!, c: values[2]!)
        }
        
    }
    
    func processDecimalAnswer(value:Double) -> String {
        
        //check whether the value is [positive] interger
        if floor(value) == value {
            return String(Int(value))
        }else{ //if is not a interger, then check whether need to hold decimal
            if let needRoundDecimal = UserDefaults.standard.object(forKey: "digitsSwitchStatus"){//if not, then if user did want to hold specific
                if needRoundDecimal as! Bool{
                    if let digitsHold = UserDefaults.standard.object(forKey: "holdDecimalDigits"){
                        return String(Double(round(pow(10.0, Double(digitsHold as! Int)) * value)/pow(10.0, Double(digitsHold as! Int))))
                    }else{//for user's first time
                        UserDefaults.standard.set(2, forKey: "holdDecimalDigits")
                        return processDecimalAnswer(value: value)
                    }
                }else{
                    return String(value)
                }
            }else{//for user's first time
                UserDefaults.standard.set(true, forKey: "digitsSwitchStatus")
                return processDecimalAnswer(value: value)
            }
        }
        

    }
    
    
}

