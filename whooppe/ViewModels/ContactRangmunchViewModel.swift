import SwiftUI
import Combine
// MARK: - ViewModel
class ContactRangmunchViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var organizationName = ""
    @Published var city = ""
    @Published var state = ""
    @Published var partnershipTypeDisplay = ""
    @Published var eventTypeDisplay = ""
    @Published var experienceLevelDisplay = ""
    @Published var message = ""

    @Published var fullNameError: String?
    @Published var emailError: String?
    @Published var phoneError: String?
    @Published var organizationNameError: String?
    @Published var cityError: String?
    @Published var stateError: String?
    @Published var partnershipTypeError: String?
    @Published var eventTypeError: String?
    @Published var experienceLevelError: String?
    @Published var messageError: String?

    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false

    typealias EnumOption = (display: String, value: String)

    static let partnershipTypes: [EnumOption] = [
        ("Organizer", "organizer"),
        ("Promoter", "promoter"),
        ("Venue Partner", "venue_partner"),
        ("Other", "other")
    ]

    static let eventTypes: [EnumOption] = [
        ("Concerts", "concerts"),
        ("Theater", "theater"),
        ("Comedy", "comedy"),
        ("Sports", "sports"),
        ("Workshops", "workshops"),
        ("Conferences", "conferences"),
        ("Other", "other")
    ]

    static let experienceLevels: [EnumOption] = [
        ("Beginner", "beginner"),
        ("Intermediate", "intermediate"),
        ("Experienced", "experienced"),
        ("Expert", "expert")
    ]

    static let indianStates: [String] = [
        "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
        "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand",
        "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur",
        "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab",
        "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura",
        "Uttar Pradesh", "Uttarakhand", "West Bengal",
        "Andaman and Nicobar Islands", "Chandigarh",
        "Dadra and Nagar Haveli and Daman and Diu", "Delhi",
        "Jammu and Kashmir", "Ladakh", "Lakshadweep", "Puducherry"
    ]

    private var partnershipTypeValue: String {
        Self.partnershipTypes.first { $0.display == partnershipTypeDisplay }?.value ?? ""
    }
    private var eventTypeValue: String {
        Self.eventTypes.first { $0.display == eventTypeDisplay }?.value ?? ""
    }
    private var experienceLevelValue: String {
        Self.experienceLevels.first { $0.display == experienceLevelDisplay }?.value ?? ""
    }

    func submitInquiry() async {
        guard validate() else { return }

        DispatchQueue.main.async { self.isLoading = true }

        let body: [String: String] = [
            "fullName": fullName,
            "email": email,
            "phone": phone,
            "organizationName": organizationName,
            "city": city,
            "state": state,
            "partnershipType": partnershipTypeValue,
            "eventType": eventTypeValue,
            "experienceLevel": experienceLevelValue,
            "message": message
        ]

        guard let url = URL(string: "https://backendmongo-tau.vercel.app/api/listyourshow/inquiry") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let http = response as? HTTPURLResponse
            DispatchQueue.main.async {
                self.isLoading = false
                if http?.statusCode == 201 {
                    self.successMessage = "Submitted"
                } else {
                    // Try to parse error message from backend
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let msg = json["message"] as? String {
                        self.errorMessage = msg
                    } else {
                        self.errorMessage = "Something went wrong. Please try again."
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func validate() -> Bool {
        var ok = true

        fullNameError = fullName.trimmingCharacters(in: .whitespaces).isEmpty ? "Full name is required" : nil
        if fullNameError != nil { ok = false }

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = "Email is required"; ok = false
        } else if !isValidEmail(email) {
            emailError = "Please enter a valid email"; ok = false
        } else { emailError = nil }

        if phone.trimmingCharacters(in: .whitespaces).isEmpty {
            phoneError = "Phone number is required"; ok = false
        } else if !phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression).count.description.isEmpty,
                  phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression).count != 10 {
            phoneError = "Please enter a valid 10-digit phone number"; ok = false
        } else { phoneError = nil }

        organizationNameError = organizationName.trimmingCharacters(in: .whitespaces).isEmpty ? "Organisation name is required" : nil
        if organizationNameError != nil { ok = false }

        cityError = city.trimmingCharacters(in: .whitespaces).isEmpty ? "City is required" : nil
        if cityError != nil { ok = false }

        stateError = state.isEmpty ? "Please select a state" : nil
        if stateError != nil { ok = false }

        partnershipTypeError = partnershipTypeDisplay.isEmpty ? "Please select a partnership type" : nil
        if partnershipTypeError != nil { ok = false }

        eventTypeError = eventTypeDisplay.isEmpty ? "Please select an event type" : nil
        if eventTypeError != nil { ok = false }

        experienceLevelError = experienceLevelDisplay.isEmpty ? "Please select your experience level" : nil
        if experienceLevelError != nil { ok = false }

        if message.trimmingCharacters(in: .whitespaces).isEmpty {
            messageError = "Message is required"; ok = false
        } else if message.count < 20 {
            messageError = "Message must be at least 20 characters"; ok = false
        } else { messageError = nil }

        return ok
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    func resetForm() {
        fullName = ""; email = ""; phone = ""; organizationName = ""
        city = ""; state = ""; partnershipTypeDisplay = ""
        eventTypeDisplay = ""; experienceLevelDisplay = ""; message = ""
        fullNameError = nil; emailError = nil; phoneError = nil
        organizationNameError = nil; cityError = nil; stateError = nil
        partnershipTypeError = nil; eventTypeError = nil
        experienceLevelError = nil; messageError = nil
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}
