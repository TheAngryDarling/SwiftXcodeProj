//
//  XCDebuggerBreakpoints.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-07-18.
//

import Foundation
#if swift(>=4.1)
    #if canImport(FoundationXML)
        import FoundationXML
    #endif
#endif

extension XCDebugger {
    
    /// The collection of breakpoints for the project for the given user
    public class Breakpoints {
        
        public enum Error: Swift.Error {
            case schemeDocumentMissingRootNode
            case attributeNotFound(attribute: String, path: String?)
            case elementNotFound(name: String, path: String?)
            //case valueNotFound(path: String)
            //case invalidAttributeValue(value: String, expectedType: Any.Type, attribute: String)
        }
        
        /// An action to perform on a breakpoint
        public class BreakpointAction {
            
            /// The breakpoint action type
            ///
            /// - debuggerCommand: A Debugger Command action
            /// - appleScript: An AppleScript action
            /// - graphicsTrace: A Graphics Trace action
            /// - log: A Log action
            /// - shellCommand: A Shell Script action
            /// - sound: A Sound action
            public enum ActionType: RawRepresentable {
                public enum Base: String {
                    case debuggerCommand = "Xcode.BreakpointAction.DebuggerCommand"
                    case appleScript = "Xcode.BreakpointAction.AppleScript"
                    case graphicsTrace = "Xcode.BreakpointAction.GraphicsTrace"
                    case log = "Xcode.BreakpointAction.Log"
                    case shellCommand = "Xcode.BreakpointAction.ShellCommand"
                    case sound = "Xcode.BreakpointAction.Sound"
                }
                case base(Base)
                case other(String)
                
                /// A Debugger Command action
                public static let debuggerCommand: ActionType = .base(.debuggerCommand)
                /// An AppleScript action
                public static let appleScript: ActionType = .base(.appleScript)
                /// A Graphics Trace action
                public static let graphicsTrace: ActionType = .base(.graphicsTrace)
                /// A Log action
                public static let log: ActionType = .base(.log)
                /// A Shell Script action
                public static let shellCommand: ActionType = .base(.shellCommand)
                /// A Sound action
                public static let sound: ActionType = .base(.sound)
                
                /// Load an action type
                ///
                /// - Parameter rawValue: The string value of the action type
                public init(rawValue: String) {
                    if let b = Base(rawValue: rawValue) {
                        self = .base(b)
                    } else {
                        self = .other(rawValue)
                    }
                }
                
                /// The string value of the a ctino type
                public var rawValue: String {
                    switch self {
                    case .base(let b): return b.rawValue
                    case .other(let rtn): return rtn
                    }
                }
                
                /// The class type associated with the action type
                public var breakpointActionType: BreakpointAction.Type {
                    switch self {
                    case .base(let b):
                        switch b {
                        case .debuggerCommand: return DebuggerCommand.self
                        case .appleScript: return AppleScript.self
                        case .graphicsTrace: return GraphicsTrace.self
                        case .log: return Log.self
                        case .shellCommand: return ShellScript.self
                        case .sound: return Sound.self
                        }
                    default: return Unknown.self
                    }
                }
            }
            
            /// The action type of this breakpoint action
            public let actionType: ActionType
            
            /// Create a new instance of a BreakpointAction
            ///
            /// Note: This should note be called directly, it should be caled through an inherited class
            ///
            /// - Parameter actionType: The action type of this acion
            public init(actionType: ActionType) {
                self.actionType = actionType
            }
            
            /// Decode the breakpoint action from the given xml element
            ///
            /// - Parameter element: The XMLElement that represents this action
            public required init(from element: XMLElement) throws {
                guard let atNode = element.attribute(forName: "ActionExtensionID") else {
                    throw Error.attributeNotFound(attribute: "ActionExtensionID", path: element.xPath)
                }
                self.actionType = ActionType(rawValue: atNode.stringValue!)
            }
            
            /// Encodes the given action into an XMLElement
            ///
            /// - Parameter element: The XMLElement to write to
            public func encode(to element: XMLElement) throws {
                let node: XMLNode = XMLNode.attribute(withName: "ActionExtensionID", stringValue: self.actionType)
                element.addAttribute(node)
            }
            
            /// A class that represents any unknown action
            public class Unknown: BreakpointAction {
                private let xmlString: String
                
