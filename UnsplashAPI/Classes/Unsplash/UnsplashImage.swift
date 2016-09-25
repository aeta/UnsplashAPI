/**
 Copyright 2016 Aeta
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */


import UIKit

struct ImageLocation {
    var city: String?
    var country: String?
    var position = LocationPosition()
}

struct LocationPosition {
    var latitude: Double?
    var longitude: Double?
}

struct ImageMetadata {
    var make: String?
    var model: String?
    var exposure_time: Double?
    var aperture: Double?
    var focal_length: Int?
    var iso: Int?
}

struct UserInformation {
    var id: String?
    var username: String?
    var name: String?
    var profile_image = ProfileImages()
    var links = UserLinks()
}

struct ProfileImages {
    var small: URL?
    var medium: URL?
    var large: URL?
}

struct UserLinks {
    var link: URL?
    var html: URL?
    var photos: URL?
    var likes: URL?
}

struct PhotoUrls {
    var raw: URL?
    var full: URL?
    var regular: URL?
    var small: URL?
    var thumb: URL?
    var custom: URL?
}

struct PhotoLinks {
    var link: URL?
    var html: URL?
    var download: URL?
}

/**
 Unsplash Image Object
 
 [Documentation](https://unsplash.com/documentation#photos)
 */
open class UnsplashImage {
    public let isAbbreviated: Bool!
    
    /// ID provided by UnsplashAPI
    public let id: String!
    
    /// Upload date of image
    public let created_at: Date?
    
    /// Resolution of image
    public let width: Int!
    public let height: Int!
    
    /// Overall color of image
    public let color: UIColor?
    
    /// Number of downloads of image from Unsplash
    public let downloads: Int?
    
    /// Number of linkes from Unsplash
    public let likes: Int?
    
    var exif = ImageMetadata()
    var location = ImageLocation()
    
    var user = UserInformation()
    var urls = PhotoUrls()
    var links = PhotoLinks()
    
    /**
     Initialize UnsplashImage using JSON as form of dictionary. If required values
     are nil, UnsplashImage may return nil.
     
     - parameter json: JSON as form of dictionary
     - parameter abbreviated: default false, must be set true if requesting from /photos rather than /photos/:id
     */
    public init?(fromDict json: [String: Any], abbreviated: Bool = false) {
        self.isAbbreviated = abbreviated
        self.id = json["id"] as! String
        
        self.width = json["width"] as! Int
        self.height = json["height"] as! Int
        
        self.color = UIColor(hex: json["color"] as! String)
        
        self.downloads = json["downloads"] as? Int
        self.likes = json["downloads"] as? Int
        
        // Location Data
        if let location = json["location"] as? [String: AnyObject] {
            self.location.city = location["city"] as? String
            self.location.country = location["country"] as? String
            if let position = location["position"] as? [String: AnyObject] {
                self.location.position.latitude = position["latitude"] as? Double
                self.location.position.longitude = position["longitude"] as? Double
            }
        }
        
        // EXIF Data
        if let exif = json["exif"] as? [String: AnyObject] {
            self.exif.make = exif["make"] as? String
            self.exif.model = exif["model"] as? String
            self.exif.exposure_time = exif["exposure_time"] as? Double
            self.exif.aperture = exif["aperture"] as? Double
            self.exif.focal_length = exif["focal_length"] as? Int
            self.exif.iso = exif["iso"] as? Int
        }
        
        // User Data
        if let user = json["user"] as? [String: AnyObject] {
            self.user.id = user["id"] as? String
            self.user.username = user["username"] as? String
            self.user.name = user["name"] as? String
            
            // Profile Images
            if let profile_image = user["profile_image"] as? [String: String] {
                self.user.profile_image.small = URL(string: profile_image["small"] ?? "")
                self.user.profile_image.medium = URL(string: profile_image["medium"] ?? "")
                self.user.profile_image.large = URL(string: profile_image["large"] ?? "")
            }
            
            // User Links
            if let links = user["links"] as? [String: String] {
                self.user.links.link = URL(string: links["self"]!)
                self.user.links.html = URL(string: links["html"]!)
                self.user.links.photos = URL(string: links["photos"]!)
                self.user.links.likes = URL(string: links["photos"]!)
            }
        }
        
        // Image Links
        if let urls = json["urls"] as? [String: String] {
            self.urls.raw = URL(string: urls["raw"]!)
            self.urls.full = URL(string: urls["full"]!)
            self.urls.regular = URL(string: urls["regular"]!)
            self.urls.small = URL(string: urls["small"]!)
            self.urls.thumb = URL(string: urls["thumb"]!)
            self.urls.custom = URL(string: urls["custom"] ?? "")
        }
        
        // Misc
        if let links = json["links"] as? [String: String] {
            self.links.link = URL(string: links["self"]!)
            self.links.html = URL(string: links["html"]!)
            self.links.download = URL(string: links["download"]!)
        }
        
        // Date
        let string = json["created_at"] as! String
        // Seperate into components to remove the time zone
        let components = string.components(separatedBy: "-")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        
        // Unsplash API returns times in GMT-4
        let timeZoneComponents = components[3].components(separatedBy: ":")
        let tz = TimeZone(identifier: "GMT-\(timeZoneComponents.first!)\(timeZoneComponents.last!)")
        formatter.timeZone = tz
        
        // Strip away the time zone and create the Date
        let date = formatter.date(from: "\(components[0])-\(components[1])-\(components[2])")
        
        self.created_at = date
    }
}
