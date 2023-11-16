//
//  ViewController.swift
//  RubbishTestApp
//
//  Created by Emin Israfil on 11/14/23.
//


import UIKit
import AVFoundation
import FirebaseCore
import SnapKit
import FirebaseStorage
//import FirebaseStorage
//import FirebaseStorage


class ViewController: UIViewController, UINavigationControllerDelegate {
    // Camera and UI elements
    var cameraView: UIView!
    var sendPhotoButton: UIButton!
    var sendExistingPhotoButton: UIButton!
    var cloudFunctionTestButton1: UIButton!
    var cloudFunctionTestButton2: UIButton!
    
    
    // Camera capture session
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var recycleMode: RecycleMode = .scanItem
    var playbackManager: VoicePlayBackManager?
    private var instructionLabel: UILabel!
    private var askUserToSubmitStatsURL: URL?
    private var sayCheeseURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraView()
        setupButtons()
        // Additional setup
    }
    
    // Actions
    
    func uploadPhoto(_ imageData: Data) {
        // Assuming you have a storage reference set up
        let storageRef = Storage.storage().reference()
        let photoRef = storageRef.child("photos/\(UUID().uuidString).jpg")
        
        // Upload the photo
        photoRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Error uploading photo: \(String(describing: error))")
                return
            }
            
            // Fetch the download URL
            photoRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error fetching download URL: \(String(describing: error))")
                    return
                }
                
                // Call cloud function with the URL
                self.callCloudFunction(with: downloadURL)
            }
        }
    }
    
    func callCloudFunction(with photoURL: URL) {
        // THIS NEEDS TO BE UPDATED With the correct route
        let cloudFunctionURL = URL(string: "https://us-central1-your-project-id.cloudfunctions.net/yourFunction")!
        
        // Create the request
        var request = URLRequest(url: cloudFunctionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["photoURL": photoURL.absoluteString]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Error: Could not create request body")
            return
        }
        
        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error calling cloud function: \(String(describing: error))")
                return
            }
            
            print(response)
            print(data)
            print(error)
        }
        task.resume()
    }
    
    
    // Button action methods
    @objc func sendPhotoButtonTapped() {
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc func sendExistingPhotoButtonTapped() {
        guard let image = UIImage(named: "trashpile") else {
            print("Error: Image not found in assets")
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to JPEG")
            return
        }

        // Encode the image data in base64
        let base64String = imageData.base64EncodedString()

        // Prepare the request for the cloud function
        let url = URL(string: "https://us-central1-your-project-id.cloudfunctions.net/yourFunction")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the JSON body with the base64 encoded string
        let jsonBody: [String: Any] = ["image": base64String]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            print("Error: Could not create JSON body")
            return
        }

        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error calling cloud function: \(String(describing: error))")
                return
            }

            // ...
            
            print(response)
            print(data)
            print(error)
            
            // Check for a valid HTTP response
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    // Assuming the response is a JSON object
                    if let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Handle the parsed data
                        print("Response: \(responseObject)")
                        
                        // If you need to update the UI based on this response,
                        // make sure to dispatch that on the main thread
                        DispatchQueue.main.async {
                            // Update your UI here
                        }
                    }
                } catch let parsingError {
                    print("Error parsing response: \(parsingError)")
                }
            } else {
                print("Unexpected response from the server")
            }
            
        }
        task.resume()
    }
    
    @objc func cloudFunctionTestButton1Tapped() {
        // THIS NEEDS TO BE UPDATED With the correct route!!!!!!
        let cloudFunctionURL = URL(string: "https://us-central1-your-project-id.cloudfunctions.net/test")!
        
        // Create the request
        var request = URLRequest(url: cloudFunctionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["TEST": "TESTBODY"]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Error: Could not create request body")
            return
        }
        
        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error calling cloud function: \(String(describing: error))")
                return
            }
            
            // Handle the response from the cloud function
            // ...
            
            print(response)
            print(data)
            print(error)
            
            // Check for a valid HTTP response
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    // Assuming the response is a JSON object
                    if let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Handle the parsed data
                        print("Response: \(responseObject)")
                        
                        // If you need to update the UI based on this response,
                        // make sure to dispatch that on the main thread
                        DispatchQueue.main.async {
                            // Update your UI here
                        }
                    }
                } catch let parsingError {
                    print("Error parsing response: \(parsingError)")
                }
            } else {
                print("Unexpected response from the server")
            }
            

        }
        task.resume()
    }
    
    @objc func cloudFunctionTestButton2Tapped() {
        // Implementation for cloud function test 2
    }
}