                public required init(from element: XMLElement) throws {
                    guard let content = element.firstElement(forName: "ActionContent") else {
                        throw Error.elementNotFound(name: "ActionContent", path: element.xPath)
                    }
                    self.xmlString = content.xmlString
                    try super.init(from: element)
                }
                
                public override func encode(to element: XMLElement) throws {
                    let xml = try XMLElement(xmlString: self.xmlString)
                    element.addChild(xml)
                    try super.encode(to: element)
                }
            }
            
            /// The Debugger Command Action
            public class DebuggerCommand: BreakpointAction {
                /// The debugger command
                public var command: String
                public init(command: String) {
                    self.command = command
                    super.init(actionType: .debuggerCommand)
                }
                
                public required init(from element: XMLElement) throws {
                    guard let content = element.firstElement(forName: "ActionContent") else {
                        throw Error.elementNotFound(name: "ActionContent", path: element.xPath)
                    }
                    self.command = content.attribute(forName: "consoleCommand")?.stringValue ?? ""
                    try super.init(from: element)
                }
                
                public override func encode(to element: XMLElement) throws {
                    let e = XMLTag("ActionContent", attribute: ("consoleCommand", self.command))
                    element.addChild(e)
                    try super.encode(to: element)
                }
            }
            
            /// The AppleScript action
            public class AppleScript: BreakpointAction {
                /// The actual AppleScript script
                public var script: String
                public init(script: String) {
                    self.script = script
                    super.init(actionType: .appleScript)
                }
                
                public required init(from element: XMLElement) throws {
                    guard let content = element.firstElement(forName: "ActionContent") else {
                        throw Error.elementNotFound(name: "ActionContent", path: element.xPath)
                    }
                    self.script = content.attribute(forName: "script")?.stringValue ?? ""
                    try super.init(from: element)
                }
                
                public override func encode(to element: XMLElement) throws {
                    let e = XMLTag("ActionContent", attribute: ("script", self.script))
                    element.addChild(e)
                    try super.encode(to: element)
                }
            }
            /// The Graphics Trace action
            public class GraphicsTrace: BreakpointAction {
                public init() {
                    super.init(actionType: .graphicsTrace)
                }
                
                public required init(from element: XMLElement) throws {
                    try super.init(from: element)
                }
                
                public override func encode(to element: XMLElement) throws {
                    try super.encode(to: element)
                }
            }
            /// The Log action
            public class Log: BreakpointAction {
                /// Conveyance Type
                ///
                /// - logToFile: Log the message to the file
                /// - speak: Speak the message
                public enum ConveyanceType: Int {
                    /// Log the message to the file
                    case logToFile = 0
                    /// Speak the message
                    case speak = 1
                }
                
                /// The message to log
                public var message: String
                /// How to handle the message
                public var conveyanceType: ConveyanceType
                
                /// Create a new Log action
                ///
                /// - Parameters:
                ///   - message: The message of the log
                ///   - conveyanceType: How to handle the message
                public init(message: String, conveyanceType: ConveyanceType) {
                    self.message = message
                    self.conveyanceType = conveyanceType
                    super.init(actionType: .log)
                }
                
                public required init(from element: XMLElement) throws {
                    guard let content = element.firstElement(forName: "ActionContent") else {
                        throw Error.elementNotFound(name: "ActionContent", path: element.xPath)
                    }
                    self.message = content.attribute(forName: "message")?.stringValue ?? ""
                    if let strValue = content.attribute(forName: "conveyanceType")?.stringValue,
                        let intValue = Int(strValue) {
                        self.conveyanceType = ConveyanceType(rawValue: intValue) ?? .logToFile
                    } else {
                        self.conveyanceType = .logToFile
                    }
                    try super.init(from: element)
                }
                
                public override func encode(to element: XMLElement) throws {
                    let e = XMLTag("ActionContent",
                                   attributes: ["message": self.message,
                                                "conveyanceType": "\(self.conveyanceType)"])
                    element.addChild(e)
                    try super.encode(to: element)
                }
            }
            /// A Shell Script action
            public class ShellScript: BreakpointAction {
                /// The actual shell script
                public var script: String
                /// The arguments to pass to the script
                public var args: String
                /// Should the action wait for the script to finish
                public var waitUntilDone: Bool
                public init(script: String, args: String, waitUntilDone: Bool) {
                    self.script = script
                    self.args = args
                    self.waitUntilDone = waitUntilDone
                    super.init(actionType: .shellCommand)
                }
                
