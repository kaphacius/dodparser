#!/usr/bin/swift
import Foundation

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
