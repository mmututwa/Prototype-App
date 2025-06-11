import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var isShowingSignUp = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 30) {
                logoSection
                
                if isShowingSignUp {
                    SignUpView(authService: authService, isShowingSignUp: $isShowingSignUp)
                } else {
                    LoginView(authService: authService, isShowingSignUp: $isShowingSignUp)
                }
            }
            .padding(.horizontal, 32)
        }
    }
    
    private var logoSection: some View {
        VStack(spacing: 16) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
            
            Text("ProtoType.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Learn Football Like Never Before")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

struct LoginView: View {
    @ObservedObject var authService: AuthenticationService
    @Binding var isShowingSignUp: Bool
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text("Welcome Back")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(AuthTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(AuthTextFieldStyle())
                }
                
                // Error Message
                if let errorMessage = authService.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Login Button
            Button(action: {
                Task {
                    await authService.signIn(email: email, password: password)
                }
            }) {
                HStack {
                    if authService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
            
            // Sign Up Link
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.white.opacity(0.8))
                
                Button("Sign Up") {
                    isShowingSignUp = true
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
    }
}

struct SignUpView: View {
    @ObservedObject var authService: AuthenticationService
    @Binding var isShowingSignUp: Bool
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text("Create Account")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                // First Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    TextField("Enter your first name", text: $firstName)
                        .textFieldStyle(AuthTextFieldStyle())
                        .textInputAutocapitalization(.words)
                }
                
                // Last Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    TextField("Enter your last name", text: $lastName)
                        .textFieldStyle(AuthTextFieldStyle())
                        .textInputAutocapitalization(.words)
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(AuthTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    SecureField("Create a password", text: $password)
                        .textFieldStyle(AuthTextFieldStyle())
                }
                
                // Confirm Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    SecureField("Confirm your password", text: $confirmPassword)
                        .textFieldStyle(AuthTextFieldStyle())
                }
                
                // Error Message
                if let errorMessage = authService.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                // Password mismatch warning
                if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Passwords do not match")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Sign Up Button
            Button(action: {
                Task {
                    await authService.signUp(email: email, password: password, firstName: firstName, lastName: lastName)
                }
            }) {
                HStack {
                    if authService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authService.isLoading || !isFormValid)
            
            // Sign In Link
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.white.opacity(0.8))
                
                Button("Sign In") {
                    isShowingSignUp = false
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && 
        !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
    }
}

struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(.white)
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationService())
        .preferredColorScheme(.dark)
} 