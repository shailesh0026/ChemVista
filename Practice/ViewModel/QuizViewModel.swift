//
//  QuizViewModel.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import Observation



@Observable
class QuizViewModel {
    var molecule: PracticeMolecule = PracticeMolecule()
    var options: [String] = []
    var questionText: String = ""
    var feedbackMessage: String?
    var isCorrect: Bool?
    var selectedOption: String?
    var correctOption: String = ""
    var quizType: QuizType
    
    // Question progress tracking (15 questions per quiz)
    var currentQuestion: Int = 0
    var score: Int = 0
    var isQuizComplete: Bool = false
    var hasAttemptedWrong: Bool = false  // tracks if any wrong guess was made
    private var recentQuestions: [String] = []
    let totalQuestions: Int = 15
    
    // Progress text displayed below the quiz title (e.g. "3 of 15")
    var progressText: String {
        "\(currentQuestion) of \(totalQuestions)"
    }
    
    private let builder = PracticeMoleculeBuilder()
    
    init(type: QuizType = .beginner) {
        self.quizType = type
        loadNewQuestion()
    }
    
    func loadNewQuestion() {
        // Check if quiz is complete
        guard currentQuestion < totalQuestions else {
            isQuizComplete = true
            return
        }
        
        // Advance to next question
        currentQuestion += 1
        
        // Reset answer state
        feedbackMessage = nil
        isCorrect = nil
        selectedOption = nil
        hasAttemptedWrong = false
        builder.clear()
        
        generateQuestion()
    }
    
    private func generateQuestion() {
        var generatedName = ""
        var attempts = 0
        
        // It tries up to 10 times to build a new, unique molecule for the user to name.
        while attempts < 10 {
            builder.clear()
            
            switch quizType {
            case .beginner: // Level 1: Alkanes & Basic Chains
                if Bool.random() {
                    let chainLength = Int.random(in: 2...6)
                    buildAlkane(length: chainLength)
                } else {
                    buildBranchedAlkane()
                }
                
            case .intermediate: // Level 2: Alkenes & Alkynes
                if Bool.random() {
                    let chainLength = Int.random(in: 3...6)
                    buildAlkene(length: chainLength)
                } else {
                    let chainLength = Int.random(in: 3...6)
                    buildAlkyne(length: chainLength)
                }
                
            case .advanced: // Level 3: Enynes (Complex structure)
                let chainLength = Int.random(in: 4...7)
                buildComplexStructure(length: chainLength)
            }
            
            builder.fillHydrogens()
            self.molecule = builder.molecule
            generatedName = PracticeIUPACNamingLogic.generateName(for: molecule)
            
            if !recentQuestions.contains(generatedName) {
                recentQuestions.append(generatedName)
                if recentQuestions.count > 5 { // Keep a buffer of 5 to avoid quick repeats
                    recentQuestions.removeFirst()
                }
                break
            }
            attempts += 1
        }
        
        correctOption = generatedName
        
        // random names of different lengths that match the quiz difficulty
        var wrongOptions: Set<String> = []
        while wrongOptions.count < 3 {
            let wrongLength = Int.random(in: 1...10)
            let suffix: String
            switch quizType {
            case .beginner: suffix = "ane"
            case .intermediate: suffix = Bool.random() ? "ene" : "yne"
            case .advanced:
                let choices = ["enyne", "adiene", "diyne", "ene", "yne"]
                suffix = choices.randomElement()!
            }
            let wrongName = PracticeIUPACNamingLogic.getPrefix(for: wrongLength) + suffix
            if wrongName != generatedName {
                wrongOptions.insert(wrongName)
            }
        }
        
        options = (Array(wrongOptions) + [generatedName]).shuffled()
        questionText = "What is the IUPAC name for this structure?"
    }
    
    private func buildAlkane(length: Int) {
        var previous: PracticeAtom?
        for i in 0..<length {
            let atom = builder.addAtom(element: .carbon, position: SIMD3<Float>(Float(i)*3.0, (i%2==0 ? 0 : 1.2), 0))
            if let p = previous { _ = builder.addBond(from: p, to: atom, type: .single) }
            previous = atom
        }
    }
    
