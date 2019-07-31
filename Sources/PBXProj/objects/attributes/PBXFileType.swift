//
//  PBXFileType.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-12-03.
//

import Foundation
import SwiftPatches

/// Protocol defining PBX File Type details
public protocol PBXFileTypeDetails {
    var identifier: String { get }
    var defaultExtension: String? { get }
    var allExtensions: [String] { get }
    var isCodeFile: Bool { get }
}

/// An indicator for the kind of file
public struct PBXFileType: Hashable {
    
    #if !swift(>=4.0.4)
    public var hashValue: Int { return self.rawValue.hashValue }
    #endif
    
    
    private let rawValue: String
    ///public init() { self.rawValue = "" }
    internal init() { self = "" }
    public init(_ rawValue: String) { self.rawValue = rawValue }
    
    /// Indicates if there is no value
    public var isEmpty: Bool { return self.rawValue.isEmpty }
    
    
    /// Structure to store locally defined file type details
    internal struct FileTypeDetails: PBXFileTypeDetails {
        let identifier: String
        let allExtensions: [String]
        let isCodeFile: Bool
        
        var defaultExtension: String? { return self.allExtensions.first }
        
    }
    
    /// Dictionary list of details for all currently known types
    internal static var fileTypeDetails: [String: FileTypeDetails] = [
        "archive": FileTypeDetails(identifier: "archive", allExtensions: [], isCodeFile: false),
        "archive.ar": FileTypeDetails(identifier: "archive.ar", allExtensions: ["a"], isCodeFile: false),
        "archive.asdictionary": FileTypeDetails(identifier: "archive.asdictionary", allExtensions: ["asdictionary"], isCodeFile: false),
        "archive.binhex": FileTypeDetails(identifier: "archive.binhex", allExtensions: ["hqx"], isCodeFile: false),
        "archive.ear": FileTypeDetails(identifier: "archive.ear", allExtensions: ["ear"], isCodeFile: false),
        "archive.gzip": FileTypeDetails(identifier: "archive.gzip", allExtensions: ["gz", "gzip"], isCodeFile: false),
        "archive.jar": FileTypeDetails(identifier: "archive.jar", allExtensions: ["jar"], isCodeFile: false),
        "archive.macbinary": FileTypeDetails(identifier: "archive.macbinary", allExtensions: ["bin"], isCodeFile: false),
        "archive.metal-library": FileTypeDetails(identifier: "archive.metal-library", allExtensions: ["metallib"], isCodeFile: false),
        "archive.ppob": FileTypeDetails(identifier: "archive.ppob", allExtensions: ["ppob"], isCodeFile: false),
        "archive.rsrc": FileTypeDetails(identifier: "archive.rsrc", allExtensions: ["rsrc", "view"], isCodeFile: false),
        "archive.stuffit": FileTypeDetails(identifier: "archive.stuffit", allExtensions: ["sit", "sitx"], isCodeFile: false),
        "archive.tar": FileTypeDetails(identifier: "archive.tar", allExtensions: ["tar"], isCodeFile: false),
        "archive.war": FileTypeDetails(identifier: "archive.war", allExtensions: ["war"], isCodeFile: false),
        "archive.zip": FileTypeDetails(identifier: "archive.zip", allExtensions: ["zip"], isCodeFile: false),
        "audio": FileTypeDetails(identifier: "audio", allExtensions: [], isCodeFile: false),
        "audio.aiff": FileTypeDetails(identifier: "audio.aiff", allExtensions: ["aiff", "aif", "cdda"], isCodeFile: false),
        "audio.au": FileTypeDetails(identifier: "audio.au", allExtensions: ["au"], isCodeFile: false),
        "audio.midi": FileTypeDetails(identifier: "audio.midi", allExtensions: ["mid", "midi"], isCodeFile: false),
        "audio.mp3": FileTypeDetails(identifier: "audio.mp3", allExtensions: ["mp3"], isCodeFile: false),
        "audio.wav": FileTypeDetails(identifier: "audio.wav", allExtensions: ["wav", "wave"], isCodeFile: false),
        "compiled": FileTypeDetails(identifier: "compiled", allExtensions: [], isCodeFile: false),
        "compiled.air": FileTypeDetails(identifier: "compiled.air", allExtensions: ["air"], isCodeFile: false),
        "compiled.cfm": FileTypeDetails(identifier: "compiled.cfm", allExtensions: [], isCodeFile: false),
        "compiled.javaclass": FileTypeDetails(identifier: "compiled.javaclass", allExtensions: ["class"], isCodeFile: false),
        "compiled.mach-o": FileTypeDetails(identifier: "compiled.mach-o", allExtensions: [], isCodeFile: false),
        "compiled.mach-o.bundle": FileTypeDetails(identifier: "compiled.mach-o.bundle", allExtensions: [], isCodeFile: false),
        "compiled.mach-o.corefile": FileTypeDetails(identifier: "compiled.mach-o.corefile", allExtensions: [], isCodeFile: false),
        "compiled.mach-o.dylib": FileTypeDetails(identifier: "compiled.mach-o.dylib", allExtensions: ["dylib"], isCodeFile: false),
        "compiled.mach-o.dylinker": FileTypeDetails(identifier: "compiled.mach-o.dylinker", allExtensions: [], isCodeFile: false),
        "compiled.mach-o.executable": FileTypeDetails(identifier: "compiled.mach-o.executable", allExtensions: [], isCodeFile: false),
        "compiled.mach-o.fvmlib": FileTypeDetails(identifier: "compiled.mach-o.fvmlib", allExtensions: [], isCodeFile: false),
        "compiled.mach-o.objfile": FileTypeDetails(identifier: "compiled.mach-o.objfile", allExtensions: ["o"], isCodeFile: false),
        "compiled.mach-o.preload": FileTypeDetails(identifier: "compiled.mach-o.preload", allExtensions: [], isCodeFile: false),
        "compiled.rcx": FileTypeDetails(identifier: "compiled.rcx", allExtensions: ["rcx"], isCodeFile: false),
        "file": FileTypeDetails(identifier: "file", allExtensions: [], isCodeFile: false),
        "file.bplist": FileTypeDetails(identifier: "file.bplist", allExtensions: [], isCodeFile: false),
        "file.playground": FileTypeDetails(identifier: "file.playground", allExtensions: ["playground"], isCodeFile: false),
        "file.scp": FileTypeDetails(identifier: "file.scp", allExtensions: ["scnp"], isCodeFile: false),
        "file.sks": FileTypeDetails(identifier: "file.sks", allExtensions: ["sks"], isCodeFile: false),
        "file.storyboard": FileTypeDetails(identifier: "file.storyboard", allExtensions: ["storyboard"], isCodeFile: false),
        "file.swiftpm-manifest": FileTypeDetails(identifier: "file.swiftpm-manifest", allExtensions: [], isCodeFile: false),
        "file.uicatalog": FileTypeDetails(identifier: "file.uicatalog", allExtensions: ["uicatalog"], isCodeFile: false),
        "file.xcplaygroundpage": FileTypeDetails(identifier: "file.xcplaygroundpage", allExtensions: ["xcplaygroundpage"], isCodeFile: false),
        "file.xib": FileTypeDetails(identifier: "file.xib", allExtensions: ["xib"], isCodeFile: false),
        "folder": FileTypeDetails(identifier: "folder", allExtensions: [], isCodeFile: false),
        "folder.abstractassetcatalog": FileTypeDetails(identifier: "folder.abstractassetcatalog", allExtensions: [], isCodeFile: false),
        "folder.assetcatalog": FileTypeDetails(identifier: "folder.assetcatalog", allExtensions: ["xcassets"], isCodeFile: false),
        "folder.iconset": FileTypeDetails(identifier: "folder.iconset", allExtensions: ["iconset"], isCodeFile: false),
        "folder.imagecatalog": FileTypeDetails(identifier: "folder.imagecatalog", allExtensions: ["imagecatalog"], isCodeFile: false),
        "folder.skatlas": FileTypeDetails(identifier: "folder.skatlas", allExtensions: ["atlas"], isCodeFile: false),
        "folder.stickers": FileTypeDetails(identifier: "folder.stickers", allExtensions: ["xcstickers"], isCodeFile: false),
        "image": FileTypeDetails(identifier: "image", allExtensions: [], isCodeFile: false),
        "image.bmp": FileTypeDetails(identifier: "image.bmp", allExtensions: ["bmp"], isCodeFile: false),
        "image.gif": FileTypeDetails(identifier: "image.gif", allExtensions: ["gif"], isCodeFile: false),
        "image.icns": FileTypeDetails(identifier: "image.icns", allExtensions: ["icns"], isCodeFile: false),
        "image.ico": FileTypeDetails(identifier: "image.ico", allExtensions: ["ico"], isCodeFile: false),
        "image.jpeg": FileTypeDetails(identifier: "image.jpeg", allExtensions: ["jpg", "jpeg"], isCodeFile: false),
        "image.pdf": FileTypeDetails(identifier: "image.pdf", allExtensions: ["pdf"], isCodeFile: false),
        "image.pict": FileTypeDetails(identifier: "image.pict", allExtensions: ["pct", "pic", "pict"], isCodeFile: false),
        "image.png": FileTypeDetails(identifier: "image.png", allExtensions: ["png"], isCodeFile: false),
        "image.tiff": FileTypeDetails(identifier: "image.tiff", allExtensions: ["tif", "tiff"], isCodeFile: false),
        "net.daringfireball.markdown": FileTypeDetails(identifier: "net.daringfireball.markdown", allExtensions: ["md", "mdown", "markdown"], isCodeFile: false),
        "sourcecode": FileTypeDetails(identifier: "sourcecode", allExtensions: [], isCodeFile: true),
        "sourcecode.ada": FileTypeDetails(identifier: "sourcecode.ada", allExtensions: ["ada", "adb", "ads"], isCodeFile: true),
        "sourcecode.applescript": FileTypeDetails(identifier: "sourcecode.applescript", allExtensions: ["applescript"], isCodeFile: true),
        "sourcecode.asm": FileTypeDetails(identifier: "sourcecode.asm", allExtensions: ["s"], isCodeFile: true),
        "sourcecode.asm.asm": FileTypeDetails(identifier: "sourcecode.asm.asm", allExtensions: ["asm"], isCodeFile: true),
        "sourcecode.asm.llvm": FileTypeDetails(identifier: "sourcecode.asm.llvm", allExtensions: ["ll", "llx"], isCodeFile: true),
        "sourcecode.c": FileTypeDetails(identifier: "sourcecode.c", allExtensions: [], isCodeFile: true),
        "sourcecode.c.c": FileTypeDetails(identifier: "sourcecode.c.c", allExtensions: ["c"], isCodeFile: true),
        "sourcecode.c.c.preprocessed": FileTypeDetails(identifier: "sourcecode.c.c.preprocessed", allExtensions: ["i"], isCodeFile: true),
        "sourcecode.c.h": FileTypeDetails(identifier: "sourcecode.c.h", allExtensions: ["h", "pch"], isCodeFile: true),
        "sourcecode.c.objc": FileTypeDetails(identifier: "sourcecode.c.objc", allExtensions: ["m"], isCodeFile: true),
        "sourcecode.c.objc.preprocessed": FileTypeDetails(identifier: "sourcecode.c.objc.preprocessed", allExtensions: ["mi"], isCodeFile: true),
        "sourcecode.cpp": FileTypeDetails(identifier: "sourcecode.cpp", allExtensions: [], isCodeFile: true),
        "sourcecode.cpp.cpp": FileTypeDetails(identifier: "sourcecode.cpp.cpp", allExtensions: ["C", "cc", "cp", "cpp", "cxx", "c++", "tcc"], isCodeFile: true),
        "sourcecode.cpp.cpp.preprocessed": FileTypeDetails(identifier: "sourcecode.cpp.cpp.preprocessed", allExtensions: ["ii"], isCodeFile: true),
        "sourcecode.cpp.h": FileTypeDetails(identifier: "sourcecode.cpp.h", allExtensions: ["H", "hh", "hp", "hpp", "hxx", "h++", "ipp", "pch++"], isCodeFile: true),
        "sourcecode.cpp.objcpp": FileTypeDetails(identifier: "sourcecode.cpp.objcpp", allExtensions: ["M", "mm"], isCodeFile: true),
        "sourcecode.cpp.objcpp.preprocessed": FileTypeDetails(identifier: "sourcecode.cpp.objcpp.preprocessed", allExtensions: ["mii"], isCodeFile: true),
        "sourcecode.dtrace": FileTypeDetails(identifier: "sourcecode.dtrace", allExtensions: ["d"], isCodeFile: true),
        "sourcecode.dylan": FileTypeDetails(identifier: "sourcecode.dylan", allExtensions: ["lid", "dylan"], isCodeFile: true),
        "sourcecode.exports": FileTypeDetails(identifier: "sourcecode.exports", allExtensions: ["exp"], isCodeFile: true),
        "sourcecode.fortran": FileTypeDetails(identifier: "sourcecode.fortran", allExtensions: ["f", "for"], isCodeFile: true),
        "sourcecode.fortran.f77": FileTypeDetails(identifier: "sourcecode.fortran.f77", allExtensions: ["f77"], isCodeFile: true),
        "sourcecode.fortran.f90": FileTypeDetails(identifier: "sourcecode.fortran.f90", allExtensions: ["f90", "f95"], isCodeFile: true),
        "sourcecode.glsl": FileTypeDetails(identifier: "sourcecode.glsl", allExtensions: ["glsl", "ctrl", "eval", "fs", "fsh", "frag", "fragment", "vs", "vsh", "vert", "vertex", "gs", "gsh", "geom", "geometry"], isCodeFile: true),
        "sourcecode.jam": FileTypeDetails(identifier: "sourcecode.jam", allExtensions: ["jam"], isCodeFile: true),
        "sourcecode.java": FileTypeDetails(identifier: "sourcecode.java", allExtensions: ["java"], isCodeFile: true),
        "sourcecode.javascript": FileTypeDetails(identifier: "sourcecode.javascript", allExtensions: ["js", "jscript", "javascript"], isCodeFile: true),
        "sourcecode.lex": FileTypeDetails(identifier: "sourcecode.lex", allExtensions: ["l", "lm", "lmm", "lp", "lpp", "lxx"], isCodeFile: true),
        "sourcecode.make": FileTypeDetails(identifier: "sourcecode.make", allExtensions: ["mk", "mak", "make", "gmk"], isCodeFile: true),
        "sourcecode.metal": FileTypeDetails(identifier: "sourcecode.metal", allExtensions: ["metal"], isCodeFile: true),
        "sourcecode.mig": FileTypeDetails(identifier: "sourcecode.mig", allExtensions: ["defs", "mig"], isCodeFile: true),
        "sourcecode.module-map": FileTypeDetails(identifier: "sourcecode.module-map", allExtensions: ["map", "modulemap"], isCodeFile: true),
        "sourcecode.nasm": FileTypeDetails(identifier: "sourcecode.nasm", allExtensions: ["nasm"], isCodeFile: true),
        "sourcecode.nqc": FileTypeDetails(identifier: "sourcecode.nqc", allExtensions: ["nqc"], isCodeFile: true),
        "sourcecode.opencl": FileTypeDetails(identifier: "sourcecode.opencl", allExtensions: ["cl"], isCodeFile: true),
        "sourcecode.pascal": FileTypeDetails(identifier: "sourcecode.pascal", allExtensions: ["p", "pp", "pas"], isCodeFile: true),
        "sourcecode.rez": FileTypeDetails(identifier: "sourcecode.rez", allExtensions: ["r", "rez"], isCodeFile: true),
        "sourcecode.swift": FileTypeDetails(identifier: "sourcecode.swift", allExtensions: ["swift"], isCodeFile: true),
        "sourcecode.text-based-dylib-definition": FileTypeDetails(identifier: "sourcecode.text-based-dylib-definition", allExtensions: ["tbd"], isCodeFile: true),
        "sourcecode.yacc": FileTypeDetails(identifier: "sourcecode.yacc", allExtensions: ["y", "ym", "ymm", "yp", "ypp", "yxx"], isCodeFile: true),
        "text": FileTypeDetails(identifier: "text", allExtensions: ["txt", ""], isCodeFile: false),
        "text.css": FileTypeDetails(identifier: "text.css", allExtensions: ["css"], isCodeFile: false),
        "text.html": FileTypeDetails(identifier: "text.html", allExtensions: ["htm", "html"], isCodeFile: false),
        "text.html.documentation": FileTypeDetails(identifier: "text.html.documentation", allExtensions: [], isCodeFile: false),
        "text.html.other": FileTypeDetails(identifier: "text.html.other", allExtensions: ["shtm", "shtml"], isCodeFile: false),
        "text.json": FileTypeDetails(identifier: "text.json", allExtensions: ["json"], isCodeFile: false),
        "text.man": FileTypeDetails(identifier: "text.man", allExtensions: ["1"], isCodeFile: false),
        "text.pbxproject": FileTypeDetails(identifier: "text.pbxproject", allExtensions: ["pbxproj"], isCodeFile: false),
        "text.plist": FileTypeDetails(identifier: "text.plist", allExtensions: ["plist", "dict"], isCodeFile: false),
        "text.plist.entitlements": FileTypeDetails(identifier: "text.plist.entitlements", allExtensions: ["entitlements"], isCodeFile: false),
        "text.plist.ibClassDescription": FileTypeDetails(identifier: "text.plist.ibClassDescription", allExtensions: ["classdescription", "classdescriptions"], isCodeFile: false),
        "text.plist.info": FileTypeDetails(identifier: "text.plist.info", allExtensions: [], isCodeFile: false),
        "text.plist.pbfilespec": FileTypeDetails(identifier: "text.plist.pbfilespec", allExtensions: ["pbfilespec"], isCodeFile: false),
        "text.plist.pblangspec": FileTypeDetails(identifier: "text.plist.pblangspec", allExtensions: ["pblangspec"], isCodeFile: false),
        "text.plist.scriptSuite": FileTypeDetails(identifier: "text.plist.scriptSuite", allExtensions: ["scriptSuite"], isCodeFile: false),
        "text.plist.scriptTerminology": FileTypeDetails(identifier: "text.plist.scriptTerminology", allExtensions: ["scriptTerminology"], isCodeFile: false),
        "text.plist.strings": FileTypeDetails(identifier: "text.plist.strings", allExtensions: ["strings"], isCodeFile: false),
        "text.plist.stringsdict": FileTypeDetails(identifier: "text.plist.stringsdict", allExtensions: ["stringsdict"], isCodeFile: false),
        "text.plist.xcbuildrules": FileTypeDetails(identifier: "text.plist.xcbuildrules", allExtensions: ["xcbuildrules"], isCodeFile: false),
        "text.plist.xclangspec": FileTypeDetails(identifier: "text.plist.xclangspec", allExtensions: ["xclangspec"], isCodeFile: false),
        "text.plist.xcspec": FileTypeDetails(identifier: "text.plist.xcspec", allExtensions: ["xcspec"], isCodeFile: false),
        "text.plist.xcsynspec": FileTypeDetails(identifier: "text.plist.xcsynspec", allExtensions: ["xcsynspec"], isCodeFile: false),
        "text.plist.xctxtmacro": FileTypeDetails(identifier: "text.plist.xctxtmacro", allExtensions: ["xctxtmacro"], isCodeFile: false),
        "text.plist.xml": FileTypeDetails(identifier: "text.plist.xml", allExtensions: [], isCodeFile: false),
        "text.rtf": FileTypeDetails(identifier: "text.rtf", allExtensions: ["rtf"], isCodeFile: false),
        "text.script": FileTypeDetails(identifier: "text.script", allExtensions: [], isCodeFile: false),
        "text.script.csh": FileTypeDetails(identifier: "text.script.csh", allExtensions: ["csh"], isCodeFile: false),
        "text.script.perl": FileTypeDetails(identifier: "text.script.perl", allExtensions: ["pl", "pm", "perl"], isCodeFile: false),
        "text.script.php": FileTypeDetails(identifier: "text.script.php", allExtensions: ["php", "php3", "php4", "php5", "phtml"], isCodeFile: false),
        "text.script.python": FileTypeDetails(identifier: "text.script.python", allExtensions: ["py"], isCodeFile: false),
        "text.script.ruby": FileTypeDetails(identifier: "text.script.ruby", allExtensions: ["rb", "rbw"], isCodeFile: false),
        "text.script.sh": FileTypeDetails(identifier: "text.script.sh", allExtensions: ["sh", "command"], isCodeFile: false),
        "text.script.worksheet": FileTypeDetails(identifier: "text.script.worksheet", allExtensions: ["worksheet"], isCodeFile: false),
        "text.xcconfig": FileTypeDetails(identifier: "text.xcconfig", allExtensions: ["xcconfig"], isCodeFile: false),
        "text.xml": FileTypeDetails(identifier: "text.xml", allExtensions: ["xml", "dtd", "xsl", "xslt", "xhtml", "xconf", "xmap", "xsp"], isCodeFile: false),
        "text.xml.dae": FileTypeDetails(identifier: "text.xml.dae", allExtensions: ["dae"], isCodeFile: false),
        "text.xml.ibArchivingDescription": FileTypeDetails(identifier: "text.xml.ibArchivingDescription", allExtensions: ["archivingdescription"], isCodeFile: false),
        "text.xml.ibCodingDescription": FileTypeDetails(identifier: "text.xml.ibCodingDescription", allExtensions: ["codingdescription"], isCodeFile: false),
        "video": FileTypeDetails(identifier: "video", allExtensions: [], isCodeFile: false),
        "video.avi": FileTypeDetails(identifier: "video.avi", allExtensions: ["avi"], isCodeFile: false),
        "video.mpeg": FileTypeDetails(identifier: "video.mpeg", allExtensions: ["mpg", "mpeg", "m75", "m15"], isCodeFile: false),
        "video.quartz-composer": FileTypeDetails(identifier: "video.quartz-composer", allExtensions: ["qtz"], isCodeFile: false),
        "video.quicktime": FileTypeDetails(identifier: "video.quicktime", allExtensions: ["mov", "moov", "qt"], isCodeFile: false),
        "wrapper": FileTypeDetails(identifier: "wrapper", allExtensions: [], isCodeFile: false),
        "wrapper.app-extension": FileTypeDetails(identifier: "wrapper.app-extension", allExtensions: ["appex", "pluginkit"], isCodeFile: false),
        "wrapper.application": FileTypeDetails(identifier: "wrapper.application", allExtensions: ["app"], isCodeFile: false),
        "wrapper.cfbundle": FileTypeDetails(identifier: "wrapper.cfbundle", allExtensions: [], isCodeFile: false),
        "wrapper.dsym": FileTypeDetails(identifier: "wrapper.dsym", allExtensions: ["dSYM", "dsym"], isCodeFile: false),
        "wrapper.framework": FileTypeDetails(identifier: "wrapper.framework", allExtensions: ["framework"], isCodeFile: false),
        "wrapper.framework.static": FileTypeDetails(identifier: "wrapper.framework.static", allExtensions: [], isCodeFile: false),
        "wrapper.htmld": FileTypeDetails(identifier: "wrapper.htmld", allExtensions: ["htmld"], isCodeFile: false),
        "wrapper.installer-mpkg": FileTypeDetails(identifier: "wrapper.installer-mpkg", allExtensions: ["mpkg"], isCodeFile: false),
        "wrapper.installer-pkg": FileTypeDetails(identifier: "wrapper.installer-pkg", allExtensions: ["pkg"], isCodeFile: false),
        "wrapper.java-classfolder": FileTypeDetails(identifier: "wrapper.java-classfolder", allExtensions: [], isCodeFile: false),
        "wrapper.kernel-extension": FileTypeDetails(identifier: "wrapper.kernel-extension", allExtensions: ["kext"], isCodeFile: false),
        "wrapper.nib": FileTypeDetails(identifier: "wrapper.nib", allExtensions: ["nib", "nib~"], isCodeFile: false),
        "wrapper.pb-project": FileTypeDetails(identifier: "wrapper.pb-project", allExtensions: ["xcodeproj", "xcode"], isCodeFile: false),
        "wrapper.pb-target": FileTypeDetails(identifier: "wrapper.pb-target", allExtensions: ["xctarget"], isCodeFile: false),
        "wrapper.plug-in": FileTypeDetails(identifier: "wrapper.plug-in", allExtensions: ["bundle"], isCodeFile: false),
        "wrapper.rtfd": FileTypeDetails(identifier: "wrapper.rtfd", allExtensions: ["rtfd"], isCodeFile: false),
        "wrapper.scnassets": FileTypeDetails(identifier: "wrapper.scnassets", allExtensions: ["scnassets"], isCodeFile: false),
        "wrapper.spotlight-importer": FileTypeDetails(identifier: "wrapper.spotlight-importer", allExtensions: ["mdimporter"], isCodeFile: false),
        "wrapper.storyboardc": FileTypeDetails(identifier: "wrapper.storyboardc", allExtensions: ["storyboardc"], isCodeFile: false),
        "wrapper.workspace": FileTypeDetails(identifier: "wrapper.workspace", allExtensions: ["xcworkspace"], isCodeFile: false),
        "wrapper.xcclassmodel": FileTypeDetails(identifier: "wrapper.xcclassmodel", allExtensions: ["xcclassmodel"], isCodeFile: false),
        "wrapper.xcdatamodel": FileTypeDetails(identifier: "wrapper.xcdatamodel", allExtensions: ["xcdatamodel"], isCodeFile: false),
        "wrapper.xcdatamodeld": FileTypeDetails(identifier: "wrapper.xcdatamodeld", allExtensions: ["xcdatamodeld"], isCodeFile: false),
        "wrapper.xcmappingmodel": FileTypeDetails(identifier: "wrapper.xcmappingmodel", allExtensions: ["xcmappingmodel"], isCodeFile: false),
        "wrapper.xpc-service": FileTypeDetails(identifier: "wrapper.xpc-service", allExtensions: ["xpc"], isCodeFile: false),
    ]
    