extension ViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error: Could not obtain photo data")
            return
        }
        
        // Here you can process the image if needed
        
        // Proceed to upload the photo
        uploadPhoto(imageData)
    }
    
    func setupCameraView() {
        // Initialize cameraView and add it to the main view
        cameraView = UIView(frame: view.bounds)
        view.addSubview(cameraView)
        
        // Start configuring the capture session
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        // Set up the camera input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            print("Error: Could not create video input or add it to the session")
            return
        }
        captureSession.addInput(videoInput)
        
        // Set up the photo output
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            print("Error: Could not add photo output to the session")
            return
        }
        
        // Commit configuration
        captureSession.commitConfiguration()
        
        // Set up the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        
        // Start the capture session
        captureSession.startRunning()
    }
    
    func setupButtons() {
        sendPhotoButton = UIButton(type: .system)
        sendExistingPhotoButton = UIButton(type: .system)
        cloudFunctionTestButton1 = UIButton(type: .system)
        cloudFunctionTestButton2 = UIButton(type: .system)
        
        // Configure buttons
        configureButton(sendPhotoButton, title: "Send Photo", action: #selector(sendPhotoButtonTapped))
        configureButton(sendExistingPhotoButton, title: "Send Existing", action: #selector(sendExistingPhotoButtonTapped))
        configureButton(cloudFunctionTestButton1, title: "Test 1", action: #selector(cloudFunctionTestButton1Tapped))
        configureButton(cloudFunctionTestButton2, title: "Test 2", action: #selector(cloudFunctionTestButton2Tapped))
        
        // Add buttons to the view
        view.addSubview(sendPhotoButton)
        view.addSubview(sendExistingPhotoButton)
        view.addSubview(cloudFunctionTestButton1)
        view.addSubview(cloudFunctionTestButton2)
        
        // Layout buttons
        sendPhotoButton.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.left.equalTo(view.snp.left).offset(5)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        sendExistingPhotoButton.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.left.equalTo(sendPhotoButton.snp.right).offset(5)
            make.bottom.equalTo(sendPhotoButton.snp.bottom)
        }
        
        cloudFunctionTestButton1.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.left.equalTo(sendExistingPhotoButton.snp.right).offset(5)
            make.bottom.equalTo(sendExistingPhotoButton.snp.bottom)
        }
        
        cloudFunctionTestButton2.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.left.equalTo(cloudFunctionTestButton1.snp.right).offset(5)
            make.right.lessThanOrEqualTo(view.snp.right).offset(-20)
            make.bottom.equalTo(cloudFunctionTestButton1.snp.bottom)
        }
    }
    
    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 35 // Half of height and width to make it circular
        button.addTarget(self, action: action, for: .touchUpInside)
    }
    
    
    enum RecycleMode {
        
        case scanItem
        case getCharicature
    }
    
    private func sendPhotoToDalle(image: UIImage) {
        showWholeScreenLoadingIndicator("RecycleGPT ImageGen 🤖♻️")
        sendPhotoToDalle(image: image) { result in
            DispatchQueue.main.async {
                self.hideWholeScreenLoadingIndicator()
                switch result {
                case .success(let response):
                    print(response)
                    //toggleRecycleMode()

                    if let urlString = self.parseURLFromDalleResponse(dalleResponse: response), let url = URL(string: urlString) {
                        print("URL: \(url)")
                        let yourVC = CharacterViewController(image: nil, url: url)
                        DispatchQueue.main.async {
                            self.present(yourVC, animated: true, completion: nil)
                        }
                        
                    } else {
                        print("Failed to parse URL.")
                    }

                case .failure(let error):
                    print(error)
                }
            }
            }
    }
    
    private func sendPhotoToDalle(image: UIImage, completion: @escaping (Result<String, NetworkingError>) -> Void) {
        uploadImageAndProcess(image) { result in
            switch result {
            case .success(let imageURL):
                guard let url = URL(string: "https://us-central1-rubbish-ee2d0.cloudfunctions.net/imageCreator") else {
                    completion(.failure(.generic("Doesnt work")))
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: Any] = ["imageUrl": imageURL]
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        completion(.failure(.generic("error: \(error)")))
                        return
                    }
                    guard let data = data else {
                        completion(.failure(.generic("error: \(error)")))
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        completion(.failure(.generic("Fail httpStatus")))
                        return
                    }

                    if let resultString = String(data: data, encoding: .utf8) {
                        completion(.success(resultString))
                    } else {
                        completion(.failure(.generic(" failed to decode")))
                    }
                }

                task.resume()
            case .failure(let fail):
                print(fail)
            }
        }
    }
    
    struct DalleResponse: Decodable {
        let image: [ImageItem]
    }

    struct ImageItem: Decodable {
        let revised_prompt: String
        let url: String
    }
    

    func parseURLFromDalleResponse(dalleResponse: String) -> String? {
        let decoder = JSONDecoder()

        guard let data = dalleResponse.data(using: .utf8) else {
            print("Error: Couldn't convert string to Data")
            return nil
        }

        do {
            let response = try decoder.decode(DalleResponse.self, from: data)
            return response.image.first?.url
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }
    
    enum BinType: String {
        case trash = "trash"
        case recycling = "recycling"
        case compost = "compost"
        case hazardous = "special"
    }
    
    func incrementStat(for binType: BinType) {
        switch binType {
            case .trash:
                Defaults[\.trashStats] += 1
            case .recycling:
                Defaults[\.recycleStats] += 1
            case .compost:
                Defaults[\.compostStats] += 1
            case .hazardous:
                Defaults[\.hazardousStats] += 1
        }
        updateStatsLabel(stat: binType)
    }

    func updateStatsLabel(stat: BinType) {
        let text = "🗑 Garbage: \(Defaults[\.trashStats])\n♻️ Recycling: \(Defaults[\.recycleStats])\n🌱 Compost: \(Defaults[\.compostStats])\n☣️ Special: \(Defaults[\.hazardousStats])"
        recycleStatsLabel.text = text
    }
    
    struct BinSorterResponse: Decodable {
        let Result: String
        let BinType: String
    }

    func parseBinResponse(binSorterResponse: String) -> (result: String?, binType: String?) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        let text = cleanJSONString(binSorterResponse)

        guard let data = text.data(using: .utf8) else {
            print("Error: Couldn't convert string to Data")
            return (nil, nil)
        }

        do {
            let response = try decoder.decode(BinSorterResponse.self, from: data)
            return (response.Result, response.BinType)
        } catch {
            print("Error parsing JSON: \(error)")
            return (nil, nil)
        }
    }
    
    func cleanJSONString(_ jsonString: String) -> String {
        // Step 1: Remove the leading and trailing quotation marks if they exist
        let trimmedString = jsonString.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        
        // Step 2: Replace escaped quotes and newlines
        let cleanedString = trimmedString
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\\"", with: "\"")
        
        return cleanedString
    }
    
    private func sendPhotoToRecycleGPT(image: UIImage, location: String? = nil) {
        
        showWholeScreenLoadingIndicator("RecycleGPT working 🤖♻️")
        postImageURL(image: image) { result in
            DispatchQueue.main.async {
                
            self.hideWholeScreenLoadingIndicator()
            switch result {
            case .success(let response):
                print(response)
                let parsedResponse = self.parseBinResponse(binSorterResponse: response)
                
                // Determine the bin type and increment the corresponding stat
                guard let binTypeString = parsedResponse.binType,
                      let binType = BinType(rawValue: binTypeString),
                        let result = parsedResponse.result  else {
                    
                    AlertView.showAlert("Oops!", message: "Error", presentingVC: self, completion: nil)

                    return
                }
                
                self.incrementStat(for: binType)
                
                self.playVoice(result) {
                    
                    if let askUserToSubmitStatsURL = self.askUserToSubmitStatsURL, let playbackManager = self.playbackManager {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            playbackManager.playRecording(url: askUserToSubmitStatsURL) {
                                // Code to execute after playback finishes
                                SpeechController.shared.startSpeechRecognition()
                                //self.recycleMode = .getCharicature
                                
                                playbackManager.playRecording(url: self.sayCheeseURL!) {
                                    // Code to execute after playback finishes
                                    print("Playback of request to submit stats finished")
                                }
                            }
                        }
                    }
                }
                
//                if let askUserToSubmitStatsURL = self.askUserToSubmitStatsURL, let playbackManager = self.playbackManager {
//                    // Schedule the playback to start after 10 seconds
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//                        playbackManager.playRecording(url: askUserToSubmitStatsURL) {
//                            // Code to execute after playback finishes
//                            print("Playback of request to submit stats finished")
//                        }
//                    }
//                }
            case .failure(let error):
                print(error)
            }
            }
        }
    }
    

    
    func parseResult(text: String) {
        print(text)
    }
    
    func toggleRecycleMode() {
        if recycleMode == .scanItem {
            recycleMode = .getCharicature
        } else {
            recycleMode = .scanItem
        }
    }
    
    func downloadAskUserToSubmitStatsVoiceClip() async {
        let askUserToSubmitStats = "Do you want to take a photo and contribute your stats? "
        let playbackModel = VoicePlayBackManagerModel(speechText: askUserToSubmitStats)
        playbackManager = VoicePlayBackManager(model: playbackModel)
        
        askUserToSubmitStatsURL = await playbackManager?.generateURL(askUserToSubmitStats)
        
        let saycheese = "Great. Say cheese in 3, 2, 1..."
        sayCheeseURL = await playbackManager?.generateURL(saycheese)
    }
    
    func askUserForPhoto() async {
        if let askUserToSubmitStatsURL = askUserToSubmitStatsURL, let playbackManager = self.playbackManager {
            playbackManager.playRecording(url: askUserToSubmitStatsURL) {
                
            }
        }
        
        if let sayCheeseURL = askUserToSubmitStatsURL, let playbackManager = self.playbackManager {
            playbackManager.playRecording(url: sayCheeseURL) {
                
            }
        }
        

    }
    
    func postImageURL(image: UIImage, completion: @escaping (Result<String, NetworkingError>) -> Void) {
        uploadImageAndProcess(image) { result in

            switch result {
            case .success(let imageURL):
                guard let url = URL(string: "https://us-central1-rubbish-ee2d0.cloudfunctions.net/binSorter") else {
                    completion(.failure(.generic("Doesnt work")))
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: Any] = ["imageUrl": imageURL, "location" : "San Francisco, California"]
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        completion(.failure(.generic("error: \(error)")))
                        return
                    }
                    guard let data = data else {
                        completion(.failure(.generic("error: \(error)")))
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        completion(.failure(.generic("Fail httpStatus")))
                        return
                    }

                    if let resultString = String(data: data, encoding: .utf8) {
                        completion(.success(resultString))
                    } else {
                        completion(.failure(.generic(" failed to decode")))
                    }
                }

                task.resume()
            case .failure(let fail):
                print(fail)
            }
        }
    }
    
    func uploadImageAndProcess(_ image: UIImage, completion: @escaping (Result<String, NetworkingError>) -> Void) {
        StorageManager.sharedManager.uploadAIRubbishPhoto(image) {downloadURL, error  in
            if let error = error {
                completion(.failure(NetworkingError.generic("uploadImageAndProcess error \(error)")))
                return
            }
            guard let imageURL = downloadURL?.absoluteString else {
                completion(.failure(NetworkingError.noImageURLProvided))
                return
            }
            completion(.success(imageURL))
        }
    }
    
    private func playVoice(_ text: String, completion: @escaping () -> Void) {
        let cleaned = AIParser.cleanString(text)
        let playbackModel = VoicePlayBackManagerModel(speechText: cleaned)
        playbackManager = VoicePlayBackManager(model: playbackModel)
        
        Task {
            await playbackManager?.speak(cleaned, completion: completion)
        }
    }
}


