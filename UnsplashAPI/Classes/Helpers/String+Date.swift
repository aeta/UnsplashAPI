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

import Foundation

extension String {
    /// - IMPORTANT: String format must be: ``YYYY-MM-DD'T'HH:MM:SS'Z'``
    func toDate() -> Date?  {
        // Seperate into components to remove the time zone
        let components = self.components(separatedBy: "-")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        // Unsplash API returns times in GMT-4
        let timeZoneComponents = components[3].components(separatedBy: ":")
        let tz = TimeZone(identifier: "GMT-\(timeZoneComponents.first ?? "00")\(timeZoneComponents.last ?? "00")")
        formatter.timeZone = tz
        
        let date = formatter.date(from: "\(components[0])-\(components[1])-\(components[2])")
        
        return date
    }
}