    /// Structure used for storing override methods on getting file type details
    private struct FileDetailsOverrideMethod {
        /// Unique id for the override method
        let id: String
        let method: (_ identifier: String?, _ ext: String?)->PBXFileTypeDetails?
        public init(_ method: @escaping (_ identifier: String?, _ ext: String?)->PBXFileTypeDetails?) {
            self.id = UUID.init().uuidString.replacingOccurrences(of: "-", with: "").uppercased()
            self.method = method
        }
    }
    
    /// List of all override methods
    private static var overrideFilelTypeDetailsFunc: [FileDetailsOverrideMethod] = []
    
    /// Method for registering an override method for getting file type details
    ///
    /// - Parameter method: The override method
    /// - Returns: Returns a unique id connected with the method for use with the unregisterOverrideFileTypeDetailsMethod
    @discardableResult public static func registerOverrideFileTypeDetalisMethod(_ method: @escaping (_ identifier: String?, _ ext: String?)->PBXFileTypeDetails?) -> String {
        let s = FileDetailsOverrideMethod(method)
        overrideFilelTypeDetailsFunc.append(s)
        return s.id
    }
    
    /// Method for unregistering an override method
    ///
    /// - Parameter id: The unique id created when registering an override method
    /// - Returns: Returns an indicator whether the method was removed or not
    @discardableResult public static func unregisterOverrideFileTypeDetailsMethod(withId id: String) -> Bool {
        if let idx = overrideFilelTypeDetailsFunc.firstIndex(where: { $0.id == id } ) {
            overrideFilelTypeDetailsFunc.remove(at: idx)
            return true
        }
        return false
    }
    
    
    /// Method for getting file type details based on file type identifier
    ///
    /// - Parameter identifier: The file type identifier to get the details for
    /// - Returns: Returns an object that implements PBXFileTypeDetails
    private static func getFileTypeDetails(for identifier: String) -> PBXFileTypeDetails? {
        for o in overrideFilelTypeDetailsFunc {
            if let r = o.method(identifier, nil) { return r }
        }
        return getLocalFileTypeDetails(for: identifier)
    }
    
