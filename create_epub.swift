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
    package.addAttribute(version)
    
    let metadata = XMLElement(name: "metadata")
    let title = XMLElement(name: "dc:title", stringValue: "dod")
    let creator = XMLElement(name: "dc:creator", stringValue: "Richard Fabian")
    //metadata.addChild(title)
    //metadata.addChild(creator)
    
    //package.addChild(metadata)
    
    let namespace = XMLElement(kind: .namespace)
    namespace.name = ""
    namespace.stringValue = "http://www.idpf.org/2007/opf"
    package.addNamespace(namespace)
    
    let manifest = XMLElement(name: "manifest")
    
    for i in 0..<fileList.count {
        //manifest.addChild(manifestItem(withName: fileList[i], index: i))
    }
    
    //package.addChild(manifest)
    
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
    //spine.addChild(toc)
    itemrefs.map { (item: String) -> XMLElement in
        let element = XMLElement(name: "itemref")
        let attribute = XMLElement(kind: .attribute)
        attribute.name = "idref"
        attribute.stringValue = item
        return element
    }//.forEach { spine.addChild($0) }
    
    return spine
}

func checkDirExists(atPath path: URL) {
    if fm.fileExists(atPath: path.absoluteString) == false {
        try! fm.createDirectory(at: path,
                                withIntermediateDirectories: true,
                                attributes: nil)
        dump("created directory: \(path)")
    }
}

func clearDirectory(atPath path: URL) {
    let contents = try! fm.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
    
    if contents.isEmpty == false {
        dump("removing \(contents.count) items from \(path)")
        
        for item in contents{
            try! fm.removeItem(at: item)
        }
    }
}

let fm = FileManager.default
let sourceDir = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("source", isDirectory: true)
let resultDir = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("result", isDirectory: true)
let textDir = resultDir.appendingPathComponent("text")
let imgDir = resultDir.appendingPathComponent("images")
let metaInfDirPath = resultDir.appendingPathComponent("META-INF")
dump("creating directory \(metaInfDirPath)")
try! fm.createDirectory(at: metaInfDirPath, withIntermediateDirectories: false, attributes: nil)
let metaInfFilePath = metaInfDirPath.appendingPathComponent("container.xml")
dump("creating file \(metaInfFilePath)")
try! containerXMLData().write(to: metaInfFilePath)
let textContents = try! fm.contentsOfDirectory(at: textDir, includingPropertiesForKeys: nil, options: [])
let imgContents = try! fm.contentsOfDirectory(at: imgDir, includingPropertiesForKeys: nil, options: [])
let packageFilePath = resultDir.appendingPathComponent("content.opf")
dump("creating file \(packageFilePath)")
try! packageXMLData(withFileList: textContents.map { $0.lastPathComponent } + imgContents.map {$0.lastPathComponent}).write(to: packageFilePath)

