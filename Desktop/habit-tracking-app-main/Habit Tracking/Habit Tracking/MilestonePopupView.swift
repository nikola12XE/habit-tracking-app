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
    @State private var showCancelAlert = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background overlay
                Color.black.opacity(backgroundOpacity)
                    .ignoresSafeArea()
                
                // Modal content
                VStack {
                    Spacer()
                    modalContent
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .offset(y: modalOffset)
                .ignoresSafeArea(.all, edges: .bottom)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.height > 100 {
                                if !milestoneText.isEmpty || photoData != nil {
                                    showCancelAlert = true
                                } else {
                                    dismissModal()
                                }
                            }
                        }
                )
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
        ZStack(alignment: .bottom) {
            // Main content area
            VStack(spacing: 0) {
                // Top section with delete button and line
                topSection
                
                // Main content
                VStack(spacing: 24) {
                    trophySection
                    inputSection
                }
                .padding(.horizontal, 0)
                .offset(y: -16)
                
                Spacer()
            }
            .background(Color(red: 0.929, green: 0.929, blue: 0.929))
            .clipShape(RoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
            .frame(height: photoData != nil ? 650 : 445) // Povećana visina kada postoji slika
            .padding(.top, 24)
            
            // Bottom buttons - fiksirana pozicija na dnu
            bottomButtons
        }
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
                    showDeleteAlert = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.894, green: 0.894, blue: 0.894))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 0.463, green: 0.463, blue: 0.463).opacity(0.2), lineWidth: 1)
                            )
                        Image("Trash")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .alert("Are you sure you want to delete?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        deleteMilestone()
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .padding(.leading, 24)
                .padding(.top, 8) // Podigni trash ikonicu
                
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
            Image("Trophy")
                .resizable()
                .frame(width: 52, height: 52)
            // Title and date
            VStack(spacing: 4) {
                Text("Milestone")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .tracking(-0.04 * 24)
                    .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                if let date = progressDay.date {
                    Text(dateString(from: date))
                        .font(.custom("Inter_24pt-Regular", size: 14))
                        .tracking(-0.04 * 14) // -4% letter spacing
                        .foregroundColor(Color(red: 0.561, green: 0.561, blue: 0.561)) // #8F8F8F
                }
            }
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 10) {
            // Text input field - stil iz onboarding ekrana
            HStack {
                TextField("Enter achievement", text: $milestoneText)
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
                    Image("Attach")
                        .resizable()
                        .frame(width: 20, height: 20)
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
            Text("Enter achievement")
                .font(.custom("Inter_24pt-Regular", size: 14))
                .foregroundColor(Color(red: 0.561, green: 0.561, blue: 0.561)) // #8F8F8F
                .padding(.top, 4) // Smanjen razmak sa 8 na 4
            
            // Show selected image if exists
            if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                VStack(spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200) // Povećana visina slike
                            .clipped()
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white, lineWidth: 8)
                            )
                        
                        Button(action: {
                            self.photoData = nil
                            self.selectedPhoto = nil
                        }) {
                            Image("XIcon")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                        }
                        .padding(8)
                    }
                }
                .rotationEffect(.degrees(-1)) // Nakrivljenje -1 stepen
                .padding(.top, 14)
                .padding(.bottom, 24)
            }
        }
        .padding(.horizontal, 24) // 24px od ivica ekrana
    }
    
    private var bottomButtons: some View {
        HStack(spacing: 10) {
            // Cancel button
            Button(action: {
                if !milestoneText.isEmpty || photoData != nil {
                    showCancelAlert = true
                } else {
                    dismissModal()
                }
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
            .alert("Are you sure you\nwant to leave?", isPresented: $showCancelAlert) {
                Button("Go Back", role: .cancel) {}
                    .font(.system(size: 16, weight: .regular))
                Button("Leave", role: .destructive) {
                    dismissModal()
                }
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .regular))
            } message: {
                Text("Your edits will be lost")
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
    
    private func deleteMilestone() {
        // Potpuno resetuj progressDay na početno stanje
        progressDay.milestoneText = nil
        progressDay.milestonePhoto = nil
        progressDay.completed = false
        progressDay.flowerType = nil
        
        // Obriši progressDay iz Core Data
        coreDataManager.deleteProgressDay(progressDay)
        
        dismissModal()
    }
}




#Preview {
    MilestonePopupView(progressDay: ProgressDay(), isPresented: .constant(true))
} 