    /// Method for getting the local file type details based on file type identifier
    ///
    /// - Parameter identifier: The file type identifier to get the details for
    /// - Returns: Returns an object that implements PBXFileTypeDetails
    public static func getLocalFileTypeDetails(for identifier: String) -> PBXFileTypeDetails? {
        return PBXFileType.fileTypeDetails[identifier]
    }
    
    /// Method for getting any type details based on file extenson
    ///
    /// - Parameter ext: The file extension to look for
    /// - Returns: Returns an object that implements PBXFileTypeDetails
    public static func fileType(forExt ext: String) -> PBXFileType? {
        for o in overrideFilelTypeDetailsFunc {
            if let r = o.method(nil, ext) { return PBXFileType(r.identifier) }
        }
        return localFileType(forExt: ext)
    }
    
    /// Method for getting the local file type details based on file extenson
    ///
    /// - Parameter ext: The file extension to look for
    /// - Returns: Returns an object that implements PBXFileTypeDetails
    public static func localFileType(forExt ext: String) -> PBXFileType? {
        for (k,v) in fileTypeDetails {
            if v.allExtensions.contains(ext) { return PBXFileType(k) }
        }
        return nil
    }
    
    /// Reutrns the default file extension of this file type if one exists
    public var defaultExtension: String? {
        return PBXFileType.getFileTypeDetails(for: self.rawValue)?.defaultExtension
    }
    /// Returns an array of all known extensions for this file type or and empty array if none exists
    public var allExtension: [String] {
        return PBXFileType.getFileTypeDetails(for: self.rawValue)?.allExtensions ?? []
    }
    /// Returns an indicator if this file type is a code file
    public var isCodeFile: Bool {
        return PBXFileType.getFileTypeDetails(for: self.rawValue)?.isCodeFile ?? false
    }
    
