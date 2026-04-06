import Foundation
import Combine

enum AadhaarVerificationStep {
    case buttonScreen
    case initialPopup
    case uploadAadhaar
    case uploadSelfie
}

struct AadhaarVerificationUiState {
    var currentStep: AadhaarVerificationStep = .buttonScreen
    var userName: String = ""
    var userPhone: String = ""
    var aadhaarUploaded: Bool = false
    var selfieUploaded: Bool = false
    var faceVerified: Bool = false
    var verificationStatus: String = ""
    var aadhaarFullName: String = ""
    var aadhaarImageUri: URL?
    var selfieImageUri: URL?
    var fullNameAsPerAadhaar: String = ""
    var selfieFullName: String = ""
    var nameError: String?
    var selfieNameError: String?
    var isLoading: Bool = false
    var isValidatingFace: Bool = false
    var errorMessage: String?
    var showConsentPopup: Bool = false
}
