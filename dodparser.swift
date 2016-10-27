#!/usr/bin/swift

import Foundation

func containerXMLData() -> Data {
    let container = XMLElement(name: "container")
    let root = XMLDocument(rootElement: container)
    let version = XMLElement(kind: .attribute)
    version.name = "version"
    version.stringValue = "1.0"
    container.addAttribute(version)

    let namespace = XMLElement(kind: .attribute)
    namespace.name = "xmlns"
    namespace.stringValue = "urn:oasis:names:tc:opendocument:xmlns:container"
    container.addAttribute(namespace)

    let rootfiles = XMLElement(name: "rootfiles")
    let rootfile = XMLElement(kind: .element, options: .nodeCompactEmptyElement)
    rootfile.name = "rootfile"
    let fullPath = XMLElement(kind: .attribute)
    fullPath.name = "full-path"
    fullPath.stringValue = "content.opf"
    rootfile.addAttribute(fullPath)
    let mediaType = XMLElement(kind: .attribute)
    mediaType.name = "media-type"
    mediaType.stringValue = "application/oebps-package+xml"
    rootfile.addAttribute(mediaType)


    rootfiles.addChild(rootfile)
    container.addChild(rootfiles)

    root.version = "1.0"
    root.isStandalone = true

    return root.xmlData(withOptions: Int(XMLNode.Options.nodePrettyPrint.rawValue))
}

let fm = FileManager.default

let currentDir = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("result", isDirectory: true)
if fm.fileExists(atPath: currentDir.absoluteString) == false {
    try! fm.createDirectory(at: currentDir,
                            withIntermediateDirectories: true,
                            attributes: nil)
    dump("created directory: \(currentDir)")
}

let contents = try! fm.contentsOfDirectory(at: currentDir, includingPropertiesForKeys: nil, options: [])

if contents.isEmpty == false {
    dump("removing \(contents.count) previous items")

    for item in contents{
        try! fm.removeItem(at: item)
    }
}

let address = "http://www.dataorienteddesign.com/dodmain/node{#0}.html"
let imgAddress = "http://www.dataorienteddesign.com/dodmain/img{#0}.png"

for i in 3...19 {
    let currentURL = URL(string: address.replacingCharacters(in: address.range(of: "{#0}")!, with: "\(i)"))!
    dump("loading: \(currentURL)")
    let data = try! Data(contentsOf: currentURL)
    let savePath = currentDir.appendingPathComponent(currentURL.lastPathComponent)
    dump("saving to: \(savePath)")
    try! data.write(to: savePath)
}

for i in 1...43 {
    let currentImgURL = URL(string: imgAddress.replacingCharacters(in: imgAddress.range(of: "{#0}")!, with: "\(i)"))!
    dump("loading img: \(currentImgURL)")
    let data = try! Data(contentsOf: currentImgURL)
    let savePath = currentDir.appendingPathComponent(currentImgURL.lastPathComponent)
    dump("saving to: \(savePath)")
    try! data.write(to: savePath)
}

let metaInfDirPath = currentDir.appendingPathComponent("META-INF")
dump("creating directory \(metaInfDirPath)")
try! fm.createDirectory(at: metaInfDirPath, withIntermediateDirectories: false, attributes: nil)
let metaInfFilePath = metaInfDirPath.appendingPathComponent("container.xml")
dump("creating file \(metaInfFilePath)")
try! containerXMLData().write(to: metaInfFilePath)