    /// Base file type for any file
    public static let file: PBXFileType = "file" // parent:
    /// Base file type for any folder
    public static let folder: PBXFileType = "folder" // parent:
    
    public struct Pattern {
        private init() {}
        
        public static let proxy: PBXFileType = "pattern.proxy" // parent: Pattern
    }
    
    
    /// **************** Script Build from here on **************** \\\
    
    public struct Archive {
        private init() {}
        
        public static let ar: PBXFileType = "archive.ar" // parent: archive
        public static let asdictionary: PBXFileType = "archive.asdictionary" // parent: archive
        public static let binhex: PBXFileType = "archive.binhex" // parent: archive
        public static let ear: PBXFileType = "archive.ear" // parent: archive.jar
        public static let gzip: PBXFileType = "archive.gzip" // parent: archive
        public static let jar: PBXFileType = "archive.jar" // parent: archive.zip
        public static let macbinary: PBXFileType = "archive.macbinary" // parent: archive
        public static let metalLibrary: PBXFileType = "archive.metal-library" // parent: archive
        public static let ppob: PBXFileType = "archive.ppob" // parent: archive.rsrc
        public static let rsrc: PBXFileType = "archive.rsrc" // parent: archive
        public static let stuffit: PBXFileType = "archive.stuffit" // parent: archive
        public static let tar: PBXFileType = "archive.tar" // parent: archive
        public static let war: PBXFileType = "archive.war" // parent: archive.jar
        public static let zip: PBXFileType = "archive.zip" // parent: archive
    }
    public struct Audio {
        private init() {}
        
