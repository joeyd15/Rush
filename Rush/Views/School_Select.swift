import SwiftUI

struct InitialSelectionView: View {
    @AppStorage("schoolName") var schoolName: String = ""
    @AppStorage("fraternityName") var fraternityName: String = ""
    @AppStorage("institutionSelected") var institutionSelected: Bool = false
    
    @State private var selectedSchool = "University of Tennessee Knoxville"
    @State private var selectedFrat = "Alpha Kappa Psi"
    
    let schools = ["University of Tennessee Knoxville", "Other"]
    let frats = ["Alpha Kappa Psi", "Other"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                
                // Header with orange background for "Rush UTK"
                ZStack {
                    Color.orange
                        .ignoresSafeArea(.all, edges: .top) // This pushes the color to the very top
                        .frame(height: 120)

                    Text("Rush UTK")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .scaleEffect(2)
                }
                
                // Display the local asset image.
                Image("TenneseeVolsLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                
                // The form for selecting school and fraternity/sorority.
                Form {
                    Section(header: Text("Select Your School")) {
                        Picker("School", selection: $selectedSchool) {
                            ForEach(schools, id: \.self) { school in
                                Text(school)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    Section(header: Text("Select Fraternity/Sorority")) {
                        Picker("Frat/Sorority", selection: $selectedFrat) {
                            ForEach(frats, id: \.self) { frat in
                                Text(frat)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // "Go" button that navigates to UserLoginView and saves the selections.
                NavigationLink(destination: UserLoginView()) {
                    Text("Go")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    schoolName = selectedSchool
                    fraternityName = selectedFrat
                    institutionSelected = true
                })
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct InitialSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        InitialSelectionView()
    }
}

