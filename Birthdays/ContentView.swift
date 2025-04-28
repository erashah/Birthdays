//
//  ContentView.swift
//  Birthdays
//
//  Created by Era Shah on 4/27/25.
//

import SwiftUI
import SwiftData // framework for data modeling & management

struct ContentView: View {
    @Query private var friends: [Friend]
    @Environment(\.modelContext) private var context
    @State private var newName = ""
    @State private var newBirthday = Date.now
    @State private var selectedFriend: Friend?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(friends) { friend in
                        HStack {
                            if Calendar.current.isDate(friend.birthday, equalTo: Date(), toGranularity: .day) {
                                    Text("🎂 \(friend.name)")
                            } // adds birthday cake if friend's birthday is today
                            else {
                                Text(friend.name)
                            }
                            Spacer() // takes up all available space
                            Text(friend.birthday, format: .dateTime.month(.wide).day().year())
                        }
                        .onTapGesture {
                            selectedFriend = friend
                        }
                }
                .onDelete(perform: deleteFriend)
            }
            .navigationTitle("Birthdays")
            .sheet(item: $selectedFriend) { friend in
                NavigationStack {
                    EditFriendView(friend: friend)
                }
            }
            
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center, spacing: 20) {
                    Text("New Birthday")
                        .font(.headline)
                    DatePicker(selection: $newBirthday, in: Date.distantPast...Date.now, displayedComponents: .date) {
                        TextField("Name", text: $newName)
                            .textFieldStyle(.roundedBorder)
                    }
                    Button("Save") {
                        let newFriend = Friend(name: newName, birthday: newBirthday)
                        context.insert(newFriend)
                        newName = ""
                        newBirthday = Date.now
                    }
                    .bold()
                }
                .padding()
                .background(.bar)
            }
        }
    }
    
    func deleteFriend(at offsets: IndexSet) {
            for index in offsets {
                    let friendToDelete = friends[index]
                    context.delete(friendToDelete)
            }
    }
}



#Preview {
    ContentView()
        .modelContainer(for: Friend.self, inMemory: true)
}
