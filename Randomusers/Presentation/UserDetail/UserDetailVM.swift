//
//  UserDetailVM.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import Foundation

@MainActor
class UserDetailVM {
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var fullName: String {
        return user.name.fullName
    }
    
    var email: String {
        return user.email
    }
    
    var phone: String {
        return user.phone
    }
    
    var cell: String {
        return user.cell
    }
    
    var gender: String {
        return user.gender.capitalized
    }
    
    var nationality: String {
        return user.nat
    }
    
    var address: String {
        let street = user.location.street
        return "\(street.number) \(street.name), \(user.location.city), \(user.location.state), \(user.location.country)"
    }
    
    var postcode: String {
        return user.location.postcode.stringValue
    }
    
    var dateOfBirth: String {
        let dateString = user.dob.date
        return formatDate(dateString) + " (Age: \(user.dob.age))"
    }
    
    var registrationDate: String {
        let dateString = user.registered.date
        return formatDate(dateString) + " (Duration: \(user.registered.age) years)"
    }
    
    var pictureURL: URL? {
        return URL(string: user.picture.large)
    }
    
    private func formatDate(_ dateString: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: dateString) else {
            return dateString
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
}