                public required init(from element: XMLElement) throws {
                    guard let content = element.firstElement(forName: "ActionContent") else {
                        throw Error.elementNotFound(name: "ActionContent", path: element.xPath)
                    }
                    self.script = content.attribute(forName: "command")?.stringValue ?? ""
                    self.args = content.attribute(forName: "arguments")?.stringValue ?? ""
                    self.waitUntilDone = (content.attribute(forName: "waitUntilDone")?.stringValue?.lowercased() == "yes")
                    try super.init(from: element)
                }
                
                public override func encode(to element: XMLElement) throws {
                    let e = XMLTag("ActionContent",
                                   attributes: ["command": self.script,
                                                "arguments": args,
                                                "waitUntilDone": (self.waitUntilDone ? "YES" : "NO")])
                    element.addChild(e)
                    try super.encode(to: element)
                }
            }
            /// A Sound action
            public class Sound: BreakpointAction {
                /// The sound names
                public enum SoundType: RawRepresentable {
                    public enum SoundBaseType: String {
                        case blow = "Blow"
                        case basso = "Basso"
                        case bottle = "Bottle"
                        case frog = "Frog"
                        case funk = "Funk"
                        case glass = "Glass"
                        case hero = "Hero"
                        case morse = "Morse"
                        case ping = "Ping"
                        case pop = "Pop"
                        case purr = "Purr"
                        case sosumi = "Sosumi"
                        case submarine = "Submarine"
                        case tink = "Tink"
                    }
                    case base(SoundBaseType)
                    case other(String)
                    
                    public init() {
                        self = .blow
                    }
                    
                    public static let blow: SoundType = .base(.blow)
                    public static let basso: SoundType = .base(.basso)
                    public static let bottle: SoundType = .base(.bottle)
                    public static let frog: SoundType = .base(.frog)
                    public static let funk: SoundType = .base(.funk)
                    public static let glass: SoundType = .base(.glass)
                    public static let hero: SoundType = .base(.hero)
                    public static let morse: SoundType = .base(.morse)
                    public static let ping: SoundType = .base(.ping)
                    public static let pop: SoundType = .base(.pop)
                    public static let purr: SoundType = .base(.purr)
                    public static let sosumi: SoundType = .base(.sosumi)
                    public static let submarine: SoundType = .base(.submarine)
                    public static let tink: SoundType = .base(.tink)
                    
                    /// Create new Sound Type
                    ///
                    /// - Parameter rawValue: The string representation of the sound
                    public init(rawValue: String) {
                        if let b = SoundBaseType(rawValue: rawValue) {
                            self = .base(b)
                        } else {
                            self = .other(rawValue)
                        }
                    }
                    
                    /// Create new Sound Type
                    ///
                    /// - Parameter rawValue: The string representation of the sound, if nil, the init reutrns nil
                    public init?(rawValue: String?) {
                        guard let rV = rawValue else { return nil }
                        self = SoundType(rawValue: rV)
                    }
                    
                    /// The string representation of the sound type
                    public var rawValue: String {
                        switch self {
                        case .base(let b): return b.rawValue
                        case .other(let rtn): return rtn
                        }
                    }
                    
                }
                
                /// The sound to make
                public var sound: SoundType
                /// Creates a new instance of a Sound action
                ///
                /// - Parameter sound: The name of the sound to make
                public init(sound: SoundType) {
                    self.sound = sound
                    super.init(actionType: .sound)
                }
                
                public required init(from element: XMLElement) throws {
                    guard let content = element.firstElement(forName: "ActionContent") else {
                        throw Error.elementNotFound(name: "ActionContent", path: element.xPath)
                    }
                    self.sound = SoundType(rawValue: content.attribute(forName: "soundName")?.stringValue) ?? SoundType()
                    try super.init(from: element)
                }
                
                public override func encode(to element: XMLElement) throws {
                    let e = XMLTag("ActionContent",
                                   attribute: ("soundName", self.sound.rawValue))
                    element.addChild(e)
                    try super.encode(to: element)
                }
            }
        }
        
        /// A project breakpoint
        public class Breakpoint {
            /// The type of breakpoint
            ///
            /// - fileBreakPoint: A file breakpoint
            public enum BreakpointType: RawRepresentable {
                public enum BreakpointTypeBase: String {
                    case fileBreakPoint = "Xcode.Breakpoint.FileBreakpoint"
                }
                
