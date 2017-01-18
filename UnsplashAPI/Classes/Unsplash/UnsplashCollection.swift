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


struct UnsplashCollectionCoverPhoto {
    /// Cover photo's UnsplashAPI ID
    let id: String!
    
    /// Width of cover photo
    let width: Int!
    
    /// Height of cover photo
    let height: Int!
    
    /// Overall color of cover photo (calculated by UnsplashAPI)
    let color: UIColor!
    
    /// User likes for cover photo
    let likes: Int!
    
    /// Has the logged in user liked this photo?
    let liked_by_user: Bool?
    
    /// Cover photo user details
    private(set) var user: UnsplashCollectionUser!
    
    /// Cover photo URLs
    private(set) var urls: UnsplashPhotoURLs!
    
    /// Cover photo's user interaction links
    private(set) var links: UnsplashPhotoLinks!
    
    init?(fromDict dict: [String: Any]) {
        guard let id = dict["id"] as? String,
            let width = dict["width"] as? Int,
            let height = dict["height"] as? Int,
            let color = dict["color"] as? String,
            let likes = dict["likes"] as? Int else {
                return nil
        }
        self.id = id
        self.width = width
        self.height = height
        self.color = UIColor(hex: color)
        self.likes = likes
        self.liked_by_user = dict["liked_by_user"] as? Bool
        
        guard let user = dict["user"] as? [String: Any],
            let urls = dict["urls"] as? [String: String],
            let links = dict["links"] as? [String: String] else {
                return nil
        }
        
        self.user = UnsplashCollectionUser(fromDict: user)
        self.urls = UnsplashPhotoURLs(fromDict: urls)
        self.links = UnsplashPhotoLinks(fromDict: links)
    }
}

struct UnsplashCollectionUser {
    /// User's UnsplashAPI ID
    let id: String!
    
    /// User's username
    let username: String!
    
    /// User's full name (if exists)
    let name: String?
    
    /// User's specified portfolio URL (if exists)
    let portfolioURL: URL?
    
    /// User's bio (if exists)
    let bio: String?
    
    /// User's location (if exists)
    let location: String?
    
    /// Total likes on user's photos
    let totalLikes: Int!
    
    /// Total uploaded photos
    let totalPhotos: Int!
    
    /// Total created collections
    let totalCollections: Int!
    
    /// User's profile image (if exists)
    private(set) var profile_image: UnsplashProfileImages?
    
    /// User's user interaction links
    private(set) var links: UnsplashUserLinks!
    
    init?(fromDict dict: [String: Any]) {
        guard let id = dict["id"] as? String,
            let username = dict["username"] as? String,
            let totalLikes = dict["total_likes"] as? Int,
            let totalPhotos = dict["total_photos"] as? Int,
            let totalCollections = dict["total_collections"] as? Int else {
                return nil
        }
        self.id = id
        self.username = username
        self.name = dict["name"] as? String
        self.portfolioURL = URL(string: dict["portfolio_url"] as? String ?? "")
        self.bio = dict["bio"] as? String
        self.location = dict["location"] as? String
        self.totalLikes = totalLikes
        self.totalPhotos = totalPhotos
        self.totalCollections = totalCollections
        if let profile_image = dict["profile_image"] as? [String: String] {
            self.profile_image = UnsplashProfileImages(fromDict: profile_image)
        }
        if let links = dict["links"] as? [String: String] {
            self.links = UnsplashUserLinks(fromDict: links)
        }
    }
}

struct UnsplashCollectionLinks {
    /// UnsplashAPI link
    var link: URL!
    
    /// HTML link (useful for giving the user a non-API interaction link)
    var html: URL!
    
    /// UnsplashAPI link for collection's photos
    var photos: URL!
    
    /// UnsplashAPI link for related collections (will not exist for curated collections in accordance to UnsplashAPI specs - [reference](https://unsplash.com/documentation#collections))
    var related: URL?
    
    init?(fromDict dict: [String: String]) {
        guard let link = dict["self"],
            let html = dict["html"],
            let photos = dict["photos"] else {
                return nil
        }
        self.link = URL(string: link)
        self.html = URL(string: html)
        self.photos = URL(string: photos)
        self.related = URL(string: dict["related"] ?? "")
    }
}

/**
 Unsplash Collection Object
 
 [Documentation](https://unsplash.com/documentation#collections)
 */
open class UnsplashCollection {
    /// ID provided by UnsplashAPI
    let id: Int!
    
    /// Collection title
    let title: String!
    
    /// Collection description
    let description: String?
    
    /// Collection's published date
    let published_at: Date!
    
    /// Is this collection curated as defined by UnsplashAPI
    let curated: Bool!
    
    /// Is this collection featured as defined by UnsplashAPI
    let featured: Bool!
    
    /// Total photos in collection
    let totalPhotos: Int!
    
    /// Is this collection private as defined by UnsplashAPI
    let isPrivate: Bool!
    
    /// If a user is authorized, a share key will be provided
    public let shareKey: String?
    
    /// Collection's cover photo (if exists)
    private(set) var cover_photo: UnsplashCollectionCoverPhoto?
    
    /// Collection's owner
    private(set) var user: UnsplashCollectionUser!
    
    /// Collection's user interaction links
    private(set) var links: UnsplashCollectionLinks!
    
    /**
     Initialize UnsplashCollection using JSON as form of dictionary. If required values
     are nil, UnsplashCollection may return nil.
     
     - parameter json: JSON as form of dictionary
     */
    public init?(fromDict json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let published_at = json["published_at"] as? String,
            let curated = json["curated"] as? Bool,
            let featured = json["featured"] as? Bool,
            let totalPhotos = json["total_photos"] as? Int,
            let isPrivate = json["private"] as? Bool else {
                return nil
        }
        
        self.id = id
        self.title = title
        self.description = json["description"] as? String
        self.published_at = published_at.toDate()
        self.curated = curated
        self.featured = featured
        self.totalPhotos = totalPhotos
        self.isPrivate = isPrivate
        self.shareKey = json["share_key"] as? String
        
        guard let user = json["user"] as? [String: Any],
            let links = json["links"] as? [String: String] else {
                return nil
        }
        
        if let cover_photo = json["cover_photo"] as? [String: Any] {
            self.cover_photo = UnsplashCollectionCoverPhoto(fromDict: cover_photo)
        }
        
        self.user = UnsplashCollectionUser(fromDict: user)
        self.links = UnsplashCollectionLinks(fromDict: links)
    }
}
