//
//  File.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 04.11.23.
//

import Foundation

class Publisher {

    private var handlers = [any EventHandler]()
    
    public func register(handler: any EventHandler) {
        handlers.append(handler)
    }
    
    public func register(handler: @escaping (any Event) -> ()) {
        handlers.append(BaseEventHandler(handler: handler))
    }
    
    public func publish(_ event: any Event) {
        for handler in handlers {
            handler.handle(event)
        }
    }
}

protocol Event {
}

protocol EventHandler {
    func handle(_ event: any Event)
}

class BaseEventHandler: EventHandler {
    let handler: (any Event) -> ()
    
    init(handler: @escaping (any Event) -> ()) {
        self.handler = handler
    }
    
    func handle(_ event: any Event) {
        handler(event)
    }
}