        public static let aiff: PBXFileType = "audio.aiff" // parent: audio
        public static let au: PBXFileType = "audio.au" // parent: audio
        public static let midi: PBXFileType = "audio.midi" // parent: audio
        public static let mp3: PBXFileType = "audio.mp3" // parent: audio
        public static let wav: PBXFileType = "audio.wav" // parent: audio
    }
    public struct Compiled {
        private init() {}
        
        public static let air: PBXFileType = "compiled.air" // parent: compiled
        public static let cfm: PBXFileType = "compiled.cfm" // parent: compiled
        public static let javaclass: PBXFileType = "compiled.javaclass" // parent: compiled
        public static let machO: PBXFileType = "compiled.mach-o" // parent: compiled
        public static let rcx: PBXFileType = "compiled.rcx" // parent: compiled
        
        public struct MachO {
            private init() {}
            
            public static let bundle: PBXFileType = "compiled.mach-o.bundle" // parent: compiled.mach-o
            public static let corefile: PBXFileType = "compiled.mach-o.corefile" // parent: compiled.mach-o
            public static let dylib: PBXFileType = "compiled.mach-o.dylib" // parent: compiled.mach-o
            public static let dylinker: PBXFileType = "compiled.mach-o.dylinker" // parent: compiled.mach-o
            public static let executable: PBXFileType = "compiled.mach-o.executable" // parent: compiled.mach-o
            public static let fvmlib: PBXFileType = "compiled.mach-o.fvmlib" // parent: compiled.mach-o
            public static let objfile: PBXFileType = "compiled.mach-o.objfile" // parent: compiled.mach-o
            public static let preload: PBXFileType = "compiled.mach-o.preload" // parent: compiled.mach-o
        }
    }
    public struct File {
        private init() {}
        
