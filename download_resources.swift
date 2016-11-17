#!/usr/bin/swift

import Foundation

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

checkDirExists(atPath: sourceDir)
clearDirectory(atPath: sourceDir)

let resultDir = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("result", isDirectory: true)

checkDirExists(atPath: resultDir)
clearDirectory(atPath: resultDir)

let textDir = resultDir.appendingPathComponent("text")
let imgDir = resultDir.appendingPathComponent("images")

checkDirExists(atPath: textDir)
checkDirExists(atPath: imgDir)

let address = "http://www.dataorienteddesign.com/dodmain/node{#0}.html"
let imgAddress = "http://www.dataorienteddesign.com/dodmain/img{#0}.png"

for i in 3...19 {
    let currentURL = URL(string: address.replacingCharacters(in: address.range(of: "{#0}")!, with: "\(i)"))!
    dump("loading: \(currentURL)")
    let data = try! Data(contentsOf: currentURL)
    let savePath = textDir.appendingPathComponent(currentURL.lastPathComponent)
    dump("saving to: \(savePath)")
    try! data.write(to: savePath)
}

for i in 1...43 {
    let currentImgURL = URL(string: imgAddress.replacingCharacters(in: imgAddress.range(of: "{#0}")!, with: "\(i)"))!
    dump("loading img: \(currentImgURL)")
    let data = try! Data(contentsOf: currentImgURL)
    let savePath = imgDir.appendingPathComponent(currentImgURL.lastPathComponent)
    dump("saving to: \(savePath)")
    try! data.write(to: savePath)
}

