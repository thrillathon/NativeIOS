import SwiftUI

struct PaymentScreen: View {
    @StateObject private var viewModel = PaymentViewModel()
    @Environment(\.dismiss) var dismiss
    let eventId: String
    let seatingId: String
    let ticketPrice: Double
    let eventName: String?
    let venue: String?
    let date: String?
    let time: String?
    let language: String?
    let locationLink: String?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top Bar
                
                
                Divider()
                    .padding(.horizontal, 25)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Event Ticket Card
                        EventTicketCard(
                            eventName: viewModel.eventName,
                            language: viewModel.language,
                            venue: viewModel.venue,
                            date: viewModel.date,
                            time: viewModel.time
                        )
                        
                        // Payment Details Section
                        PaymentDetailsSection(
                            ticketPrice: viewModel.ticketPrice,
                            convenienceFeeData: viewModel.convenienceFeeData,
                            isExpanded: viewModel.isConvenienceFeeExpanded,
                            onToggle: { viewModel.toggleConvenienceFee() }
                        )
                        
                        // User Details Section
                        UserDetailsSection(
                            userName: viewModel.userName,
                            userEmail: viewModel.userEmail,
                            userPhone: viewModel.userPhone,
                            userState: viewModel.state
                        )
                        
                        // Smart Entry Section
                        SmartEntrySection(
                            isFaceVerified: viewModel.isFaceVerified,
                            isChecked: viewModel.isSmartEntryChecked,
                            onChanged: { viewModel.setSmartEntryChecked($0) },
                            onVerifyFace: {
                                Task {
                                    await viewModel.verifyFaceStatus(faceId: viewModel.faceId)
                                }
                            }
                        )
                        
                        Spacer().frame(height: 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                
                // Bottom Bar
                ProceedBottomBar(
                    buttonText: "Proceed to Pay",
                    onButtonClick: { viewModel.openRazorpayCheckout() },
                    isLoading: viewModel.isLoading
                )
            }
            
            // Loading Overlay
            if viewModel.isVerifyingPayment {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .overlay {
                        VStack(spacing: 24) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Color(hex: "#D4B547"))
                            Text("Verifying payment...")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            if viewModel.canDismissVerification {
                                Button("Continue anyway") {
                                    viewModel.dismissVerificationOverlay()
                                }
                                .foregroundColor(Color(hex: "#D4B547"))
                            }
                        }
                        .padding(32)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
            }
        }
        .sheet(isPresented: $viewModel.shouldOpenRazorpay) {
            RazorpayCheckoutView(
                orderId: viewModel.razorpayOrderId,
                key: viewModel.key,
                amount: viewModel.convenienceFeeData?.totalAmount ?? viewModel.ticketPrice,
                userEmail: viewModel.userEmail,
                userPhone: viewModel.userPhone,
                onSuccess: { paymentId, signature in
                    Task {
                        // TODO: Verify payment signature after Razorpay success
                        await viewModel.verifyPayment(
                            orderId: viewModel.razorpayOrderId,
                            paymentId: paymentId,
                            signature: signature
                        )
                    }
                },
                onFailure: { error in
                    viewModel.paymentResult = .failed(errorMessage: error)
                    viewModel.showPaymentFailedDialog = true
                },
                onDismiss: {
                    viewModel.shouldOpenRazorpay = false
                }
            )
        }
        .alert("Payment Successful!", isPresented: $viewModel.showPaymentSuccessDialog) {
            Button("View Ticket") {
                viewModel.dismissPaymentSuccessDialog()
                // Navigate to tickets
            }
            Button("Go Home") {
                viewModel.dismissPaymentSuccessDialog()
                // Navigate to home
            }
        } message: {
            Text("Your ticket has been booked successfully!")
        }
        .alert("Payment Failed", isPresented: $viewModel.showPaymentFailedDialog) {
            Button("Try Again") {
                viewModel.dismissPaymentFailedDialog()
                viewModel.openRazorpayCheckout()
            }
            Button("Cancel", role: .cancel) {
                viewModel.dismissPaymentFailedDialog()
                dismiss()
            }
        } message: {
            if case .failed(let message) = viewModel.paymentResult {
                Text(message)
            }
        }
        .navigationTitle("Lock Your Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#D4B547"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                // Remove the default back button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)

        .task {
            viewModel.eventId = eventId
            viewModel.seatingId = seatingId
            viewModel.ticketPrice = ticketPrice
            viewModel.eventName = eventName ?? ""
            viewModel.venue = venue ?? ""
            viewModel.date = date ?? ""
            viewModel.time = time ?? ""
            viewModel.language = language ?? ""
            viewModel.locationLink = locationLink ?? ""
            
            await viewModel.loadPaymentDetails(eventId: eventId, seatingId: seatingId, ticketPrice: ticketPrice)
        }
    }
}

struct EventTicketCard: View {
    let eventName: String
    let language: String
    let venue: String
    let date: String
    let time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(eventName)
                        .font(.custom("Spectral", size: 20))
                    if !language.isEmpty {
                        Text(language)
                            .font(.system(size: 10))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("1")
                        .font(.system(size: 20))
                    Text("No of Ticket")
                        .font(.system(size: 10))
                }
            }
            
            HStack {
                Text(venue)
                    .font(.system(size: 10))
                Spacer()
                Image(systemName: "location.north.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#03A9F4"))
            }
            
            HStack(spacing: 15) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(date)
                        .font(.system(size: 10))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(time)
                        .font(.system(size: 10))
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black, lineWidth: 0.5)
        )
    }
}

struct PaymentDetailsSection: View {
    let ticketPrice: Double
    let convenienceFeeData: ConvenienceFeeData?
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "ticket")
                    .font(.system(size: 22))
                Text("Payment details")
                    .font(.system(size: 16, weight: .medium))
            }
            
            VStack(spacing: 8) {
                PaymentRow(label: "Ticket price", amount: ticketPrice)
                
                Button(action: onToggle) {
                    HStack {
                        Text("Convenience fees")
                            .font(.system(size: 14))
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14))
                        Spacer()
                        Text("₹ \(formatAmount(convenienceFeeData?.totalFee ?? 0))")
                            .font(.system(size: 14))
                        
                    }
                }
                .foregroundColor(.black)
                
                if isExpanded, let data = convenienceFeeData {
                    VStack(spacing: 4) {
                        PaymentSubRow(label: "Base Price", amount: data.convenienceFee)
                        PaymentSubRow(label: "IGST (18%)", amount: data.gstOnFee)
                    }
                    .padding(.leading, 16)
                }
                
                Divider()
                
                PaymentRow(label: "Total", amount: convenienceFeeData?.totalAmount ?? ticketPrice, isBold: true)
            }
            .padding(.leading, 24)
        }
        .padding(20)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

struct PaymentRow: View {
    let label: String
    let amount: Double
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: isBold ? .semibold : .regular))
            Spacer()
            Text("₹ \(formatAmount(amount))")
                .font(.system(size: 14, weight: isBold ? .semibold : .regular))
        }
    }
}

struct PaymentSubRow: View {
    let label: String
    let amount: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray.opacity(0.7))
            Spacer()
            Text("₹ \(formatAmount(amount))")
                .font(.system(size: 11))
                .foregroundColor(.gray.opacity(0.7))
        }
    }
}

func formatAmount(_ amount: Double) -> String {
    if amount == Double(Int(amount)) {
        return String(Int(amount))
    }
    return String(format: "%.2f", amount)
}
