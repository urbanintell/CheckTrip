//
//  TSAParser.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 10/26/16.
//  Copyright © 2016 Lusenii Kromah. All rights reserved.
//

import Foundation

class TSAParser: NSObject, XMLParserDelegate{

    private var waitTimesRSS:[(checkpointIndex:String,waitTime:String )] = []
    
    private var tsaWaitTime = ""
    private var currentCheckpointIndex:String = "" {
        didSet {
            currentCheckpointIndex =
                currentCheckpointIndex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentWaitTime:String = "" {
        didSet {
            currentWaitTime =
                currentWaitTime.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
  
    private var currentDateTime:String = "" {
        didSet {
            currentDateTime =
                currentDateTime.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var parserCompletionHandler:(([(checkpointIndex: String, waitTime: String)]) -> Void)?
    
    func parseFeed(feedUrl: String, completionHandler: (([(checkpointIndex: String, waitTime: String)]) -> Void)?) -> Void {
        self.parserCompletionHandler = completionHandler
        let request = URLRequest(url: URL(string: feedUrl)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            guard let data = data else {
                if let error = error {
                    print(error)
                }
                return
            }
            // Parse XML data
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        })
        task.resume()
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        waitTimesRSS = []
    }
    
  
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        tsaWaitTime = elementName
        if tsaWaitTime == "WaitTimes" {
            currentCheckpointIndex = ""
            currentWaitTime = ""
            currentDateTime = ""
        }
    }
        
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch tsaWaitTime {
        case "CheckpointIndex": currentCheckpointIndex += string
        case "WaitTime": currentWaitTime += string
        case "Created_Datetime": currentDateTime += string
            
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "WaitTimes" {
            let rssItem = (checkpointIndex: currentCheckpointIndex, waitTime: currentWaitTime)
            waitTimesRSS += [rssItem]
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(waitTimesRSS)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