        public static let archive: PBXFileType = "archive" // parent: file
        public static let audio: PBXFileType = "audio" // parent: file
        public static let bplist: PBXFileType = "file.bplist" // parent: file
        public static let compiled: PBXFileType = "compiled" // parent: file
        public static let image: PBXFileType = "image" // parent: file
        public static let scp: PBXFileType = "file.scp" // parent: file
        public static let sks: PBXFileType = "file.sks" // parent: file
        public static let storyboard: PBXFileType = "file.storyboard" // parent: file
        public static let uicatalog: PBXFileType = "file.uicatalog" // parent: file
        public static let video: PBXFileType = "video" // parent: file
        public static let xib: PBXFileType = "file.xib" // parent: file
    }
    public struct Folder {
        private init() {}
        
        public static let assetcatalog: PBXFileType = "folder.assetcatalog" // parent: folder.abstractassetcatalog
        public static let imagecatalog: PBXFileType = "folder.imagecatalog" // parent: folder.assetcatalog
        public static let stickers: PBXFileType = "folder.stickers" // parent: folder.abstractassetcatalog
        public static let wrapper: PBXFileType = "wrapper" // parent: folder
    }
    public struct Image {
        private init() {}
        
        public static let bmp: PBXFileType = "image.bmp" // parent: image
        public static let gif: PBXFileType = "image.gif" // parent: image
        public static let icns: PBXFileType = "image.icns" // parent: image
        public static let ico: PBXFileType = "image.ico" // parent: image
        public static let jpeg: PBXFileType = "image.jpeg" // parent: image
        public static let pdf: PBXFileType = "image.pdf" // parent: image
        public static let pict: PBXFileType = "image.pict" // parent: image
        public static let png: PBXFileType = "image.png" // parent: image
        public static let tiff: PBXFileType = "image.tiff" // parent: image
    }
    public struct SourceCode {
        private init() {}
        