    private func buildAlkyne(length: Int) {
        var previous: PracticeAtom?
        let tripleAt = Int.random(in: 0..<length-1)
        for i in 0..<length {
            let atom = builder.addAtom(element: .carbon, position: SIMD3<Float>(Float(i)*3.0, 0, 0)) // Linear for better look
            if let p = previous {
                let type: PracticeBond.BondType = (i-1 == tripleAt) ? .triple : .single
                _ = builder.addBond(from: p, to: atom, type: type)
            }
            previous = atom
        }
    }
    
    private func buildAlkene(length: Int) {
        var previous: PracticeAtom?
        let doubleAt = Int.random(in: 0..<length-1)
        for i in 0..<length {
            let atom = builder.addAtom(element: .carbon, position: SIMD3<Float>(Float(i)*3.0, (i%2==0 ? 0 : 1.2), 0))
            if let p = previous {
                let type: PracticeBond.BondType = (i-1 == doubleAt) ? .double : .single
                _ = builder.addBond(from: p, to: atom, type: type)
            }
            previous = atom
        }
    }
    
    private func buildComplexStructure(length: Int) {
        var previous: PracticeAtom?
        // Place a double and a triple bond. Ensure they are separated by at least one single bond.
        let doubleAt = 0
        let tripleAt = length - 2
        for i in 0..<length {
            let atom = builder.addAtom(element: .carbon, position: SIMD3<Float>(Float(i)*3.0, 0, 0)) // Linear for visual clarity
            if let p = previous {
                let type: PracticeBond.BondType
                if i-1 == doubleAt {
                    type = .double
                } else if i-1 == tripleAt {
                    type = .triple
                } else {
                    type = .single
                }
                _ = builder.addBond(from: p, to: atom, type: type)
            }
            previous = atom
        }
    }
    
    private func buildBranchedAlkane() {
        let mainLen = Int.random(in: 4...6)
        var mainChain: [PracticeAtom] = []
        for i in 0..<mainLen {
            let atom = builder.addAtom(element: .carbon, position: SIMD3<Float>(Float(i)*3.0, (i%2==0 ? 0 : 1.2), 0))
            if let p = mainChain.last { _ = builder.addBond(from: p, to: atom, type: .single) }
            mainChain.append(atom)
        }
        
        // Add one methyl branch
        let branchAt = Int.random(in: 1..<mainLen-1)
        let parent = mainChain[branchAt]
        let sidePos = parent.position + SIMD3<Float>(0, (branchAt%2==0 ? -3.0 : 3.0), 0)
        let branch = builder.addAtom(element: .carbon, position: sidePos)
        _ = builder.addBond(from: parent, to: branch, type: .single)
    }
    
    private func buildAlcohol() {
        let chainLen = Int.random(in: 1...4)
        var mainChain: [PracticeAtom] = []
        for i in 0..<chainLen {
            let atom = builder.addAtom(element: .carbon, position: SIMD3<Float>(Float(i)*3.0, (i%2==0 ? 0 : 1.2), 0))
            if let p = mainChain.last { _ = builder.addBond(from: p, to: atom, type: .single) }
            mainChain.append(atom)
        }
        
        // Add OH group at the end or middle
        guard let lastCarbon = mainChain.last else { return }
        let oPos = lastCarbon.position + SIMD3<Float>(3.0, 0, 0)
        let oAtom = builder.addAtom(element: .oxygen, position: oPos)
        _ = builder.addBond(from: lastCarbon, to: oAtom, type: .single)
    }
    
    func selectOption(_ option: String) {
        selectedOption = option
        if option == correctOption {
            isCorrect = true
            // Only award a point if no wrong attempts were made for this specific question.
            if !hasAttemptedWrong {
                score += 1
            }
            feedbackMessage = "Correct! Well done."
        } else {
            isCorrect = false
            hasAttemptedWrong = true
            feedbackMessage = "Not quite. Try again!"
        }
    }
    
    // Reset the quiz to question 1 for the same difficulty level
    func restartQuiz() {
        currentQuestion = 0
        score = 0
        isQuizComplete = false
        hasAttemptedWrong = false
        loadNewQuestion()
    }
}