                case base(BreakpointTypeBase)
                case other(String)
                
                /// A file breakpoint
                public static let fileBreakPoint: BreakpointType = .base(.fileBreakPoint)
                
                /// Create a new breakpoing type from a string
                ///
                /// - Parameter rawValue: The string representation of the breakpoint type
                public init(rawValue: String) {
                    if let b = BreakpointTypeBase(rawValue: rawValue) {
                        self = .base(b)
                    } else {
                        self = .other(rawValue)
                    }
                }
                
                /// The string representation of the breakpoint type
                public var rawValue: String {
                    switch self {
                    case .base(let b): return b.rawValue
                    case .other(let rtn): return rtn
                    }
                }
                
                /// The class type associated with the breakpoint type
                public var breakpointType: Breakpoint.Type {
                    switch self {
                    case .base(let b):
                        switch b {
                        case .fileBreakPoint: return File.self
                        }
                    default: return Unknown.self
                    }
                }
            }
            
            /// The type of this breakpoint
            public let breakpointType: BreakpointType
            public init(breakpointType: BreakpointType) {
                self.breakpointType = breakpointType
            }
            
            /// Decode the breakpoint from the given xml element
            ///
            /// - Parameter element: The XMLElement that represents this breakpoint
            public required init(from element: XMLElement) throws {
                guard let atNode = element.attribute(forName: "BreakpointExtensionID") else {
                    throw Error.attributeNotFound(attribute: "BreakpointExtensionID", path: element.xPath)
                }
                self.breakpointType = BreakpointType(rawValue: atNode.stringValue!)
            }
            
            /// Encodes the given breakpoint into an XMLElement
            ///
            /// - Parameter element: The XMLElement to write to
            public func encode(to element: XMLElement) throws {
                let node: XMLNode = XMLNode.attribute(withName: "BreakpointExtensionID", stringValue: self.breakpointType)
                element.addAttribute(node)
            }
            
            /// A class that represents any unknown breakpoint
            public class Unknown: Breakpoint {
                private let xmlString: String
                
                public required init(from element: XMLElement) throws {
                    guard let content = element.firstElement(forName: "BreakpointContent") else {
                        throw Error.elementNotFound(name: "BreakpointContent", path: element.xPath)
                    }
                    self.xmlString = content.xmlString
                    try super.init(from: element)
                }
                
                public override func encode(to element: XMLElement) throws {
                    let xml = try XMLElement(xmlString: self.xmlString)
                    element.addChild(xml)
                    try super.encode(to: element)
                }
            }
            
            /// A File breakpoint
            public class File: Breakpoint {
                
                /// If the breakpoing should be enabled or not
                public var shouldBeEnabled: Bool
                /// How many times to igore
                public var ignoreCount: Int
                /// The breakpoing condition
                public var condition: String?
                /// Indicator if should continue execution after running actions
                public var continueAfterRunningActions: Bool
                /// The file the breakpoint is in
                public var filePath: String
                /// The timestamp
                public var timestampString: Decimal
                /// The starting column number of the breakpoint
                public var startingColumnNumber: UInt
                /// The ending column number of the breakpoint
                public var endingColumnNumber: UInt
                /// The starting line of the breakpoint
                public var startingLineNumber: UInt
                /// The ending line of the breakpoint
                public var endingLineNumber:UInt
                /// The landmark name of the breakpoint
                public var landmarkName: String
                /// The landmakr type of the breakpoint
                public var landmarkType: Int
                /// The actions to perform on this breakpoint
                public var actions: [BreakpointAction]
                
