//
//  LoginView.swift
//  LivePolls
//
//  Created by Efe Koç on 31.12.2024.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoginSuccessful = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Text("MEETICA")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.bottom, 30)
                
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
                
                Button(action: login) {
                    Text("Oturum aç")
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .navigationDestination(isPresented: $isLoginSuccessful) {
                    HomeView()
                        .navigationBarBackButtonHidden(true)
                }
                
                NavigationLink {
                    SignUpView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack {
                        Text("Hesabınız yok mu?")
                        Text("Kaydol")
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

    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurun."
            showErrorAlert = true
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Firebase hata mesajlarını Türkçeleştir
                errorMessage = translateFirebaseError(error.localizedDescription)
                showErrorAlert = true
                isLoginSuccessful = false
            } else {
                isLoginSuccessful = true
            }
        }
    }

    private func translateFirebaseError(_ message: String) -> String {
        switch message {
        case "The email address is badly formatted.":
            return "E-posta adresi yanlış formatta."
        case "The password is invalid or the user does not have a password.":
            return "Hatalı şifre girdiniz."
        case "There is no user record corresponding to this identifier. The user may have been deleted.":
            return "Bu e-posta adresine ait bir hesap bulunamadı."
        default:
            return "Kayıtlı kullanıcı bulunamadı."
        }
    }
}

#Preview {
    LoginView()
}
