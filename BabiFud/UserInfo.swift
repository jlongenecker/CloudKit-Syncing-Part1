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

class UserInfo {
  
  let container : CKContainer
  var userRecordID : CKRecordID!
  var contacts = [AnyObject]()
  
  init (container : CKContainer) {
    self.container = container;
  }
  
  func loggedInToICloud(completion : (accountStatus : CKAccountStatus, error : NSError!) -> ()) {
    container.accountStatusWithCompletionHandler() { status, error in
        completion(accountStatus: status, error: error)
    }
    completion(accountStatus: .CouldNotDetermine, error: nil)
  }
  
  func userID(completion: (userRecordID: CKRecordID!, error: NSError!)->()) {
    //1
    if userRecordID != nil {
      completion(userRecordID: userRecordID, error: nil)
    } else {
        //2
      self.container.fetchUserRecordIDWithCompletionHandler() {
        recordID, error in
        //3
        if recordID != nil {
          //4
            self.userRecordID = recordID
        }
        completion(userRecordID: recordID, error: error)
      }
    }
  }
  
  func userInfo(recordID: CKRecordID!,
    completion:(userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
      //replace this stub
    container.discoverUserInfoWithUserRecordID(recordID) { discoveredUserInfo, error in
        completion(userInfo: discoveredUserInfo, error: error)
        }
    }
  
  func requestDiscoverability(completion: (discoverable: Bool) -> ()) {
    //replace this stub
    //1
    container.statusForApplicationPermission(.UserDiscoverability) { status, error in
        //2 
        if error != nil || status == CKApplicationPermissionStatus.Denied {
            print("Status \(status)")
            completion(discoverable: false)
        } else {
            //3 
            self.container.requestApplicationPermission(.UserDiscoverability) { status, error in
                completion(discoverable: status == .Granted)
            }
        }
    }
    completion(discoverable: false)
  }
  
  func userInfo(completion: (userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
    print("UserInfo Method Called")
    requestDiscoverability() { discoverable in
      self.userID() { recordID, error in
        if error != nil {
          completion(userInfo: nil, error: error)
        } else {
          self.userInfo(recordID, completion: completion)
        }
      }
    }
  }
  
  func findContacts(completion: (userInfos:[AnyObject]!, error: NSError!)->()) {
    completion(userInfos: [CKRecordID](), error: nil)
  }
}