                public required init(from element: XMLElement) throws {
                    guard let content = element.firstElement(forName: "BreakpointContent") else {
                        throw Error.elementNotFound(name: "BreakpointContent", path: element.xPath)
                    }
                    
                    self.shouldBeEnabled = (content.attribute(forName: "shouldBeEnabled")?.stringValue?.lowercased() == "yes")
                    self.ignoreCount = Int(content.attribute(forName: "ignoreCount")!.stringValue!)!
                    self.condition = content.attribute(forName: "condition")?.stringValue
                    self.continueAfterRunningActions = (content.attribute(forName: "continueAfterRunningActions")?.stringValue?.lowercased() == "yes")
                    self.filePath = content.attribute(forName: "filePath")!.stringValue!
                    self.timestampString = Decimal(string: content.attribute(forName: "timestampString")!.stringValue!)!
                    self.startingColumnNumber = UInt(content.attribute(forName: "startingColumnNumber")!.stringValue!)!
                    self.endingColumnNumber = UInt(content.attribute(forName: "endingColumnNumber")!.stringValue!)!
                    self.startingLineNumber = UInt(content.attribute(forName: "startingLineNumber")!.stringValue!)!
                    self.endingLineNumber = UInt(content.attribute(forName: "endingLineNumber")!.stringValue!)!
                    self.landmarkName = content.attribute(forName: "landmarkName")!.stringValue!
                    self.landmarkType = Int(content.attribute(forName: "landmarkType")!.stringValue!)!
                    
                    self.actions = []
                    if let xmlActionsNode = content.firstElement(forName: "Actions") {
                        let xmlActions = xmlActionsNode.elements(forName: "BreakpointActionProxy")
                        for xmlAction in xmlActions {
                            if let attrib = xmlAction.attribute(forName: "ActionExtensionID"), let attribValue = attrib.stringValue {
                                let aT = BreakpointAction.ActionType(rawValue: attribValue)
                                let action = try aT.breakpointActionType.init(from: xmlAction)
                                self.actions.append(action)
                            }
                        }
                        
                    }
                    
                    try super.init(from: element)
                }
                
                public override func encode(to element: XMLElement) throws {
                    var attribs: [String: String] = [:]
                    attribs["shouldBeEnabled"] = self.shouldBeEnabled ? "Yes" : "No"
                    attribs["ignoreCount"] = "\(self.ignoreCount)"
                    if let c = self.condition { attribs["condition"] = c }
                    attribs["continueAfterRunningActions"] = self.continueAfterRunningActions ? "Yes" : "No"
                    attribs["filePath"] = self.filePath
                    attribs["timestampString"] = "\(self.timestampString)"
                    attribs["startingColumnNumber"] = "\(self.startingColumnNumber)"
                    attribs["endingColumnNumber"] = "\(self.endingColumnNumber)"
                    attribs["startingLineNumber"] = "\(self.startingLineNumber)"
                    attribs["endingLineNumber"] = "\(self.endingLineNumber)"
                    attribs["landmarkName"] = self.landmarkName
                    attribs["landmarkType"] = "\(self.landmarkType)"
                    
                    let e = XMLTag("ActionContent", attributes: attribs)
                    
                    if self.actions.count > 0 {
                        let xmlActions = XMLTag("Actions")
                        e.addChild(xmlActions)
                        for action in self.actions {
                            let xmlAction = XMLTag("BreakpointActionProxy")
                            try action.encode(to: xmlAction)
                            xmlAction.addChild(xmlAction)
                        }
                    }
                    
                    element.addChild(e)
                    try super.encode(to: element)
                }
            }
        }
        
        
        internal var hasInfoChanged: Bool = true
        /// The breakpoint file type
        public let type: Int
        /// The breakpoint file version
        public let version: Decimal
        
        /// An array of the breakpoints
        private var breakpoints: [Breakpoint]
        
        /// The current number of breakpoints
        public var count: Int { return self.breakpoints.count }
        
        
        /// Create new empty breakpoints list
        public init() {
            self.type = 1
            self.version = 2.0
            self.breakpoints = []
        }
        
        /// Create new breakpoints list from the xml data
        ///
        /// - Parameter data: the xml data
        public init(fromData data: Data) throws {
            let xmlDocument = try XMLDocument(data: data, options: [])
            guard let root = xmlDocument.rootElement() else {
                throw Error.schemeDocumentMissingRootNode
            }
            
            self.type = Int(root.attribute(forName: "type")!.stringValue!)!
            self.version = Decimal(string: root.attribute(forName: "version")!.stringValue!)!
            self.breakpoints = []
            if let xmlBreakPoints = root.firstElement(forName: "Breakpoints") {
                let xmlBreakPointElements = xmlBreakPoints.elements(forName: "BreakpointProxy")
                for xmlBreakPointElement in xmlBreakPointElements {
                    if let attrib = xmlBreakPointElement.attribute(forName: "BreakpointExtensionID"), let attribValue = attrib.stringValue {
                        let aT = Breakpoint.BreakpointType(rawValue: attribValue)
                        let breakPoint = try aT.breakpointType.init(from: xmlBreakPointElement)
                        self.breakpoints.append(breakPoint)
                    }
                }
            }
        }
        
