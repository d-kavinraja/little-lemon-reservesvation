import SwiftUI

struct ReservationForm: View {
    
    @EnvironmentObject var model:Model
    @State var showFormInvalidMessage = false
    @State var errorMessage = ""
    
    
    private var restaurant:RestaurantLocation
    @State var reservationDate = Date()
    @State var party:Int = 1
    @State var specialRequests:String = ""
    @State var customerName = ""
    @State var customerPhoneNumber = ""
    @State var customerEmail = ""
    
    
    // this environment variable stores the presentation mode status
    // of this view. This will be used to dismiss this view when
    // the user taps on the RESERVE
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // stores a temporary reservation used by this view
    @State private var temporaryReservation = Reservation()
    
    // this flag will trigger .onChange
    // this is necessary because due to to a SwiftUI limitation, we cannot change the model
    // values from withing the view itself, as it is being drawn (inside the button)
    // so, this flag will defer the change
    @State var mustChangeReservation = false
    
    init(_ restaurant:RestaurantLocation) {
        self.restaurant = restaurant
    }
    
    var body: some View {
        VStack {
            Form {
                // Restaurant information
                RestaurantView(restaurant)
                
                // Shows the party information
                HStack {
                    VStack (alignment: .leading) {
                        Text("PARTY")
                            .font(.subheadline)
                        
                        TextField("",
                                  value: $party,
                                  formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        // A check on the number of guests.
                        .onChange(of: party) { value in
                            if value == 0 { party = 1 }
                        }
                    }
                    
                    
                    // DATE PICKER
                    VStack {
                        
                        // This shows the date picker
                        // the option in:Date()... allows any date to be
                        // selected from today forward.
                        // if the option was in:...Date(), any date from the past up
                        // to today could be selected
                        //
                        // displayedComponents specify that date and time must be displayed
                        DatePicker(selection: $reservationDate, in: Date()...,
                                   displayedComponents: [.date, .hourAndMinute]) {
                            //              Text("Select a date")
                        }
                    }
                }
                .padding([.top, .bottom], 20)
                
                
                
                // Textfields showing informations like customer
                // name, phone, email, and special requests
                Group{
                    Group{
                        HStack{
                            Text("NAME: ")
                                .font(.subheadline)
                            TextField("Your name...",
                                      text: $customerName)
                            
                        }
                        
                        HStack{
                            Text("PHONE: ")
                                .font(.subheadline)
                            
                            TextField("Your phone number...",
                                      text: $customerPhoneNumber)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                        }
                        
                        HStack{
                            Text("E-MAIL: ")
                                .font(.subheadline)
                            TextField("Your e-mail...",
                                      text: $customerEmail)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        }
                        
                        
                        TextField("add any special request (optional)",
                                  text: $specialRequests,
                                  axis:.vertical)
                        .padding()
                        .overlay( RoundedRectangle(cornerRadius: 20).stroke(.gray.opacity(0.2)) )
                        .lineLimit(6)
                        .padding([.top, .bottom], 20)
                    }
                    
                    
                    // add the RESERVE button
                    Button(action: {
                        // Checking the form for correctly entered information
                        validateForm()
                    }, label: {
                        Text("CONFIRM RESERVATION")
                    })
                    .padding(.init(top: 10, leading: 30, bottom: 10, trailing: 30))
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .padding(.top, 10)
                }
            }
            
            // Forms have this space between the title and the content
            // that is amost impossible to remove without incurring
            // into complex steps that run out of the scope of this
            // course. So, this is a hack, to bring the content up
            // try to comment this line and see what happens.
            .padding(.top, -40)
            
            // makes the form background invisible
            // the original color is gray
            .scrollContentBackground(.hidden)
            
            .onChange(of: mustChangeReservation) { _ in
                model.reservation = temporaryReservation
            }
            // Alert with mistake form
            .alert("Error", isPresented: $showFormInvalidMessage, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(self.errorMessage)
            })
        }
        .onAppear {
            model.displayingReservationForm = true
        }
        .onDisappear {
            model.displayingReservationForm = false
        }
    }
    
    private func validateForm() {
        
        // customerName must contain just letters
        let nameIsValid = isValid(name: customerName)
        let emailIsValid = isValid(email: customerEmail)
        
        guard nameIsValid && emailIsValid
        else {
            var invalidNameMessage = ""
            if customerName.isEmpty || !isValid(name: customerName) {
                invalidNameMessage = "Names can only contain letters and must have at least 3 characters\n\n"
            }
            
            var invalidPhoneMessage = ""
            // Checking for a phone number
            if customerPhoneNumber.isEmpty {
                invalidPhoneMessage = "The phone number cannot be blank.\n\n"
            }
            
            var invalidEmailMessage = ""
            if !customerEmail.isEmpty || !isValid(email: customerEmail) {
                invalidEmailMessage = "The e-mail is invalid and cannot be blank."
            }
            
            self.errorMessage = "Found these errors in the form:\n\n \(invalidNameMessage)\(invalidPhoneMessage)\(invalidEmailMessage)"
            
            showFormInvalidMessage.toggle()
            return
        }
        
        // form is valid, proceed
        
        // create new temporary reservation
        let temporaryReservation = Reservation(restaurant:restaurant,
                                               customerName: customerName,
                                               customerEmail: customerEmail,
                                               customerPhoneNumber: customerPhoneNumber,
                                               reservationDate:reservationDate,
                                               party:party,
                                               specialRequests:specialRequests)
        
        // Store the temporary reservation locally
        self.temporaryReservation = temporaryReservation
        
        // set the flag to defer changing to the model (see .onChange)
        self.mustChangeReservation.toggle()
        
        // dismiss this view
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func isValid(name: String) -> Bool {
        guard !name.isEmpty,
              name.count > 2
        else { return false }
        for chr in name {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") && !(chr == " ") ) {
                return false
            }
        }
        return true
    }
    
    func isValid(email:String) -> Bool {
        guard !email.isEmpty else { return false }
        let emailValidationRegex = "^[\\p{L}0-9!#$%&'*+\\/=?^_`{|}~-][\\p{L}0-9.!#$%&'*+\\/=?^_`{|}~-]{0,63}@[\\p{L}0-9-]+(?:\\.[\\p{L}0-9-]{2,7})*$"
        let emailValidationPredicate = NSPredicate(format: "SELF MATCHES %@", emailValidationRegex)
        return emailValidationPredicate.evaluate(with: email)
    }
    
    
}

struct ReservationForm_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRestaurant = RestaurantLocation(city: "Las Vegas", neighborhood: "Downtown", phoneNumber: "(702) 555-9898")
        ReservationForm(sampleRestaurant).environmentObject(Model())
    }
}









