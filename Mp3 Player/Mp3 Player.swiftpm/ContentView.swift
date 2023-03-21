import SwiftUI

//Imported Package - https://github.com/twostraws/Subsonic
import Subsonic

struct ContentView: View {
    // Initialize an empty array to hold the file names
    var mp3Files = [String]()
    
    // Create a state variable to hold the selected file name
    @State var selectedFile: String? = nil
    
    // Initialize the view and populate mp3Files array with .mp3 files in the resources directory
    init() {
        guard let resourcesDir = Bundle.main.resourcePath else {
            print("Unable to get reference to Resources directory")
            return
        }
        
        let directoryEnumerator = FileManager.default.enumerator(atPath: resourcesDir)
        
        while let file = directoryEnumerator?.nextObject() as? String {
            if file.hasSuffix(".mp3") {
                mp3Files.append(file)
            }
        }
    }
    
    // Define the view body
    var body: some View {
        List {
            // Loop through the mp3Files array and display the files in a list
            ForEach(mp3Files, id: \.self) { mp3File in
                HStack {
                    // Display the file name with black color unless it's selected
                    Text(mp3File)
                        .foregroundColor(mp3File == selectedFile ? .gray: .black)
                    
                    Spacer()
                    
                    // Display the play/stop icon with black color unless it's selected
                    Image(systemName: mp3File == selectedFile ? "stop.fill" : "play.fill")
                        .foregroundColor(mp3File == selectedFile ? .gray: .black)
                }
                .padding(20)
                // When a file is tapped, either play or stop the sound depending on whether it's selected or not
                .onTapGesture {
                    if selectedFile == mp3File {
                        self.stop(sound: mp3File)
                        selectedFile = nil
                    } else {
                        self.play(sound: mp3File)
                        selectedFile = mp3File
                    }
                }
            }
        }
    }
    
    // Define a function to play the selected sound
    func playSound(soundFile: String) {
        // Play the selected sound
        self.play(sound: soundFile)
    }
    
    // Define a function to stop the selected sound
    func stopSound(soundFile: String) {
        // Stop the selected sound
        self.stop(sound: soundFile)
    }
}
