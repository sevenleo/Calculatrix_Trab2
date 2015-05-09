//
//  ViewController.swift
//  Calculatrix
//
//  Created by Leo Neves on 4/10/15.
//  Copyright (c) 2015 Leo Neves. All rights reserved.
//


import UIKit

class ViewController: UIViewController
{
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    let decimalSeparator =  NSNumberFormatter().decimalSeparator ?? "."
    let limite: Int = 38

    var userIsInTheMiddleOfTypingANumber = false
    var calcula = Calculatrix()

    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
      
        if userIsInTheMiddleOfTypingANumber {
            
            if (digit == ".") && (display.text?.rangeOfString(".") != nil) { return }
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit != ".") && ((display.text == "0") || (display.text == "-0"))
            { display.text = digit ; return }
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
            history.text = calcula.description != "?" ? calcula.description : " "
        }
    }
    
    
    @IBAction func operando(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operacao = sender.currentTitle {
            if let result = calcula.executaOP(operacao) {
                Mostra = result
            } else {
                Mostra = nil
            }
            history.text = history.text!         }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let valor = Mostra {
            Mostra = calcula.pushOperando(valor)
        } else {
            Mostra = nil
        }
    }
    
    @IBAction func setVariavel(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        
        let qual = dropFirst(sender.currentTitle!)
        if let value = Mostra {
            calcula.setVariavel(qual, value: value)
            Mostra = calcula.calcular()
        }
    }
    
    @IBAction func pushVariavel(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        Mostra = calcula.pushOperando(sender.currentTitle!)
    }
    
    @IBAction func ClearPilha(sender: AnyObject) {
        calcula.ZeraPilha()
        Mostra = nil

    }

    @IBAction func clearAll(sender: AnyObject) {
        calcula.clearAll()
        Mostra = nil
    }
    
   
    
    var Mostra: Double? {
        get {
            if let displayText = display.text {
                return numberFormatter().numberFromString(displayText)?.doubleValue
            }
            return nil
        }
        set {
            if (newValue != nil) {
                display.text = numberFormatter().stringFromNumber(newValue!)
            } else {
                display.text = " "
            }
            userIsInTheMiddleOfTypingANumber = false
            history.text = calcula.printa + " ="
            history.text = rolatexto(history.text!)
        }
    }
    
    func numberFormatter () -> NSNumberFormatter{
        let numberFormatterLoc = NSNumberFormatter()
        numberFormatterLoc.numberStyle = .DecimalStyle
        numberFormatterLoc.maximumFractionDigits = 10
        numberFormatterLoc.notANumberSymbol = "Error"
        numberFormatterLoc.groupingSeparator = " "
        return numberFormatterLoc
    }
    
    func rolatexto (text: String ) -> String {
        var linha = text
        let countText = count(linha)
        if countText > limite {
            linha = linha[advance(linha.startIndex,
                countText - limite )..<linha.endIndex]
            let StringArray = linha.componentsSeparatedByString(" ")
            var StringArray1 = StringArray[1..<StringArray.count]
            if !StringArray1.isEmpty { linha =  " ".join(StringArray1)}
            linha =  "... " + linha
        }
        return linha
    }
}

