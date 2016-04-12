
/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import CloudKit
import MapKit

struct ChangingTableLocation : OptionSetType, BooleanType {
  var rawValue: UInt = 0
  var boolValue:Bool {
    get {
      return self.rawValue != 0
    }
  }
  init(rawValue: UInt) { self.rawValue = rawValue }
  init(nilLiteral: ()) { self.rawValue = 0 }
  func toRaw() -> UInt { return self.rawValue }
  static func convertFromNilLiteral() -> ChangingTableLocation { return .None}
  static func fromRaw(raw: UInt) -> ChangingTableLocation? { return self.init(rawValue: raw) }
  static func fromMask(raw: UInt) -> ChangingTableLocation { return self.init(rawValue: raw) }
  static var allZeros: ChangingTableLocation { return self.init(rawValue: 0) }

  static var None: ChangingTableLocation   { return self.init(rawValue: 0) }      //0
  static var Mens: ChangingTableLocation   { return self.init(rawValue: 1 << 0) } //1
  static var Womens: ChangingTableLocation { return self.init(rawValue: 1 << 1) } //2
  static var Family: ChangingTableLocation { return self.init(rawValue: 1 << 2) } //4
  
  func images() -> [UIImage] {
    var images = [UIImage]()
    if self.intersect(.Mens) {
      images.append(UIImage(named: "man")!)
    }
    if self.intersect(.Womens) {
      images.append(UIImage(named: "woman")!)
    }
    
    return images
  }
}

func == (lhs: ChangingTableLocation, rhs: ChangingTableLocation) -> Bool     { return lhs.rawValue == rhs.rawValue }
func | (lhs: ChangingTableLocation, rhs: ChangingTableLocation) -> ChangingTableLocation { return ChangingTableLocation(rawValue: lhs.rawValue | rhs.rawValue) }
func & (lhs: ChangingTableLocation, rhs: ChangingTableLocation) -> ChangingTableLocation { return ChangingTableLocation(rawValue: lhs.rawValue & rhs.rawValue) }
func ^ (lhs: ChangingTableLocation, rhs: ChangingTableLocation) -> ChangingTableLocation { return ChangingTableLocation(rawValue: lhs.rawValue ^ rhs.rawValue) }


struct SeatingType : OptionSetType, BooleanType {
  var rawValue: UInt = 0
  var boolValue:Bool {
    get {
      return self.rawValue != 0
    }
  }
  init(rawValue: UInt) { self.rawValue = rawValue }
  init(nilLiteral: ()) { self.rawValue = 0 }
  func toRaw() -> UInt { return self.rawValue }
  static func convertFromNilLiteral() -> SeatingType { return .None}
  static func fromRaw(raw: UInt) -> SeatingType? { return self.init(rawValue: raw) }
  static func fromMask(raw: UInt) -> SeatingType { return self.init(rawValue: raw) }
  static var allZeros: SeatingType { return self.init(rawValue: 0) }
  
  static var None:      SeatingType { return self.init(rawValue: 0) }      //0
  static var Booster:   SeatingType { return self.init(rawValue: 1 << 0) } //1
  static var HighChair: SeatingType { return self.init(rawValue: 1 << 1) } //2
  
  func images() -> [UIImage] {
    var images = [UIImage]()
    if self.intersect(.Booster) {
      images.append(UIImage(named: "booster")!)
    }
    if self.intersect(.HighChair) {
      images.append(UIImage(named: "highchair")!)
    }
    
    return images
  }
}

func == (lhs: SeatingType, rhs: SeatingType) -> Bool     { return lhs.rawValue == rhs.rawValue }
func | (lhs: SeatingType, rhs: SeatingType) -> SeatingType { return SeatingType(rawValue: lhs.rawValue | rhs.rawValue) }
func & (lhs: SeatingType, rhs: SeatingType) -> SeatingType { return SeatingType(rawValue: lhs.rawValue & rhs.rawValue) }
func ^ (lhs: SeatingType, rhs: SeatingType) -> SeatingType { return SeatingType(rawValue: lhs.rawValue ^ rhs.rawValue) }

class Establishment : NSObject, MKAnnotation {
  
  var record : CKRecord!
  var name : String!
  var location : CLLocation!
  weak var database : CKDatabase!
  
  var assetCount = 0
  
  var healthyChoice : Bool {
  get {
    let trueResult = 1
    let newRecord = record.objectForKey("HealthyOption")
    if let newRecord = newRecord {
        let result = newRecord.isEqual(trueResult)
        return result
    } else {
        return false
    }
  }
  }
  
  var kidsMenu: Bool {
  get {
    let trueResult = 1
    let newRecord = record.objectForKey("KidsMenu")
    if let newRecord = newRecord {
        let result = newRecord.isEqual(trueResult)
        return result
    } else {
        return false
    }
 
  }
  }
  
  init(record : CKRecord, database: CKDatabase) {
    self.record = record
    self.database = database
    
    self.name = record.objectForKey("Name") as! String
    self.location = record.objectForKey("Location") as! CLLocation
  }
  
  func fetchRating(completion: (rating: Double, isUser: Bool) -> ()) {
    Model.sharedInstance().userInfo.userID() { userRecord, error in
      self.fetchRating(userRecord, completion: completion)
    }
  }
  
  func fetchRating(userRecord: CKRecordID!, completion: (rating: Double, isUser: Bool) -> ()) {
    //REPLACE THIS STUB
    completion(rating: 0, isUser: false)
  }

  func fetchNote(completion: (note: String!) -> ()) {
    Model.sharedInstance().fetchNote(self) { note, error in
      completion(note: note)
    }
  }
  
  func fetchPhotos(completion:(assets: [CKRecord]!)->()) {
    let predicate = NSPredicate(format: "Establishment == %@", record)
    let query = CKQuery(recordType: "EstablishmentPhoto", predicate: predicate);
    //Intermediate Extension Point - with cursors
    database.performQuery(query, inZoneWithID: nil) { results, error in
      if error == nil {
        self.assetCount = results!.count
      }
      completion(assets: results! as [CKRecord])
    }
  }
  
  func changingTable() -> ChangingTableLocation {
    let changingTable = record?.objectForKey("ChangingTable") as? NSNumber
    var val:UInt = 0;
    if let changingTableNum = changingTable {
      val = changingTableNum.unsignedLongValue
    }
    return ChangingTableLocation(rawValue: val)
  }
  
  func seatingType() -> SeatingType {
    let seatingType = record?.objectForKey("SeatingType") as? NSNumber
    var val:UInt = 0;
    if let seatingTypeNum = seatingType {
      val = seatingTypeNum.unsignedLongValue
    }
    return SeatingType(rawValue: val)
  }

  func loadCoverPhoto(completion:(photo: UIImage!) -> ()) {
    //replace this stub
    //1 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
        var image: UIImage!
        //2 
        if let asset = self.record.objectForKey("CoverPhoto") as? CKAsset {
            let url = asset.fileURL
            let path = url.path
            if let path = path {
                if let imageData = NSData(contentsOfFile: path) {
                    //4
                    image = UIImage(data: imageData)
                }
            }
        }
        completion(photo: image)
    }
  }
  
  //MARK: - map annotation
  
  var coordinate : CLLocationCoordinate2D {
  get {
    return location.coordinate
  }
  }
  var title : String? {
  get {
    return name
  }
  }
  

}