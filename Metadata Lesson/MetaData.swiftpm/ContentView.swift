/* ********************************
 
******************************** */

import SwiftUI
import MapKit

/*
The first struct, "ContentView," creates the main view of the app, which displays the selected image, metadata, and location information. It also contains a button that, when pressed, shows the ImagePicker view. 
*/
struct ContentView: View {
    //state variable for holding the selected image
    @State private var image: UIImage? 
    
    //state variable for holding the metadata of the image
    @State private var metadata: String = ""
    
    //state variable for holding the location of the image
    @State private var location: CLLocationCoordinate2D?
    
    //state variable for determining if the image picker is shown
    @State private var isShown = false 
    
    var body: some View {
        VStack {
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("No image selected")
            }
            
            TextField("Metadata", text: $metadata)
                .disabled(true)
                .padding()
            
            if location != nil {
                Map(coordinateRegion: Binding<MKCoordinateRegion>(
                    get: {
                        MKCoordinateRegion(center: self.location!, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    },
                    set: { _ in }
                ))
                .frame(width: 400, height: 300)
            } else {
                Text("No location information available")
            }
            
            Button(action: {
                //when button is pressed, set isShown to true
                self.isShown = true 
            }) {
                Text("Select Image")
            }
            //if isShown is true, show the ImagePicker view
            if isShown {
                ImagePicker(image: $image, metadata: $metadata, location: $location, isShown: $isShown) 
                
            }
        }
    }
}

/*
 The second struct, "ImagePicker," is responsible for displaying the ImagePickerView struct.
 */

struct ImagePicker: View {
    //bound variable to hold the selected image
    @Binding var image: UIImage? 
    
    //bound variable to hold the metadata of the selected image
    @Binding var metadata: String 
    
    //bound variable to hold the location of the selected image
    @Binding var location: CLLocationCoordinate2D? 
    
    //bound variable to hold the state of if the ImagePickerView is shown
    @Binding var isShown: Bool 
    
    var body: some View {
        VStack {
            //Initialize the ImagePickerView and pass in the bound variables
            ImagePickerView(image: $image, metadata: $metadata, location: $location, isShown: $isShown) 
        }
    }
}

/*
 The third struct, "ImagePickerView," is a UIViewControllerRepresentable that creates and manages the UIImagePickerController, which allows the user to select an image from their photo library. The struct also has a coordinator that handles the delegate methods of the UIImagePickerController, which sets the selected image, metadata, and location information to the appropriate bindings and dismisses the image picker when the user finishes picking an image.
 */


struct ImagePickerView: UIViewControllerRepresentable {
    // Reference to the environment variable presentationMode
    @Environment(\.presentationMode) var presentationMode
    // Binding variable for image
    @Binding var image: UIImage?
    // Binding variable for metadata
    @Binding var metadata: String
    // Binding variable for location
    @Binding var location: CLLocationCoordinate2D?
    // Binding variable for isShown
    @Binding var isShown: Bool
    
    // Creates a UIImagePickerController and sets the sourceType and delegate
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    // Not used in this example
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    // Creates a Coordinator object
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // Coordinator class that conforms to UIImagePickerControllerDelegate and UINavigationControllerDelegate
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        // Reference to parent view
        var parent: ImagePickerView
        // Reference to presentationMode binding
        var presentationMode: Binding<PresentationMode>
        
        // Initializer that sets the parent and presentationMode variables
        init(parent: ImagePickerView) {
            self.parent = parent
            self.presentationMode = parent.presentationMode
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // check if original image is present in info dictionary
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            // check if imageURL is present in info dictionary
            if let imageURL = info[.imageURL] as? URL {
                let options = [kCGImageSourceShouldCache: false] as CFDictionary
                guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, options) else { return }
                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, options) as? [CFString: Any]
                // check if GPS data is present in image properties
                if let gpsData = imageProperties?[kCGImagePropertyGPSDictionary] as? [CFString: Any] {
                    let latitude = gpsData[kCGImagePropertyGPSLatitude] as? CLLocationDegrees ?? 0.0
                    let longitude = gpsData[kCGImagePropertyGPSLongitude] as? CLLocationDegrees ?? 0.0
                    parent.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                // check if metadata is present in image properties
                if let metadata = imageProperties?[kCGImagePropertyExifDictionary] as? [CFString: Any] {
                    parent.metadata = "\(metadata)"
                }
            }
            parent.isShown = false
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
}