        public struct Assembly {
            private init() {}
            
            public static let asm: PBXFileType = "sourcecode.asm.asm" // parent: sourcecode.asm
            public static let asmLlvm: PBXFileType = "sourcecode.asm.llvm" // parent: sourcecode
            public static let nasm: PBXFileType = "sourcecode.nasm" // parent: sourcecode
            public static let source: PBXFileType = "sourcecode.asm" // parent: sourcecode
        }
        public struct C {
            private init() {}
            
            public static let c: PBXFileType = "sourcecode.c.c" // parent: sourcecode.c
            public static let header: PBXFileType = "sourcecode.c.h" // parent: sourcecode.c
            public static let preprocessedSource: PBXFileType = "sourcecode.c.c.preprocessed" // parent: sourcecode.c.c
            public static let source: PBXFileType = "sourcecode.c" // parent: sourcecode
        }
        public struct CPP {
            private init() {}
            
            public static let cpp: PBXFileType = "sourcecode.cpp.cpp" // parent: sourcecode.cpp
            public static let cppPreprocessedSource: PBXFileType = "sourcecode.cpp.objcpp.preprocessed" // parent: sourcecode.cpp.objcpp
            public static let cppSource: PBXFileType = "sourcecode.cpp.objcpp" // parent: sourcecode.cpp
            public static let header: PBXFileType = "sourcecode.cpp.h" // parent: sourcecode.cpp
            public static let preprocessedSource: PBXFileType = "sourcecode.cpp.cpp.preprocessed" // parent: sourcecode.cpp.cpp
            public static let source: PBXFileType = "sourcecode.cpp" // parent: sourcecode.c
        }
        public struct Fortran {
            private init() {}
            
            public static let f77: PBXFileType = "sourcecode.fortran.f77" // parent: sourcecode.fortran
            public static let f90: PBXFileType = "sourcecode.fortran.f90" // parent: sourcecode.fortran
        }
        public struct ObjectiveC {
            private init() {}
            
            public static let preprocessedSource: PBXFileType = "sourcecode.c.objc.preprocessed" // parent: sourcecode.c.objc
            public static let source: PBXFileType = "sourcecode.c.objc" // parent: sourcecode.c
        }
        public struct Swift {
            private init() {}
            
            public static let fileSwiftpmManifest: PBXFileType = "file.swiftpm-manifest" // parent: sourcecode.swift
            public static let source: PBXFileType = "sourcecode.swift" // parent: sourcecode
        }
        public struct Various {
            private init() {}
            
            public static let ada: PBXFileType = "sourcecode.ada" // parent: sourcecode
            public static let dtrace: PBXFileType = "sourcecode.dtrace" // parent: sourcecode
            public static let dylan: PBXFileType = "sourcecode.dylan" // parent: sourcecode
            public static let exports: PBXFileType = "sourcecode.exports" // parent: sourcecode
            public static let fortran: PBXFileType = "sourcecode.fortran" // parent: sourcecode
            public static let glsl: PBXFileType = "sourcecode.glsl" // parent: sourcecode
            public static let jam: PBXFileType = "sourcecode.jam" // parent: sourcecode
            public static let java: PBXFileType = "sourcecode.java" // parent: sourcecode
            public static let lex: PBXFileType = "sourcecode.lex" // parent: sourcecode
            public static let make: PBXFileType = "sourcecode.make" // parent: sourcecode
            public static let metal: PBXFileType = "sourcecode.metal" // parent: sourcecode
            public static let mig: PBXFileType = "sourcecode.mig" // parent: sourcecode
            public static let moduleMap: PBXFileType = "sourcecode.module-map" // parent: sourcecode
            public static let nqc: PBXFileType = "sourcecode.nqc" // parent: sourcecode
            public static let opencl: PBXFileType = "sourcecode.opencl" // parent: sourcecode
            public static let pascal: PBXFileType = "sourcecode.pascal" // parent: sourcecode
            public static let rez: PBXFileType = "sourcecode.rez" // parent: sourcecode
            public static let textBasedDylibDefinition: PBXFileType = "sourcecode.text-based-dylib-definition" // parent: sourcecode
            public static let wrapperXcdatamodel: PBXFileType = "wrapper.xcdatamodel" // parent: sourcecode
            public static let wrapperXcdatamodeld: PBXFileType = "wrapper.xcdatamodeld" // parent: sourcecode
            public static let wrapperXcmappingmodel: PBXFileType = "wrapper.xcmappingmodel" // parent: sourcecode
            public static let yacc: PBXFileType = "sourcecode.yacc" // parent: sourcecode
        }
    }
    public struct Text {
        private init() {}
        
        public static let css: PBXFileType = "text.css" // parent: text
        public static let html: PBXFileType = "text.html" // parent: text
        public static let json: PBXFileType = "text.json" // parent: text
        public static let man: PBXFileType = "text.man" // parent: text
        public static let netDaringfireballMarkdown: PBXFileType = "net.daringfireball.markdown" // parent: sourcecode
        public static let pbxproject: PBXFileType = "text.pbxproject" // parent: text
        public static let plainText: PBXFileType = "text" // parent: file
        public static let plist: PBXFileType = "text.plist" // parent: text
        public static let plistStrings: PBXFileType = "text.plist.strings" // parent: text
        public static let plistStringsdict: PBXFileType = "text.plist.stringsdict" // parent: text
        public static let rtf: PBXFileType = "text.rtf" // parent: text
        public static let script: PBXFileType = "text.script" // parent: text
        public static let sourcecode: PBXFileType = "sourcecode" // parent: text
        public static let xcconfig: PBXFileType = "text.xcconfig" // parent: text
        public static let xml: PBXFileType = "text.xml" // parent: text
        
        public struct Html {
            private init() {}
            
            public static let documentation: PBXFileType = "text.html.documentation" // parent: text.html
            public static let other: PBXFileType = "text.html.other" // parent: text.html
        }
        public struct PropertyList {
            private init() {}
            
