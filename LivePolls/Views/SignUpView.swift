import SwiftUI
import Firebase

struct SignUpView: View {
    @State private var firstname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var repeatPassword: String = ""
    
    @State private var isSignUpSuccessful = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Spacer()
                
                Text("MEETICA")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.bottom, 30)
                
                TextField("İsminizi giriniz", text: $firstname)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Capsule())
                    .autocapitalization(.words)
                
                TextField("Mailinizi giriniz", text: $email)
                    .padding()
                    .keyboardType(.emailAddress)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Capsule())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Şifrenizi giriniz", text: $password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Capsule())
                
                SecureField("Şifrenizi tekrar giriniz", text: $repeatPassword)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Capsule())
                
                Button(action: signUp) {
                    Text("Kayıt ol")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .navigationDestination(isPresented: $isSignUpSuccessful) {
                    HomeView()
                        .navigationBarBackButtonHidden(true)
                }
                
                NavigationLink {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack {
                        Text("Zaten bir hesabınız var mı?")
                        Text("Oturum aç")
                            .bold()
                            .foregroundColor(Color.accentColor)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color(UIColor.systemBackground))
            .alert("Hata", isPresented: $showErrorAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func signUp() {
        guard !firstname.isEmpty, !email.isEmpty, !password.isEmpty, !repeatPassword.isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurun."
            showErrorAlert = true
            return
        }
        
        guard password == repeatPassword else {
            errorMessage = "Şifreler uyuşmuyor!"
            showErrorAlert = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Firebase hata mesajlarını Türkçeleştir
                errorMessage = translateFirebaseError(error.localizedDescription)
                showErrorAlert = true
                isSignUpSuccessful = false
            } else {
                isSignUpSuccessful = true
            }
        }
    }

    private func translateFirebaseError(_ message: String) -> String {
        switch message {
        case "The email address is badly formatted.":
            return "Geçersiz bir e-posta adresi girdiniz."
        case "The password must be 6 characters long or more.":
            return "Şifre en az 6 karakterden oluşmalıdır."
        case "The email address is already in use by another account.":
            return "Bu e-posta adresi zaten kullanılıyor."
        default:
            return "Bir hata oluştu. Lütfen tekrar deneyin."
        }
    }
}

#Preview {
    SignUpView()
}
