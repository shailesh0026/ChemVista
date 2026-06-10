//
//  QuizView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
// 

import SwiftUI
import ARKit

struct QuizView: View {
    @State private var viewModel: QuizViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showARView = false
    @State private var showARUnavailableAlert = false

    init(type: QuizType = .beginner) {
        _viewModel = State(wrappedValue: QuizViewModel(type: type))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 30)
                
                if viewModel.isQuizComplete {
                    Spacer()
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .accessibilityHidden(true)
                        
                        Text("Quiz Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text("\(viewModel.quizType.rawValue) Level")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                        
                        let percentage = Int(Double(viewModel.score) / Double(viewModel.totalQuestions) * 100)
                        VStack(spacing: 8) {
                            Text("\(viewModel.score) / \(viewModel.totalQuestions)")
                                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                                .foregroundColor(.white)
                                .accessibilityLabel("Score: \(viewModel.score) out of \(viewModel.totalQuestions)")
                            
                            Text("\(percentage)% Correct")
                                .font(.title3)
                                .foregroundColor(percentage >= 70 ? .green : (percentage >= 40 ? .yellow : .red))
                                .accessibilityLabel("\(percentage) percent correct")
                        }
                        .padding(.vertical, 12)
                        
                        VStack(spacing: 12) {
                            Button { viewModel.restartQuiz() } label: {
                                Text("Restart Quiz")
                                    .bold()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(AppButtonStyle())
                            .accessibilityLabel("Restart quiz")
                            .accessibilityHint("Starts from the first question")
                            
                            Button { dismiss() } label: {
                                Text("Back to Menu")
                                    .bold()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(AppButtonStyle())
                            .accessibilityLabel("Back to Practice menu")
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding()
                    Spacer()
                } else {
                    Text(viewModel.progressText)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 6)
                        .accessibilityLabel("Question \(viewModel.progressText)")
                    
                    Text(viewModel.questionText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        .accessibilityAddTraits(.isHeader)
                    
                    PracticeMolecule3DView(molecule: $viewModel.molecule, cameraDistance: 20)
                        .frame(height: 260)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .accessibilityLabel("3D model of the quiz molecule")
                        .accessibilityHint("Examine the molecule to identify it")
                        .accessibilityAddTraits(.isImage)
                    
                    Spacer()
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(viewModel.options, id: \.self) { option in
                            Button { viewModel.selectOption(option) } label: {
                                Text(option)
                                    .font(.title3)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(buttonColor(for: option))
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                            .buttonStyle(QuizOptionStyle())
                            .disabled(viewModel.isCorrect == true)
                            .accessibilityLabel(option)
                            .accessibilityValue(answerAccessibilityValue(for: option))
                            .accessibilityHint(viewModel.selectedOption == nil ? "Select this answer" : "")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    if let feedback = viewModel.feedbackMessage {
                        VStack(spacing: 10) {
                            Text(feedback)
                                .font(.headline)
                                .foregroundColor(viewModel.isCorrect == true ? .green : .red)
                                .transition(.scale)
                                .accessibilityLabel(feedback)
                                .accessibilityValue(viewModel.isCorrect == true ? "Correct" : "Incorrect")
                            
                            if viewModel.isCorrect == true {
                                Button { viewModel.loadNewQuestion() } label: {
                                    let isLast = viewModel.currentQuestion >= viewModel.totalQuestions
                                    Text(isLast ? "See Results" : "Next Question")
                                        .bold()
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.5))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .buttonStyle(AppButtonStyle())
                                .accessibilityLabel(viewModel.currentQuestion >= viewModel.totalQuestions ? "See Results" : "Next Question")
                                .accessibilityHint(viewModel.currentQuestion >= viewModel.totalQuestions ? "Shows your final score" : "Loads the next question")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                }
            }
        }
        .navigationTitle("\(viewModel.quizType.rawValue) Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.isQuizComplete {
                    Button {
                        if ARWorldTrackingConfiguration.isSupported {
                            showARView = true
                        } else {
                            showARUnavailableAlert = true
                        }
                    } label: {
                        Image(systemName: "arkit")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(ToolbarIconStyle())
                    .accessibilityLabel("View in AR")
                    .accessibilityHint("Opens augmented reality view of the quiz molecule")
                }
            }
        }
        .fullScreenCover(isPresented: $showARView) {
            PracticeARViewOnlySheet(
                molecule: $viewModel.molecule,
                title: ""
            )
        }
        .alert("AR Not Available", isPresented: $showARUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("AR requires a device with a supported chip.")
        }
    }
    
    func buttonColor(for option: String) -> Color {
        guard let selected = viewModel.selectedOption else {
            return Color.gray.opacity(0.2)
        }
        
        if viewModel.isCorrect == true {
            return option == viewModel.correctOption ? .green : .gray.opacity(0.3)
        } else {
            return option == selected ? .red : .gray.opacity(0.2)
        }
    }

    /// Returns an accessibility value string describing whether this option is correct/incorrect/unanswered.
    func answerAccessibilityValue(for option: String) -> String {
        guard viewModel.selectedOption != nil else { return "" }
        if viewModel.isCorrect == true {
            return option == viewModel.correctOption ? "Correct" : "Incorrect"
        } else {
            return option == viewModel.selectedOption ? "Incorrect — your selection" : ""
        }
    }
}

#Preview("QuizView") {
    NavigationStack {
        QuizView()
    }
    .preferredColorScheme(.dark)
}
