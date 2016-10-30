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

func packageXMLData(withFileList fileList: Array<String>) -> Data {
    let package = XMLElement(name: "package")
    let root = XMLDocument(rootElement: package)
    root.version = "1.0"
    root.isStandalone = true
    let version = XMLElement(kind: .attribute)
    version.name = "version"
    version.stringValue = "1.0"
    version.kind
    package.addAttribute(version)
    
    let metadata = XMLElement(name: "metadata")
    let title = XMLElement(name: "dc:title", stringValue: "dod")
    let creator = XMLElement(name: "dc:creator", stringValue: "Richard Fabian")
    metadata.addChild(title)
    metadata.addChild(creator)
    
    package.addChild(metadata)
    
    let namespace = XMLElement(kind: .namespace)
    namespace.name = ""
    namespace.stringValue = "http://www.idpf.org/2007/opf"
    package.addNamespace(namespace)
    
    let manifest = XMLElement(name: "manifest")
    
    for i in 0..<fileList.count {
        manifest.addChild(manifestItem(withName: fileList[i], index: i))
    }
    
    package.addChild(manifest)
    
    let itemrefs = manifest.children?.filter { child in
        return child is XMLElement
        } as! Array<XMLElement>
    let ids = itemrefs.filter
        { $0.attribute(forName: "media-type")?.stringValue == "application/xhtml" }
        .flatMap { $0.attribute(forName: "id")?.stringValue }
    let spine = createSpine(withItemrefs: ids)
    package.addChild(spine)
    
    return root.xmlData(withOptions: Int(XMLNode.Options.nodePrettyPrint.rawValue))
}

func manifestItem(withName name: String, index: Int) -> XMLElement {
    let item = XMLElement(name: "item")
    if name.hasSuffix("png") {
        item.setAttributesAs(["href": "images/\(name)", "media-type": "image/png", "id": "id\(index)"])
    } else {
        item.setAttributesAs(["href": "text/\(name)", "media-type": "application/xhtml+xml", "id": "id\(index)"])
    }
    return item
}

func createSpine(withItemrefs itemrefs: Array<String>) -> XMLElement {
    let spine = XMLElement(name: "spine")
    let toc = XMLElement(kind: .attribute)
    toc.name = "toc"
    toc.stringValue = "ncx"
    spine.addChild(toc)
    itemrefs.map { (item: String) -> XMLElement in
        let element = XMLElement(name: "itemref")
        let attribute = XMLElement(kind: .attribute)
        attribute.name = "idref"
        attribute.stringValue = item
        return element
        }.forEach { spine.addChild($0) }
    
    return spine
}


let fm = FileManager.default

let sourceDir = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("source", isDirectory: true)
if fm.fileExists(atPath: sourceDir.absoluteString) == false {
    try! fm.createDirectory(at: sourceDir,
                            withIntermediateDirectories: true,
                            attributes: nil)
    dump("created directory: \(sourceDir)")
}

let contents = try! fm.contentsOfDirectory(at: sourceDir, includingPropertiesForKeys: nil, options: [])

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
    let savePath = sourceDir.appendingPathComponent("text", isDirectory: true).appendingPathComponent(currentURL.lastPathComponent)
    dump("saving to: \(savePath)")
    try! data.write(to: savePath)
}

for i in 1...43 {
    let currentImgURL = URL(string: imgAddress.replacingCharacters(in: imgAddress.range(of: "{#0}")!, with: "\(i)"))!
    dump("loading img: \(currentImgURL)")
    let data = try! Data(contentsOf: currentImgURL)
    let savePath = sourceDir.appendingPathComponent("images", isDirectory: true).appendingPathComponent(currentImgURL.lastPathComponent)
    dump("saving to: \(savePath)")
    try! data.write(to: savePath)
}

let resultDir = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("result", isDirectory: true)
if fm.fileExists(atPath: resultDir.absoluteString) == false {
    try! fm.createDirectory(at: resultDir,
                            withIntermediateDirectories: true,
                            attributes: nil)
    dump("created directory: \(resultDir)")
}

let metaInfDirPath = resultDir.appendingPathComponent("META-INF")
dump("creating directory \(metaInfDirPath)")
try! fm.createDirectory(at: metaInfDirPath, withIntermediateDirectories: false, attributes: nil)
let metaInfFilePath = resultDir.appendingPathComponent("container.xml")
dump("creating file \(metaInfFilePath)")
try! containerXMLData().write(to: resultDir)
