//
//  Calculatrix.swift
//  Calculatrix
//
//  Created by Computação Gráfica 2 on 08/05/15.
//  Copyright (c) 2015 Leo Neves. All rights reserved.
//

import Foundation



class Calculatrix
{
    private enum Op: Printable
    {
        case Operando(Double)
        case operacao0(String, () -> Double)
        case operacao1(String, Double -> Double)
        case operacao2(String, (Double, Double) -> Double)
        case Variavel(String)
        
        var description: String {
            get {
                switch self {
                case .Operando(let operando):
                    return "\(operando)"
                case .operacao1(let nome, _):
                    return nome
                case .operacao2(let nome, _):
                    return nome
                case .operacao0(let nome, _):
                    return nome
                case .Variavel(let nome):
                    return nome
                    
                }
            }
        }
    }
    
    private var Pilha = [Op]()
    private var operacoes = [String:Op]()
    private var variaveis = [String: Double]()
    
    func getVariavel(nome: String) -> Double? {
        return variaveis[nome]
    }
    
    func setVariavel(nome: String, value: Double) {
        variaveis[nome] = value
    }
    
    func clearVariavel() {
        variaveis.removeAll()
    }
    
    func ZeraPilha() {
        Pilha.removeAll()
    }
    
    func clearAll() {
        clearVariavel()
        ZeraPilha()
    }
    
    init() {
        func adc (op: Op) {
            operacoes[op.description] = op
        }
        adc(Op.operacao2("×", *))
        adc(Op.operacao2("÷", { $1 / $0 }))
        adc(Op.operacao2("+", +))
        adc(Op.operacao2("−", { $1 - $0 }))
        adc(Op.operacao1("SQRT", sqrt))
        adc(Op.operacao1("SEN", sin))
        adc(Op.operacao1("COS", cos))
        adc(Op.operacao0("π", { M_PI }))

    }
    
    
    typealias PropertyList = AnyObject
    
    var program:PropertyList {
        get {
            return Pilha.map{$0.description}
        }
        set{
            if let opSnomes = newValue as? Array<String> {
                
                var AddPilha = [Op]()
                for opSnome in opSnomes {
                    if let op = operacoes[opSnome]{
                        AddPilha.append(op)
                    } else if let operando = NSNumberFormatter().numberFromString(opSnome)?.doubleValue {
                        AddPilha.append(.Operando(operando))
                    }
                }
                Pilha = AddPilha
            }
        }
    }
    
    var printa: String {
        get {
            let (result, remainder) = printaB(Pilha)
            return result ?? ""
        }
    }
    
    private func printaB(ops: [Op]) -> (result: String?, nextOperacao: [Op]) {
        let (result, reminder) = printaC(ops)
        if !reminder.isEmpty {
            let (current, reminderCurrent) = printaB(reminder)
            return ("\(current!), \(result!)",reminderCurrent)
        }
        return (result,reminder)
    }
    
    var description: String {
        get {
            var (result, remainder) = ("", Pilha)
            var current: String?
            do {
                (current, remainder) = printaC(remainder)
                result = result == "" ? current! : "\(current!), \(result)"
            } while remainder.count > 0
            return result
        }
    }
    
    private func printaC(ops: [Op]) -> (result: String?, nextOperacao: [Op]) {
        if !ops.isEmpty {
            var nextOperacao = ops
            let op = nextOperacao.removeLast()
            switch op {
                
            case .Operando(let operando):
                return ( numberFormatter().stringFromNumber(operando), nextOperacao)
                
            case .operacao0(let nome, _):
                return (nome, nextOperacao);
                
            case .operacao1(let nome, _):
                let resultadoOP = printaC(nextOperacao)
                if let operando = resultadoOP.result {
                    return ("\(nome)(\(operando))", resultadoOP.nextOperacao)
                }
                
            case .operacao2(let nome, _):
                let op1faz = printaC(nextOperacao)
                if var operando1 = op1faz.result {
                    if nextOperacao.count - op1faz.nextOperacao.count > 2 {
                        operando1 = "(\(operando1))"
                    }
                    let op2faz = printaC(op1faz.nextOperacao)
                    if let operando2 = op2faz.result {
                        return ("\(operando2) \(nome) \(operando1)", op2faz.nextOperacao)
                    }
                }
                
            case .Variavel(let nome):
                return (nome, nextOperacao)
            }
        }
        return ("?", ops)
    }
    
    private func calcular(ops: [Op]) -> (result: Double?, nextOperacao: [Op]) {
        if !ops.isEmpty {
            var nextOperacao = ops
            let op = nextOperacao.removeLast()
            switch op {
            case .Operando(let operando):
                return (operando, nextOperacao)
                
            case .operacao0(_, let operacao):
                return (operacao(), nextOperacao)
                
            case .operacao1(_, let operacao):
                let resultadoOP = calcular(nextOperacao)
                if let operando = resultadoOP.result {
                    return (operacao(operando), resultadoOP.nextOperacao)
                }
            case .operacao2(_, let operacao):
                let op1faz = calcular(nextOperacao)
                if let operando1 = op1faz.result {
                    let op2faz = calcular(op1faz.nextOperacao)
                    if let operando2 = op2faz.result {
                        return (operacao(operando1, operando2), op2faz.nextOperacao)
                    }
                }
            case .Variavel(let nome):
                return (variaveis[nome], nextOperacao)
                
            }
        }
        return (nil, ops)
    }
    
    func calcular() -> Double? {
        let (result, remainder) = calcular(Pilha)
        return result
    }
    
    func pushOperando(operando: Double) -> Double? {
        Pilha.append(Op.Operando(operando))
        return calcular()
    }
    
    func pushOperando(nome: String) -> Double? {
        Pilha.append(Op.Variavel(nome))
        return calcular()
    }
    
    func executaOP(nome: String) -> Double? {
        if let operacao = operacoes[nome] {
            Pilha.append(operacao)
        }
        return calcular()
    }
    
    func PilhaToString() -> String {
        return Pilha.isEmpty ? "" : " ".join(Pilha.map{ $0.description })
    }
    
    func numberFormatter () -> NSNumberFormatter{
        let numberFormatterLoc = NSNumberFormatter()
        numberFormatterLoc.numberStyle = .DecimalStyle
        numberFormatterLoc.maximumFractionDigits = 10
        numberFormatterLoc.groupingSeparator = " "
        return numberFormatterLoc
    }
    
}