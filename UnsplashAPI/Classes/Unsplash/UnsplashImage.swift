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

struct UnsplashImageLocation {
    /// Full name of location (e.g. ``Pike Place Market, Seattle, United States``)
    let title: String?
    
    /// Truncated name of location, typically just the name of the point of interest (e.g. ``Pike Place Market``)
    let name: String?
    
    /// Image's city (e.g. ``Seattle``)
    let city: String?
    
    /// Image's country (e.g. ``United States``)
    let country: String?
    
    /// Image's specific coordinates (latitude & longitude)
    private(set) var position: UnsplashLocationPosition?
    
    init?(fromDict dict: [String: Any]) {
        self.title = dict["title"] as? String
        self.name = dict["name"] as? String
        self.city = dict["city"] as? String
        self.country = dict["country"] as? String
        if let position = dict["position"] as? [String: Double] {
            self.position = UnsplashLocationPosition(fromDict: position)
        }
    }
}

struct UnsplashLocationPosition {
    /// Latitude coordinate of image's location
    let latitude: Double?
    
    /// Longitude coordinate of image's location
    let longitude: Double?
    
    init?(fromDict dict: [String: Double]) {
        self.latitude = dict["latitude"]
        self.longitude = dict["longitude"]
    }
}

struct UnsplashImageMetadata {
    /// Make of camera
    let make: String?
    
    /// Model of camera
    let model: String?
    
    /// Exposure time of camera
    let exposure_time: Double?
    
    /// Aperture of camera
    let aperture: Double?
    
    /// Focal length of camera
    let focal_length: Int?
    
    /// ISO of camera
    let iso: Int?
    
    init?(fromDict dict: [String: Any]) {
        self.make = dict["make"] as? String
        self.model = dict["model"] as? String
        self.exposure_time = dict["exposure_time"] as? Double
        self.aperture = dict["aperure"] as? Double
        self.focal_length = dict["focal_length"] as? Int
        self.iso = dict["iso"] as? Int
    }
}

struct UnsplashImageUserInformation {
    /// User's UnsplashAPI ID
    let id: String!
    
    /// User's username
    let username: String!
    
    /// User's full name (if exists)
    let name: String?
    
    /// User's profile image (if exists)
    private(set) var profile_image: UnsplashProfileImages!
    
    /// User's user interaction links
    private(set) var links: UnsplashUserLinks!
    
    init?(fromDict dict: [String: Any]) {
        self.id = dict["id"] as! String
        self.username = dict["username"] as! String
        self.name = dict["name"] as? String
        if let profile_image = dict["profile_image"] as? [String: String] {
            self.profile_image = UnsplashProfileImages(fromDict: profile_image)
        }
        
        if let links = dict["links"] as? [String: String] {
            self.links = UnsplashUserLinks(fromDict: links)
        }
    }
}

struct UnsplashProfileImages {
    /// Small resolution
    let small: URL?
    
    /// Medium resolution
    let medium: URL?
    
    /// Full resolution
    let large: URL?
    
    init?(fromDict dict: [String: String]) {
        self.small = URL(string: dict["small"] ?? "")
        self.medium = URL(string: dict["medium"] ?? "")
        self.large = URL(string: dict["large"] ?? "")
    }
}

struct UnsplashUserLinks {
    /// UnsplashAPI link
    let link: URL!
    
    /// HTML link (useful for giving the user a non-API interaction link)
    let html: URL!
    
    /// UnsplashAPI link for user's photos
    let photos: URL!
    
    /// UnsplashAPI link for user's liked photos
    let likes: URL!
    
    /// UnsplashAPI link for user's portfolio URL
    let portfolio: URL!
    
    /// UnsplashAPI link for user's following list
    let following: URL!
    
    /// UnsplashAPI link for user's followers list
    let followers: URL!
    
