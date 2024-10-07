//
//  ContentView.swift
//  WordGarden
//
//  Created by Emerald on 20/9/24.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
	@State private var wordsGuessed = 0
	@State private var wordsMissed = 0
	@State private var currentWordIndex = 0
	@State private var wordToGuess = ""
	@State private var revealedWord = ""
	@State private var lettersGuessed = ""
	@State private var guessessRemaining = 8
	@State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
	@State private var guessedLetter = ""
	@State private var imageName = "flower8"
	@State private var playAgainHidden = true
	@State private var playAgainButtonLabel = "Another Word?"
	@State private var audioPlayer: AVAudioPlayer!
	@FocusState private var textFieldIsFocused: Bool
	
	private let wordsToGuess = ["SWIFT", "DOG", "CAT"]
	private let maximumGuessess = 8
	
	
	var body: some View {
		VStack {
			HStack{
				VStack(alignment: .leading)
				{
					Text("Words Guessed:\(wordsGuessed)")
					Text("Words Missed:\(wordsMissed)")
				}
				Spacer()
				VStack(alignment: .trailing) {
					Text("Words to Guess:\(wordsToGuess.count - (wordsGuessed + wordsMissed))")
					Text("Words in Game:\(wordsToGuess.count)")
				}
			}.padding(.horizontal)
			
			Spacer()
			Text(gameStatusMessage)
				.font(.title)
				.multilineTextAlignment(.center)
				.frame(height: 80)
				.minimumScaleFactor(0.5)
				.padding()
			Spacer()
			Text(revealedWord)
				.font(.title)
			
			if playAgainHidden {
				HStack{
					TextField("", text: $guessedLetter)
						.textFieldStyle(.roundedBorder)
						.frame(width: 30)
						.overlay {
							RoundedRectangle(cornerRadius: 5)
								.stroke(.gray, lineWidth: 2)
						}
						.keyboardType(.asciiCapable)
						.submitLabel(.done)
						.autocorrectionDisabled()
						.textInputAutocapitalization(.characters)
						.onChange(of: guessedLetter, initial: true) { _, _ in
							guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
							guard let lastChar = guessedLetter.last
							else {
								return
							}
							guessedLetter = String(lastChar).uppercased()
						}
						.onSubmit {
							guard guessedLetter != "" else {
								return
							}
							guessALetter()
							updateGamePlay()
						}
						.focused($textFieldIsFocused)
					
					Button("Guess a Letter"){
						guessALetter()
						updateGamePlay()
					}.buttonStyle(.bordered)
						.tint(.mint)
						.disabled(guessedLetter.isEmpty)
				}
			}
			else {
				Button(playAgainButtonLabel){
					//If all words have been guessed ...
					if currentWordIndex == wordsToGuess.count {
						currentWordIndex = 0
						wordsGuessed = 0
						wordsMissed = 0  
						playAgainButtonLabel = "Another Word?"
					}
					//Reset after a word was guessed or missed.
					wordToGuess = wordsToGuess[currentWordIndex]
					revealedWord = "_" + String(repeating: " _",count: wordToGuess.count-1)
					lettersGuessed = ""
					guessessRemaining = maximumGuessess
					imageName = "flower\(guessessRemaining)"
					gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
					playAgainHidden = true
				}.buttonStyle(.borderedProminent)
					.tint(.mint)
			}
			Spacer()
			Image(imageName)
				.resizable()
				.scaledToFit()
				.animation(.easeIn(duration: 0.75), value: imageName)
			Spacer()
		}
		.ignoresSafeArea(edges:.bottom)
		.onAppear (){
			wordToGuess = wordsToGuess[currentWordIndex]
			//Create a string from a repeating value
			revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
			guessessRemaining = maximumGuessess
		}
	}
	
	func guessALetter(){
		textFieldIsFocused = false
		lettersGuessed = lettersGuessed + guessedLetter //newly keyed in
		revealedWord = ""
		//loop through all letters in wordToGuess
		for letter in wordToGuess  {
			if (lettersGuessed.contains(letter))
			{
				revealedWord = revealedWord + "\(letter) "
				print("if\(revealedWord)")
			} else {
				//if not, add an underscore + a blank space, to revealedWord
				revealedWord = revealedWord + "_ "
				print("else\(revealedWord)")
			}
		}
		revealedWord.removeLast()
	}
	
	func playSound(soundName: String)	{
	 guard let soundFile = NSDataAsset(name: soundName) else {
		 print("Could not read file name \(soundName)")
		 return
	 }
	 do {
		 audioPlayer = try AVAudioPlayer(data: soundFile.data)
		 audioPlayer.play()
	 } catch {
		 print("ERROR: \(error.localizedDescription) creating audioPlayer.")
	 }
 }
	
	func updateGamePlay(){
	
		if !wordToGuess.contains(guessedLetter) {
			print("guessedLetter\(guessedLetter)")
			
			guessessRemaining -= 1
			//Animate crumbling leaf and play "incorrect" sound
			imageName = "wilt\(guessessRemaining)"
			playSound(soundName: "incorrect")
			
			//Delay change to flower image until after animation is done
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.75){
				imageName = "flower\(guessessRemaining)"
			}
			
		} else {
			print("guessedLetter\(guessedLetter)")
			playSound(soundName: "correct")
		}
		
		//when do we play another word?
		if !revealedWord.contains("_"){ //Guessed when no _ in revealedWord
			gameStatusMessage = "You've Guessed It! It Took you \(lettersGuessed.count) Guesses to Guess the Word."
			wordsGuessed += 1
			currentWordIndex += 1
			playAgainHidden = false
			playSound(soundName: "word-guessed")
			
		}else if guessessRemaining == 0 { // Word Missed
			gameStatusMessage = "So Sorry. You're All Out of Guessess."
			wordsMissed += 1
			currentWordIndex += 1
			playAgainHidden = false
			playSound(soundName: "word-not-guessed")
		}else{ // Keep guessing
			gameStatusMessage = "You've Made \(lettersGuessed.count) Guess\(lettersGuessed.count == 1 ? "": "es")"
		}
		if currentWordIndex == wordsToGuess.count {
			playAgainButtonLabel = "Restart Game?"
			gameStatusMessage = gameStatusMessage + "\nYou've Tried All of the Words. Restart from the Beginning?"
		}
		guessedLetter = ""
	}
}


#Preview {
	ContentView()
}
