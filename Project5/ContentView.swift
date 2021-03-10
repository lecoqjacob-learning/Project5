//
//  ContentView.swift
//  Project5
//
//  Created by Jacob LeCoq on 2/21/21.
//

import SwiftUI

struct ContentView: View {
//    @State private var usedWords = [String]()
    @State private var usedWords = [String]()
    @State private var usedWords2 = [String](repeating: "test", count: 40)
    let colors: [Color] = [.red, .green, .blue, .orange, .pink, .purple, .yellow]
    
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }

        usedWords.insert(answer, at: 0)
        newWord = ""
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }

    func isReal(word: String) -> Bool {
        guard word.count > 3 else {
            return false
        }

        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)

        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }

    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"

                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()

                //Project 18 - Challenge 2
                GeometryReader { mainView in
                    List(usedWords2, id: \.self) { word in
                        GeometryReader { innerView in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                    .foregroundColor(self.getColor(mainProxy: mainView, innerProxy: innerView))
                                Text(word)
                            }
                            .frame(width: innerView.size.width, alignment: .leading)
                            .offset(x: self.getOffset(mainProxy: mainView, innerProxy: innerView), y: 0)
                        }
                    }
                }
            }
            .navigationBarTitle(rootWord)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Restart Game") {
                        startGame()
                    }
                }
            }
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func getColor(mainProxy: GeometryProxy,innerProxy: GeometryProxy) -> Color{
        let listHeight = mainProxy.size.height
        let listStart = mainProxy.frame(in: .global).minY
        let itemStart = innerProxy.frame(in: .global).minY
        
        let itemPercent =  (itemStart - listStart) / listHeight * 100
        let colorValue = Double(itemPercent / 100)
        
        return Color(red: 2 * (1 - colorValue), green: 0, blue: 2 * colorValue, opacity: 1)
    }
    
    func getOffset(mainProxy: GeometryProxy,innerProxy: GeometryProxy) -> CGFloat{
        let listHeight = mainProxy.size.height
        let listStart = mainProxy.frame(in: .global).minY
        let itemStart = innerProxy.frame(in: .global).minY
        
        let itemPercent =  (itemStart - listStart) / listHeight * 100

        let thresholdPercent: CGFloat = 60
        let indent: CGFloat = 5

        if itemPercent > thresholdPercent {
            return (itemPercent - (thresholdPercent - 1)) * indent
        }

        return 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