    init?(fromDict dict: [String: String]) {
        guard let link = dict["self"],
            let html = dict["html"],
            let photos = dict["photos"],
            let likes = dict["likes"],
            let portfolio = dict["portfolio"],
            let following = dict["following"],
            let followers = dict["followers"] else {
                return nil
        }
        self.link = URL(string: link)
        self.html = URL(string: html)
        self.photos = URL(string: photos)
        self.likes = URL(string: likes)
        self.portfolio = URL(string: portfolio)
        self.following = URL(string: following)
        self.followers = URL(string: followers)
    }
}

struct UnsplashPhotoURLs {
    let raw: URL!
    let full: URL!
    let regular: URL!
    let small: URL!
    let thumb: URL!
    let custom: URL?
    
    init?(fromDict dict: [String: String]) {
        guard let raw = dict["raw"],
            let full = dict["full"],
            let regular = dict["regular"],
            let small = dict["small"],
            let thumb = dict["thumb"] else {
                return nil
        }
        self.raw = URL(string: raw)
        self.full = URL(string: full)
        self.regular = URL(string: regular)
        self.small = URL(string: small)
        self.thumb = URL(string: thumb)
        self.custom = URL(string: dict["custom"] ?? "")
    }
}

struct UnsplashPhotoLinks {
    let link: URL!
    let html: URL!
    let download: URL!
    
    init?(fromDict dict: [String: String]) {
        guard let link = dict["self"],
            let html = dict["html"],
            let download = dict["download"] else {
                return nil
        }
        self.link = URL(string: link)
        self.html = URL(string: html)
        self.download = URL(string: download)
    }
}

/**
 Unsplash Image Object
 
 [Documentation](https://unsplash.com/documentation#photos)
 */
open class UnsplashImage {
    let isAbbreviated: Bool!
    
    /// ID provided by UnsplashAPI
    let id: String!
    
    /// Image published date
    let created_at: Date!
    
    /// Width of image
    let width: Int!
    
    /// Height of image
    let height: Int!
    
    /// Overall color of image (calculated by UnsplashAPI)
    let color: UIColor!
    
    /// Number of downloads of image (provided by UnsplashAPI)
    let downloads: Int?
    
    /// Number of likes from Unsplash (provided by UnsplashAPI)
    let likes: Int?
    
    private(set) var exif: UnsplashImageMetadata?
    private(set) var location: UnsplashImageLocation?
    
    private(set) var user: UnsplashImageUserInformation!
    private(set) var urls: UnsplashPhotoURLs!
    private(set) var links: UnsplashPhotoLinks!
    
    /**
     Initialize UnsplashImage using JSON as form of dictionary. If required values
     are nil, UnsplashImage may return nil.
     
     - parameter json: JSON as form of dictionary
     - parameter abbreviated: default false, must be set true if requesting from /photos rather than /photos/:id
     */
    public init?(fromDict json: [String: Any], abbreviated: Bool = false) {
        self.isAbbreviated = abbreviated
        
        guard let id = json["id"] as? String,
            let createdAt = json["created_at"] as? String,
            let width = json["width"] as? Int,
            let height = json["height"] as? Int,
            let color = json["color"] as? String else {
                return nil
        }
        
        self.id = id
        self.created_at = createdAt.toDate()
        self.width = width
        self.height = height
        
        self.color = UIColor(hex: color)
        
        self.downloads = json["downloads"] as? Int
        self.likes = json["downloads"] as? Int
        
        guard let user = json["user"] as? [String: Any],
            let urls = json["urls"] as? [String: String],
            let links = json["links"] as? [String: String] else {
                return nil
        }
        
        // Location Data
        if let location = json["location"] as? [String: Any] {
            self.location = UnsplashImageLocation(fromDict: location)
        }
        
        // EXIF Data
        if let exif = json["exif"] as? [String: Any] {
            self.exif = UnsplashImageMetadata(fromDict: exif)
        }
        self.user = UnsplashImageUserInformation(fromDict: user)
        self.urls = UnsplashPhotoURLs(fromDict: urls)
        self.links = UnsplashPhotoLinks(fromDict: links)
    }
}