            public static let entitlements: PBXFileType = "text.plist.entitlements" // parent: text.plist
            public static let ibClassDescription: PBXFileType = "text.plist.ibClassDescription" // parent: text.plist
            public static let info: PBXFileType = "text.plist.info" // parent: text.plist.xml
            public static let pbfilespec: PBXFileType = "text.plist.pbfilespec" // parent: text.plist
            public static let pblangspec: PBXFileType = "text.plist.pblangspec" // parent: text.plist
            public static let scriptSuite: PBXFileType = "text.plist.scriptSuite" // parent: text.plist
            public static let scriptTerminology: PBXFileType = "text.plist.scriptTerminology" // parent: text.plist
            public static let xcbuildrules: PBXFileType = "text.plist.xcbuildrules" // parent: text.plist
            public static let xclangspec: PBXFileType = "text.plist.xclangspec" // parent: text.plist
            public static let xcspec: PBXFileType = "text.plist.xcspec" // parent: text.plist
            public static let xcsynspec: PBXFileType = "text.plist.xcsynspec" // parent: text.plist
            public static let xctxtmacro: PBXFileType = "text.plist.xctxtmacro" // parent: text.plist
            public static let xml: PBXFileType = "text.plist.xml" // parent: text.plist
        }
        public struct Scripts {
            private init() {}
            
            public static let applescript: PBXFileType = "sourcecode.applescript" // parent: sourcecode
            public static let csh: PBXFileType = "text.script.csh" // parent: text.script
            public static let javascript: PBXFileType = "sourcecode.javascript" // parent: sourcecode
            public static let perl: PBXFileType = "text.script.perl" // parent: text.script
            public static let php: PBXFileType = "text.script.php" // parent: text.script
            public static let python: PBXFileType = "text.script.python" // parent: text.script
            public static let ruby: PBXFileType = "text.script.ruby" // parent: text.script
            public static let sh: PBXFileType = "text.script.sh" // parent: text.script
            public static let worksheet: PBXFileType = "text.script.worksheet" // parent: text.script
        }
        public struct Xml {
            private init() {}
            
            public static let dae: PBXFileType = "text.xml.dae" // parent: text.xml
            public static let ibArchivingDescription: PBXFileType = "text.xml.ibArchivingDescription" // parent: text.xml
            public static let ibCodingDescription: PBXFileType = "text.xml.ibCodingDescription" // parent: text.xml
        }
    }
    public struct Video {
        private init() {}
        
        public static let avi: PBXFileType = "video.avi" // parent: video
        public static let mpeg: PBXFileType = "video.mpeg" // parent: video
        public static let quartzComposer: PBXFileType = "video.quartz-composer" // parent: video
        public static let quicktime: PBXFileType = "video.quicktime" // parent: video
    }
    public struct Wrapper {
        private init() {}
        
        public static let `static`: PBXFileType = "wrapper.framework.static" // parent: wrapper.framework
        public static let appExtension: PBXFileType = "wrapper.app-extension" // parent: wrapper.xpc-service
        public static let application: PBXFileType = "wrapper.application" // parent: wrapper.cfbundle
        public static let cfbundle: PBXFileType = "wrapper.cfbundle" // parent: wrapper
        public static let dsym: PBXFileType = "wrapper.dsym" // parent: wrapper
        public static let filePlayground: PBXFileType = "file.playground" // parent: wrapper
        public static let fileXcplaygroundpage: PBXFileType = "file.xcplaygroundpage" // parent: wrapper
        public static let folderAbstractassetcatalog: PBXFileType = "folder.abstractassetcatalog" // parent: wrapper
        public static let folderIconset: PBXFileType = "folder.iconset" // parent: wrapper
        public static let folderSkatlas: PBXFileType = "folder.skatlas" // parent: wrapper
        public static let framework: PBXFileType = "wrapper.framework" // parent: wrapper.cfbundle
        public static let htmld: PBXFileType = "wrapper.htmld" // parent: wrapper
        public static let installerMpkg: PBXFileType = "wrapper.installer-mpkg" // parent: wrapper
        public static let installerPkg: PBXFileType = "wrapper.installer-pkg" // parent: wrapper
        public static let javaClassfolder: PBXFileType = "wrapper.java-classfolder" // parent: wrapper
        public static let kernelExtension: PBXFileType = "wrapper.kernel-extension" // parent: wrapper.plug-in
        public static let nib: PBXFileType = "wrapper.nib" // parent: wrapper
        public static let pbProject: PBXFileType = "wrapper.pb-project" // parent: wrapper
        public static let pbTarget: PBXFileType = "wrapper.pb-target" // parent: wrapper.pb-project
        public static let plugIn: PBXFileType = "wrapper.plug-in" // parent: wrapper.cfbundle
        public static let rtfd: PBXFileType = "wrapper.rtfd" // parent: wrapper
        public static let scnassets: PBXFileType = "wrapper.scnassets" // parent: wrapper
        public static let spotlightImporter: PBXFileType = "wrapper.spotlight-importer" // parent: wrapper.cfbundle
        public static let storyboardc: PBXFileType = "wrapper.storyboardc" // parent: wrapper
        public static let workspace: PBXFileType = "wrapper.workspace" // parent: wrapper
        public static let xcclassmodel: PBXFileType = "wrapper.xcclassmodel" // parent: wrapper
        public static let xpcService: PBXFileType = "wrapper.xpc-service" // parent: wrapper.cfbundle
    }
}
extension PBXFileType: CustomStringConvertible {
    public var description: String { return self.rawValue }
}

extension PBXFileType: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(rawValue)
    }
}

extension PBXFileType: Equatable {
    public static func ==(lhs: PBXFileType, rhs: PBXFileType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: PBXFileType, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
    public static func ==(lhs: String, rhs: PBXFileType) -> Bool {
        return lhs == rhs.rawValue
    }
}
extension PBXFileType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
