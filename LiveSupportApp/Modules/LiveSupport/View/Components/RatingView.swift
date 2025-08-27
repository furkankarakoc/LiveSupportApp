//
//  RatingView.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import SwiftUI

struct RatingView: View {
    @Binding var isPresented: Bool
    @State private var selectedRating: Int = 0
    @State private var feedback: String = ""
    let onAction: (RatingAction) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Görüşmeyi Puanla")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Deneyiminizi değerlendirin")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Star Rating
            VStack(spacing: 12) {
                Text("Hizmet kalitesi")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: {
                            selectedRating = star
                        }) {
                            Image(systemName: star <= selectedRating ? "star.fill" : "star")
                                .font(.title)
                                .foregroundColor(star <= selectedRating ? .yellow : .gray)
                                .scaleEffect(star == selectedRating ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedRating)
                        }
                    }
                }
                
                if selectedRating > 0 {
                    Text(ratingText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Feedback Text Field
            VStack(spacing: 8) {
                Text("Ek yorumlarınız (isteğe bağlı)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Deneyiminizi paylaşın...", text: $feedback, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            // Submit Button
            Button(action: {
                let rating = ConversationRating(rating: selectedRating, feedback: feedback.isEmpty ? nil : feedback)
                onAction(.submit(rating))
                isPresented = false
            }) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Gönder")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedRating > 0 ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(selectedRating == 0)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
    
    private var ratingText: String {
        switch selectedRating {
        case 1: return "Çok kötü"
        case 2: return "Kötü"
        case 3: return "Orta"
        case 4: return "İyi"
        case 5: return "Mükemmel"
        default: return ""
        }
    }
}
