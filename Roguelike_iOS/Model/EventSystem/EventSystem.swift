//
//  EventSystem.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 26/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import Combine

enum RLEvent {
    case idle
    case entityDied(RLEntity)
    case levelup(RLEntity)
}

class EventSystem: ObservableObject {
    static var main: EventSystem = EventSystem()
    
    @Published var eventQueue = [RLEvent]()
    @Published var lastEvent = RLEvent.idle
    
    func fireEvent(_ event: RLEvent) {
        // print("Queueing event: \(event)")
        lastEvent = event
        eventQueue.append(event)
    }
}
