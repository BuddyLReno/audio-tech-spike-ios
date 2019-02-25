//
//  Episode.model.swift
//  Audio Tech Spike
//
//  Created by Buddy Reno on 2/25/19.
//  Copyright © 2019 Buddy Reno. All rights reserved.
//

import Foundation

struct Episode {
    var id: Int32
    var hourNumber: Int32
    var title: String
    var audioUrl: String
    var duration: Int32
    var progress: Int32
}

extension Episode: SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE Episode(
        id INT PRIMARY KEY NOT NULL,
        title VARCHAR(255),
        hourNumber INT,
        audioURL VARCHAR(255),
        duration INT,
        progress INT
        );
        """
    }
    
    static var deleteStatement: String {
        return """
        DROP TABLE Episode
        """
    }
}
