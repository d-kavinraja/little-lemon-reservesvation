import SwiftUI

struct LocationsView: View {
    @EnvironmentObject var model:Model
    // The body of this view, which consists of:
    // - A logo image at the top
    // - A title that changes based on the value of `model.displayingReservationForm`
    // - A list of restaurants, each of which can be clicked to navigate to a reservation form for that restaurant
    var body: some View {
        VStack {
            // Logo
            LittleLemonLogo()
                .padding(.top, 50)
            // Changing title
            Text(model.displayingReservationForm ? "Reservation Details" : "Select a location")
                .padding([.leading, .trailing], 40)
                .padding([.top, .bottom], 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
            // List of restaurants
            // On small interfaces you can go down using tap as the view is placed in NavigationView
            NavigationView {
                List(model.restaurants, id: \.self) { restaurant in
                    NavigationLink(destination: ReservationForm(restaurant)) {
                        RestaurantView(restaurant)
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                }
                .listStyle(.plain)
            }
        }
        .padding(.top, -10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView().environmentObject(Model())
    }
}

