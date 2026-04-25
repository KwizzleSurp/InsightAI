import SwiftUI

struct TagChipEditor: View {
    @Binding var tags: [String]
    @State private var newTag = ""
    @Environment(\.designSystem) private var designSystem
    @Namespace private var namespace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(designSystem.typography.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text(tag)
                                .font(.caption2.weight(.medium))
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    tags.removeAll { $0 == tag }
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                        .matchedGeometryEffect(id: "tag-\(tag)", in: namespace)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 1.1).combined(with: .opacity)
                        ))
                    }
                }
            }
            .frame(height: 40)
            
            HStack {
                TextField("Add tag...", text: $newTag)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addTag() }
                    .frame(maxWidth: 120)
                
                Button("Add") { addTag() }
                    .buttonStyle(.bordered)
                    .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else {
            newTag = ""
            return
        }
        withAnimation(.spring(response: 0.3)) {
            tags.append(trimmed)
        }
        newTag = ""
    }
}

#Preview {
    TagChipEditor(tags: .constant(["work", "growth", "family"]))
        .environment(\.designSystem, DesignSystem())
        .padding()
}
