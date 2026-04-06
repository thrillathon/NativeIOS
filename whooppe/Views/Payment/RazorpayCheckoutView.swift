import SwiftUI
import WebKit

struct RazorpayCheckoutView: View {
    let orderId: String
    let key: String
    let amount: Double
    let userEmail: String
    let userPhone: String
    let onSuccess: (String, String) -> Void
    let onFailure: (String) -> Void
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Text("Payment")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                    onDismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            .padding(16)
            
            RazorpayWebView(
                orderId: orderId,
                key: key,
                amount: amount,
                userEmail: userEmail,
                userPhone: userPhone,
                onSuccess: onSuccess,
                onFailure: onFailure
            )
            
            Spacer()
        }
        .background(Color.white)
    }
}

struct RazorpayWebView: UIViewRepresentable {
    let orderId: String
    let key: String
    let amount: Double
    let userEmail: String
    let userPhone: String
    let onSuccess: (String, String) -> Void
    let onFailure: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        // Register script message handlers
        configuration.userContentController.add(context.coordinator, name: "paymentSuccess")
        configuration.userContentController.add(context.coordinator, name: "paymentFailure")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        let htmlContent = razorpayHTML(
            orderId: orderId,
            key: key,
            amount: Int(amount * 100), // Convert to paise
            userEmail: userEmail,
            userPhone: userPhone
        )
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSuccess: onSuccess, onFailure: onFailure)
    }
    
    private func razorpayHTML(orderId: String, key: String, amount: Int, userEmail: String, userPhone: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto; padding: 20px; }
                .container { text-align: center; margin-top: 40px; }
                button { padding: 12px 24px; background: #D4B547; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; }
                button:hover { background: #c5a63a; }
            </style>
        </head>
        <body>
            <div class="container">
                <h2>Razorpay Checkout</h2>
                <p>Amount: ₹\(Double(amount) / 100)</p>
                <button onclick="startPayment()">Pay Now</button>
            </div>
            
            <script>
                function startPayment() {
                    var options = {
                        'key': '\(key)',
                        'amount': \(amount),
                        'currency': 'INR',
                        'order_id': '\(orderId)',
                        'name': 'Whooppe',
                        'description': 'Event Ticket Payment',
                        'customer_details': {
                            'email': '\(userEmail)',
                            'contact': '\(userPhone)'
                        },
                        'handler': function(response) {
                            window.webkit.messageHandlers.paymentSuccess.postMessage({
                                'paymentId': response.razorpay_payment_id,
                                'signature': response.razorpay_signature
                            });
                        },
                        'modal': {
                            'ondismiss': function() {
                                window.webkit.messageHandlers.paymentFailure.postMessage('Payment cancelled');
                            }
                        }
                    };
                    var rzp = new Razorpay(options);
                    rzp.open();
                }
                
                // Auto-open on load
                window.addEventListener('load', function() {
                    startPayment();
                });
            </script>
        </body>
        </html>
        """
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let onSuccess: (String, String) -> Void
        let onFailure: (String) -> Void
        
        init(onSuccess: @escaping (String, String) -> Void, onFailure: @escaping (String) -> Void) {
            self.onSuccess = onSuccess
            self.onFailure = onFailure
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "paymentSuccess" {
                if let body = message.body as? [String: String],
                   let paymentId = body["paymentId"],
                   let signature = body["signature"] {
                    onSuccess(paymentId, signature)
                }
            } else if message.name == "paymentFailure" {
                if let error = message.body as? String {
                    onFailure(error)
                }
            }
        }
    }
}

#Preview {
    RazorpayCheckoutView(
        orderId: "ORD_69a58ad1_667908",
        key: "rzp_live_SMQqLRvMuvKxWz",
        amount: 1.02,
        userEmail: "test@example.com",
        userPhone: "9999999999",
        onSuccess: { _, _ in },
        onFailure: { _ in },
        onDismiss: {}
    )
}
