import SwiftUI
// import Razorpay

/*
class PaymentManager: NSObject, RazorpayPaymentCompletionProtocol {
    static let shared = PaymentManager()
    
    private var razorpay: RazorpayCheckout?
    private var paymentCallback: ((Result<(paymentId: String, orderId: String, signature: String), PaymentError>) -> Void)?
    
    override init() {
        super.init()
        razorpay = RazorpayCheckout.initWithKey("YOUR_RAZORPAY_KEY", andDelegate: self)
    }
    
    func openPayment(options: [String: Any], callback: @escaping (Result<(String, String, String), PaymentError>) -> Void) {
        paymentCallback = callback
        razorpay?.open(options)
    }
    
    func onPaymentSuccess(_ paymentId: String, withData paymentData: [AnyHashable: Any]?) {
        let orderId = paymentData?["razorpay_order_id"] as? String ?? ""
        let signature = paymentData?["razorpay_signature"] as? String ?? ""
        paymentCallback?(.success((paymentId, orderId, signature)))
        PaymentCallbackManager.shared.onPaymentSuccess(paymentId: paymentId, orderId: orderId, signature: signature)
    }
    
    func onPaymentError(_ code: Int32, description: String, withData paymentData: [AnyHashable: Any]?) {
        let (errorCode, cleanMessage) = parseRazorpayError(code: Int(code), response: description)
        paymentCallback?(.failure(PaymentError(code: errorCode, message: cleanMessage)))
        PaymentCallbackManager.shared.onPaymentError(code: errorCode, message: cleanMessage)
    }
    
    private func parseRazorpayError(code: Int, response: String?) -> (Int, String) {
        guard let response = response, !response.isEmpty else {
            return (2, "")
        }
        
        let lowercased = response.lowercased()
        if lowercased.contains("cancelled") || lowercased == "undefined" {
            return (2, response)
        }
        
        return (code, response)
    }
}
*/

// struct PaymentError: Error {
//     let code: Int
//     let message: String
// }
//
// class PaymentCallbackManager {
//     static let shared = PaymentCallbackManager()
//     private var successCallback: ((String, String, String) -> Void)?
//     private var errorCallback: ((Int, String) -> Void)?
//     
//     func setCallbacks(onSuccess: @escaping (String, String, String) -> Void,
//                       onError: @escaping (Int, String) -> Void) {
//         successCallback = onSuccess
//         errorCallback = onError
//     }
//     
//     func onPaymentSuccess(paymentId: String, orderId: String, signature: String) {
//         successCallback?(paymentId, orderId, signature)
//     }
//     
//     func onPaymentError(code: Int, message: String) {
//         errorCallback?(code, message)
//     }
// }
