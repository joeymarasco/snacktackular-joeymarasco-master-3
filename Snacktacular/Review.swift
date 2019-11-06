//
//  Review.swift
//  Snacktacular
//
//  Created by Joseph Marasco on 11/6/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["title": title, "text": text, "rating": rating, "reviewUserID": reviewUserID, "date": date, "documentID": documentID]
    }
    
    
    init(title: String, text: String, rating: Int, reviewUserID: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewUserID = reviewUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(title: "", text: "", rating: 0, reviewUserID: currentUserID, date: Date(), documentID: "")
    }
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()

        // Create the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we have saved a record, well have a document ID
        if self.documentID != "" {
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(self.dictionary) { (error) in
                if let error = error {
                    print("****ERROR: updating document \(self.documentID) in spot \(spot.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Document updated with refID \(ref.documentID)")
                    completed(true)
                }
                
            }
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("****ERROR: creating new document in spot \(spot.documentID) for new review documentID \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Document created with refID \(ref?.documentID ?? "unknown")")
                    completed(true)
                }
                
            }
        }
    }
}
