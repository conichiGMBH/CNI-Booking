//
//  CNIPartner.swift
//  CNI-Itineraries
//
//  Created by David Henner on 03.07.19.
//  Copyright © 2019 conichi. All rights reserved.
//

import Foundation

public class CNIPartner: CNIObject, CNIModelDelegate {
    public let primaryId: String?
    public let secondaryIds: [String]?

    public init(primaryId: String?, secondaryIds: [String]?) {
        self.primaryId = primaryId
        self.secondaryIds = secondaryIds
    }

    public func deserialize() -> [String : Any] {
        var dict = [String: Any]()

        dict["primary_id"] = primaryId
        dict["secondary_ids"] = secondaryIds

        return dict
    }
}
