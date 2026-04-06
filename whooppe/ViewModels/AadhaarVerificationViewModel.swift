// ViewModels/AadhaarVerificationViewModel.swift
import Foundation
import SwiftUI
import Combine

// MARK: - ViewModel
class AadhaarVerificationViewModel: ObservableObject {
    @Published var currentStep: AadhaarVerificationStep = .buttonScreen
    @Published var userName: String = ""
    @Published var userPhone: String = ""
    @Published var aadhaarUploaded: Bool = false
    @Published var selfieUploaded: Bool = false
    @Published var faceVerified: Bool = false
    @Published var verificationStatus: String = ""
    @Published var aadhaarFullName: String = ""
    @Published var aadhaarImageUri: URL?
    @Published var selfieImageUri: URL?
    @Published var fullNameAsPerAadhaar: String = ""
    @Published var selfieFullName: String = ""
    @Published var nameError: String?
    @Published var selfieNameError: String?
    @Published var isLoading: Bool = false
    @Published var isValidatingFace: Bool = false
    @Published var errorMessage: String?
    @Published var showConsentPopup: Bool = false
    @Published var isLoadingProfile: Bool = false
    @Published var verificationSuccess = false
    
    private let apiService = APIService.shared
    private var currentAadhaarImage: UIImage?
    private var currentSelfieImage: UIImage?
    
    init() {
        print("📱 AadhaarVerificationViewModel initialized")
    }
    
    // MARK: - Load User Profile from API
    @MainActor
    func loadUserProfile() async {
        print("🔄 [WHOOPPE PASS] Loading user profile from API...")
        isLoadingProfile = true
        
        do {
            let response = try await apiService.getUserProfile()
            print("✅ [WHOOPPE PASS] Profile API response received")
            
            if response.status == "success" {
                let profileData = response.data
                let user = profileData.user
                let aadhaar = profileData.aadhaarStatus
                let face = profileData.faceVerification
                
                userName = user?.name ?? ""
                userPhone = user?.phone ?? ""
                aadhaarUploaded = aadhaar?.uploaded ?? false
                aadhaarFullName = aadhaar?.fullName ?? ""
                selfieUploaded = user?.uploadedPhoto != nil
                faceVerified = face?.verified ?? false
                verificationStatus = user?.verificationStatus ?? "pending"
                
                print("📊 User: \(userName), Phone: \(userPhone)")
                print("📊 Aadhaar: \(aadhaarUploaded), Face: \(faceVerified)")
            } else {
                errorMessage = response.message ?? "Failed to load profile"
            }
        } catch {
            print("❌ Failed to load profile: \(error.localizedDescription)")
            errorMessage = "Failed to load profile"
        }
        
        isLoadingProfile = false
    }
    
    // MARK: - Refresh Profile
    @MainActor
    func refreshUserProfile() async {
        print("🔄 Refreshing user profile...")
        await loadUserProfile()
    }
    
    // MARK: - Navigation Methods
    func onInitialButtonClick() {
        currentStep = .initialPopup
    }
    
    func onContinueFromPopup() async {
        currentStep = .uploadAadhaar
    }
    
    func navigateToButtonScreen() {
        currentStep = .buttonScreen
    }
    
    func onSelfieButtonClick() {
        currentStep = .uploadSelfie
    }
    
    // MARK: - Image Handling
    func onAadhaarImageCaptured(_ image: UIImage) {
        currentAadhaarImage = image
        aadhaarImageUri = saveImageToTemp(image, name: "aadhaar")
        aadhaarUploaded = true
    }
    
    func onSelfieImageCaptured(_ image: UIImage) {
        currentSelfieImage = image
        selfieImageUri = saveImageToTemp(image, name: "selfie")
        selfieUploaded = true
    }
    
    func onRemoveAadhaarImage() {
        currentAadhaarImage = nil
        aadhaarImageUri = nil
        aadhaarUploaded = false
    }
    
    func onRemoveSelfieImage() {
        currentSelfieImage = nil
        selfieImageUri = nil
        selfieUploaded = false
    }
    
    func onNameChange(_ name: String) {
        fullNameAsPerAadhaar = name
        nameError = nil
    }
    
    func onSelfieNameChange(_ name: String) {
        selfieFullName = name
        selfieNameError = nil
    }
    
    func onConsentAgree() {
        showConsentPopup = false
        Task {
            await onAadhaarUploadClick()
        }
    }
    
    func onConsentCancel() {
        showConsentPopup = false
    }
    
    // MARK: - Upload Methods
    func onAadhaarUploadClick() async {
        guard let image = currentAadhaarImage else {
            await MainActor.run {
                errorMessage = "Please capture Aadhaar image first"
            }
            return
        }
        
        guard !fullNameAsPerAadhaar.isEmpty else {
            await MainActor.run {
                errorMessage = "Please enter name as per Aadhaar"
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to process image"
            }
            return
        }
        
        do {
            let response = try await apiService.uploadAadhaarImage(
                imageData: imageData,
                fullName: fullNameAsPerAadhaar
            )
            
            await MainActor.run {
                isLoading = false
                if response.success {
                    aadhaarUploaded = true
                    aadhaarFullName = fullNameAsPerAadhaar
                    currentStep = .uploadSelfie
                } else {
                    errorMessage = response.message ?? "Aadhaar upload failed"
                }
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Upload failed: \(error.localizedDescription)"
            }
        }
    }
    
    func onSelfieUploadClick() async {
        guard let image = currentSelfieImage else {
            await MainActor.run {
                errorMessage = "Please capture selfie first"
            }
            return
        }
        
        guard !selfieFullName.isEmpty else {
            await MainActor.run {
                errorMessage = "Please enter your name"
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            isValidatingFace = true
            errorMessage = nil
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            await MainActor.run {
                isLoading = false
                isValidatingFace = false
                errorMessage = "Failed to process image"
            }
            return
        }
        
        do {
            let response = try await apiService.uploadSelfieImage(
                imageData: imageData,
                fullName: selfieFullName
            )
            
            await MainActor.run {
                isLoading = false
                isValidatingFace = false
                
                if response.success {
                    selfieUploaded = true
                    faceVerified = response.faceVerified ?? false
                    verificationStatus = response.faceVerified == true ? "verified" : "pending"
                    
                    if faceVerified {
                        verificationSuccess = true
                    }
                    
                    currentStep = .buttonScreen
                    
                    Task {
                        await refreshUserProfile()
                    }
                } else {
                    errorMessage = response.message ?? "Selfie upload failed"
                }
            }
        } catch {
            await MainActor.run {
                isLoading = false
                isValidatingFace = false
                errorMessage = "Upload failed: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Helpers
    private func saveImageToTemp(_ image: UIImage, name: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(name)_\(UUID().uuidString).jpg"
        let fileURL = tempDir.appendingPathComponent(fileName)
        try? data.write(to: fileURL)
        return fileURL
    }
}