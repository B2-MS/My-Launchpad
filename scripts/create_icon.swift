#!/usr/bin/env swift

import AppKit

// Create a rocket icon programmatically
func createRocketIcon(size: CGSize) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let rect = CGRect(origin: .zero, size: size)
    let cornerRadius = size.width * 0.2
    
    // Draw purple rounded rect background
    let purpleColor = NSColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1.0)
    purpleColor.setFill()
    let bgPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    bgPath.fill()
    
    // Draw white rocket manually (simple rocket shape)
    NSColor.white.setFill()
    
    let centerX = size.width / 2
    let centerY = size.height / 2
    let rocketHeight = size.height * 0.6
    let rocketWidth = size.width * 0.25
    
    // Rocket body path
    let rocketPath = NSBezierPath()
    
    // Nose cone (top)
    let noseTop = centerY + rocketHeight * 0.5
    let noseBottom = centerY + rocketHeight * 0.2
    rocketPath.move(to: NSPoint(x: centerX, y: noseTop))
    rocketPath.line(to: NSPoint(x: centerX - rocketWidth * 0.4, y: noseBottom))
    rocketPath.line(to: NSPoint(x: centerX + rocketWidth * 0.4, y: noseBottom))
    rocketPath.close()
    rocketPath.fill()
    
    // Body (rectangle)
    let bodyTop = noseBottom
    let bodyBottom = centerY - rocketHeight * 0.25
    let bodyRect = NSRect(
        x: centerX - rocketWidth * 0.4,
        y: bodyBottom,
        width: rocketWidth * 0.8,
        height: bodyTop - bodyBottom
    )
    NSBezierPath(roundedRect: bodyRect, xRadius: 2, yRadius: 2).fill()
    
    // Fins (left)
    let finPath1 = NSBezierPath()
    finPath1.move(to: NSPoint(x: centerX - rocketWidth * 0.4, y: bodyBottom + rocketHeight * 0.15))
    finPath1.line(to: NSPoint(x: centerX - rocketWidth * 0.8, y: bodyBottom - rocketHeight * 0.05))
    finPath1.line(to: NSPoint(x: centerX - rocketWidth * 0.4, y: bodyBottom))
    finPath1.close()
    finPath1.fill()
    
    // Fins (right)
    let finPath2 = NSBezierPath()
    finPath2.move(to: NSPoint(x: centerX + rocketWidth * 0.4, y: bodyBottom + rocketHeight * 0.15))
    finPath2.line(to: NSPoint(x: centerX + rocketWidth * 0.8, y: bodyBottom - rocketHeight * 0.05))
    finPath2.line(to: NSPoint(x: centerX + rocketWidth * 0.4, y: bodyBottom))
    finPath2.close()
    finPath2.fill()
    
    // Flame (orange/yellow)
    let flameTop = bodyBottom
    let flameBottom = centerY - rocketHeight * 0.5
    
    NSColor.orange.setFill()
    let flamePath = NSBezierPath()
    flamePath.move(to: NSPoint(x: centerX - rocketWidth * 0.25, y: flameTop))
    flamePath.line(to: NSPoint(x: centerX, y: flameBottom))
    flamePath.line(to: NSPoint(x: centerX + rocketWidth * 0.25, y: flameTop))
    flamePath.close()
    flamePath.fill()
    
    // Inner flame (yellow)
    NSColor.yellow.setFill()
    let innerFlamePath = NSBezierPath()
    innerFlamePath.move(to: NSPoint(x: centerX - rocketWidth * 0.12, y: flameTop))
    innerFlamePath.line(to: NSPoint(x: centerX, y: flameBottom + (flameTop - flameBottom) * 0.3))
    innerFlamePath.line(to: NSPoint(x: centerX + rocketWidth * 0.12, y: flameTop))
    innerFlamePath.close()
    innerFlamePath.fill()
    
    // Window on rocket (small circle)
    NSColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0).setFill()
    let windowSize = rocketWidth * 0.35
    let windowRect = NSRect(
        x: centerX - windowSize / 2,
        y: centerY + rocketHeight * 0.05,
        width: windowSize,
        height: windowSize
    )
    NSBezierPath(ovalIn: windowRect).fill()
    
    image.unlockFocus()
    return image
}

// Icon sizes needed for macOS
let sizes: [(String, Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024)
]

let iconsetPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"

for (name, size) in sizes {
    let image = createRocketIcon(size: CGSize(width: size, height: size))
    
    if let tiffData = image.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        let url = URL(fileURLWithPath: "\(iconsetPath)/\(name).png")
        try? pngData.write(to: url)
        print("Created \(name).png")
    }
}

print("Done creating icon set!")
