import SwiftUI
import PhotosUI

struct MilestonePopupView: View {
    let progressDay: ProgressDay
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    @State private var milestoneText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignConstants.largeSpacing) {
                // Header with date
                VStack(spacing: DesignConstants.smallSpacing) {
                    Text("Milestone")
                        .font(DesignConstants.titleFont)
                        .foregroundColor(DesignConstants.textColor)
                    
                    if let date = progressDay.date {
                        Text(dateString(from: date))
                            .font(DesignConstants.captionFont)
                            .foregroundColor(DesignConstants.textColor.opacity(0.7))
                    }
                }
                .padding(.top, DesignConstants.largeSpacing)
                
                // Content
                VStack(spacing: DesignConstants.largeSpacing) {
                    // Text input
                    VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                        Text("What did you accomplish?")
                            .font(DesignConstants.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(DesignConstants.textColor)
                        
                        TextEditor(text: $milestoneText)
                            .font(DesignConstants.bodyFont)
                            .padding(DesignConstants.mediumSpacing)
                            .background(Color.white)
                            .cornerRadius(DesignConstants.mediumCornerRadius)
                            .frame(minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignConstants.mediumCornerRadius)
                                    .stroke(DesignConstants.primaryColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Photo picker
                    VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                        Text("Add a photo (optional)")
                            .font(DesignConstants.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(DesignConstants.textColor)
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .foregroundColor(DesignConstants.primaryColor)
                                
                                Text("Choose Photo")
                                    .font(DesignConstants.bodyFont)
                                    .foregroundColor(DesignConstants.primaryColor)
                                
                                Spacer()
                            }
                            .padding(DesignConstants.mediumSpacing)
                            .background(Color.white)
                            .cornerRadius(DesignConstants.mediumCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignConstants.mediumCornerRadius)
                                    .stroke(DesignConstants.primaryColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Display selected photo
                        if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(DesignConstants.mediumCornerRadius)
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
                                    .padding(DesignConstants.smallSpacing),
                                    alignment: .topTrailing
                                )
                        }
                    }
                }
                .padding(.horizontal, DesignConstants.largeSpacing)
                
                Spacer()
                
                // Save button
                Button("Save Milestone") {
                    saveMilestone()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, DesignConstants.largeSpacing)
                .padding(.bottom, DesignConstants.largeSpacing)
            }
            .background(DesignConstants.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        // Dismiss the sheet
                        // In a real app, you might want to use a different approach
                    }
                    .foregroundColor(DesignConstants.primaryColor)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
        .onAppear {
            // Load existing milestone data
            milestoneText = progressDay.milestoneText ?? ""
            photoData = progressDay.milestonePhoto
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func saveMilestone() {
        coreDataManager.addMilestone(
            to: progressDay,
            text: milestoneText,
            photo: photoData
        )
        
        // Update the progress day to mark as completed
        coreDataManager.updateProgressDay(progressDay, completed: true)
        
        // Dismiss the sheet
        // In a real app, you might want to use a different approach
    }
}

#Preview {
    MilestonePopupView(progressDay: ProgressDay())
} 