        /// Create a new breakpoint list
        ///
        /// - Parameters:
        ///   - url: the url the the breakpoint list file
        ///   - provider: The filesystem provider to use to read the file
        public convenience init(fromURL url: XcodeFileSystemURLResource,
                                usingFSProvider provider: XcodeFileSystemProvider) throws {
            if let data = try provider.dataIfExists(from: url) {
                // Only try and load data if there was data
                try self.init(fromData: data)
            } else {
                self.init()
            }
            
        }
        
        /// Add a breakpoint to the list
        ///
        /// - Parameter newElement: The new breakpoint to add
        public func append(_ newElement: Breakpoint) {
            self.breakpoints.append(newElement)
        }
        /// Remove a breakpoint
        ///
        /// - Parameter index: The index of the breakpoint to remove
        public func remove(at index: Int) {
            self.breakpoints.remove(at: index)
            self.hasInfoChanged = true
        }
        /// Remove all breakpoints
        public func removeAll() {
            guard self.breakpoints.count > 0 else { return }
            self.breakpoints.removeAll()
            self.hasInfoChanged = true
            
            
        }
        
        /// Remove all breakpoints where conditions are met
        ///
        /// - Parameter predicate: A function to test if the breakpoint should be removed
        public func removeAll(where predicate: (Breakpoint) throws -> Bool) rethrows {
            var index: Int = 0
            while index < self.breakpoints.count {
                if try predicate(self.breakpoints[index]) {
                    self.remove(at: index)
                    self.hasInfoChanged = true
                } else {
                    index += 1
                }
            }
        }
        
        /// Get the save save action for the breakpoints file
        ///
        /// - Parameters:
        ///   - url: The url to the file to save
        ///   - overrideChangeCheck: An indicator if should ignore any has changed checks
        /// - Returns: Returns the save action if one is needed
        public func saveAction(to url: XcodeFileSystemURLResource,
                               overrideChangeCheck: Bool = false) throws -> XcodeFileSystemProviderAction? {
            guard self.hasInfoChanged || overrideChangeCheck else { return nil }
            
            let element = XMLTag("Bucket", attributes: ["type": "\(self.type)","version": "\(self.version)"])
            let xmlDocment = XMLDocument(rootElement: element)
            let xmlBreakpoints = XMLTag("Breakpoints")
            for bp in self.breakpoints {
                let xmlBreakpoint = XMLTag("BreakpointProxy")
                xmlBreakpoints.addChild(xmlBreakpoint)
                try bp.encode(to: xmlBreakpoint)
            }
            
            let dta = xmlDocment.xmlData(options: [.nodePrettyPrint, .nodePreserveEmptyElements, .nodeUseDoubleQuotes])
            
            return XcodeFileSystemProviderAction.writeData(dta, to: url, writeOptions: .atomic) {
                (_: XcodeFileSystemProvider, _: XcodeFileSystemProviderAction, _: XcodeFileSystemProviderActionResponse?, err: Swift.Error?) -> Void in
                if err == nil {
                    self.hasInfoChanged = false
                }
            }
        }
        
        /// Saves the breakpoint file
        ///
        /// - Parameters:
        ///   - url: The url to the file to save
        ///   - provider: The filesystem provider to use to write the file
        ///   - overrideChangeCheck: An indicator if should ignore any has changed checks
        public func save(to url: XcodeFileSystemURLResource,
                         usingFSProvider provider: XcodeFileSystemProvider,
                         overrideChangeCheck: Bool = false) throws {
            
            if let action = try self.saveAction(to: url, overrideChangeCheck: overrideChangeCheck) {
                try provider.action(action)
            }
        }
    }
}

extension XCDebugger.Breakpoints: Collection {
    
    public typealias Index = Int
    public typealias Element = XCDebugger.Breakpoints.Breakpoint
    // The upper and lower bounds of the collection, used in iterations
    public var startIndex: Index { return self.breakpoints.startIndex }
    public var endIndex: Index { return self.breakpoints.endIndex }
    
    /// Get or set a breakpoint
    ///
    /// - Parameter index: the index to the breakpoint
    public subscript(index: Int) -> XCDebugger.Breakpoints.Breakpoint {
        get { return self.breakpoints[index] }
        set {
            self.breakpoints[index] = newValue
            self.hasInfoChanged = true
        }
    }
    
    public func index(after i: Int) -> Int {
        return self.breakpoints.index(after: i)
    }
}
