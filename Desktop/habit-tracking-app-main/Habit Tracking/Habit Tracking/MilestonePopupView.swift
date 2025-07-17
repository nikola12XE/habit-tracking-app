import SwiftUI
import PhotosUI
import UIKit

struct MilestonePopupView: View {
    let progressDay: ProgressDay
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    @Binding var isPresented: Bool
    
    @State private var milestoneText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showImagePicker = false
    @State private var showImageActionSheet = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var backgroundOpacity: Double = 0
    @State private var modalOffset: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background overlay
                Color.black.opacity(backgroundOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissModal()
                    }
                
                // Modal content
                VStack {
                    Spacer()
                    modalContent
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .offset(y: modalOffset)
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .onAppear {
            // Load existing milestone data
            milestoneText = progressDay.milestoneText ?? ""
            photoData = progressDay.milestonePhoto
            showModal()
        }
        .actionSheet(isPresented: $showImageActionSheet) {
            ActionSheet(
                title: Text("Add Photo"),
                message: Text("Choose how you want to add a photo"),
                buttons: [
                    .default(Text("Take Photo")) {
                        showCamera = true
                    },
                    .default(Text("Choose from Library")) {
                        showPhotoLibrary = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showCamera) {
            CameraView(photoData: $photoData)
        }
        .photosPicker(isPresented: $showPhotoLibrary, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }
    
    private var modalContent: some View {
        VStack(spacing: 0) {
            // Top section with delete button and line
            topSection
            
            // Main content
            VStack(spacing: 24) {
                trophySection
                inputSection
            }
            .padding(.horizontal, 0)
            .padding(.top, 24)
            
            Spacer()
            
            // Bottom buttons
            bottomButtons
        }
        .background(Color(red: 0.929, green: 0.929, blue: 0.929))
        .cornerRadius(20)
        .frame(height: 445)
        .padding(.top, 24)
        .animation(.easeInOut(duration: 0.3), value: photoData != nil)
    }
    
    private var topSection: some View {
        VStack(spacing: 0) {
            // Swipe down line
            Rectangle()
                .fill(Color(red: 0.787, green: 0.787, blue: 0.787))
                .frame(width: 38, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 16)
            
            HStack {
                // Delete button
                Button(action: {
                    dismissModal()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.894, green: 0.894, blue: 0.894))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 0.463, green: 0.463, blue: 0.463).opacity(0.2), lineWidth: 1)
                            )
                        
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.463, green: 0.463, blue: 0.463))
                    }
                }
                .padding(.leading, 24)
                .padding(.top, 16) // Pozicioniraj gornju ivicu kruga na 16px od vrha
                .offset(y: -24) // Kompenzuj za visinu kruga (48px/2 = 24px)
                
                Spacer()
                
                // Empty space for balance
                Circle()
                    .fill(Color.clear)
                    .frame(width: 48, height: 48)
                    .padding(.trailing, 24)
            }
        }
    }
    
    private var trophySection: some View {
        VStack(spacing: 10) {
            // Trophy icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.894, green: 0.894, blue: 0.894))
                    .frame(width: 52, height: 52)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Color(red: 0.894, green: 0.894, blue: 0.894))
                    .overlay(
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(Color(red: 0.894, green: 0.894, blue: 0.894))
                            .blur(radius: 0.5)
                    )
            }
            
            // Title and date
            VStack(spacing: 4) {
                Text("Milestone")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                
                if let date = progressDay.date {
                    Text(dateString(from: date))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.black)
                }
            }
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 10) {
            // Text input field - stil iz onboarding ekrana
            HStack {
                TextField("Enter your achievement", text: $milestoneText)
                    .font(.custom("Inter_24pt-SemiBold", size: 16))
                    .tracking(-0.16)
                    .foregroundColor(.black)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)
                
                Spacer()
                
                // Paperclip icon - attach button
                Button(action: {
                    showImageActionSheet = true
                }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                }
                .padding(.trailing, 24)
            }
            .frame(height: 52)
            .background(Color(red: 0.894, green: 0.894, blue: 0.894))
            .cornerRadius(38)
            .overlay(
                RoundedRectangle(cornerRadius: 38)
                    .stroke(Color(red: 0.46, green: 0.46, blue: 0.46).opacity(0.28), lineWidth: 1)
            )
            
            // Placeholder text - stil iz onboarding ekrana
            Text("Enter your achievement")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047).opacity(0.7))
                .padding(.top, 8)
            
            // Show selected image if exists
            if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                VStack(spacing: 8) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(
                            Button(action: {
                                self.photoData = nil
                                self.selectedPhoto = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .padding(8),
                            alignment: .topTrailing
                        )
                }
            }
        }
        .padding(.horizontal, 24) // 24px od ivica ekrana
    }
    
    private var bottomButtons: some View {
        HStack(spacing: 10) {
            // Cancel button
            Button(action: {
                dismissModal()
            }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.black)
                    .frame(width: 114, height: 62)
                    .background(Color(red: 0.894, green: 0.894, blue: 0.894))
                    .cornerRadius(100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(Color(red: 0.851, green: 0.851, blue: 0.851), lineWidth: 1)
                    )
            }
            
            // Save button
            Button(action: {
                saveMilestone()
            }) {
                Text("Save Milestone")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.white)
                    .frame(width: 200, height: 62)
                    .background(Color.black)
                    .cornerRadius(100)
            }
        }
        .padding(.horizontal, 58)
        .padding(.bottom, 32)
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MM. yyyy."
        return formatter.string(from: date)
    }
    
    private func showModal() {
        withAnimation(.easeInOut(duration: 0.3)) {
            backgroundOpacity = 0.2
            modalOffset = 0
        }
    }
    
    private func dismissModal() {
        withAnimation(.easeInOut(duration: 0.3)) {
            backgroundOpacity = 0
            modalOffset = UIScreen.main.bounds.height
        } completion: {
            isPresented = false
        }
    }
    
    private func saveMilestone() {
        coreDataManager.addMilestone(
            to: progressDay,
            text: milestoneText,
            photo: photoData
        )
        
        // Update the progress day to mark as completed
        coreDataManager.updateProgressDay(progressDay, completed: true)
        
        dismissModal()
    }
}



#Preview {
    MilestonePopupView(progressDay: ProgressDay(), isPresented: .constant(true))
} 