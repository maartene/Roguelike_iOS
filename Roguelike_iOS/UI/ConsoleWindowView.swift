//
//  ConsoleWindowView.swift
//  RogueLike_Catalyst
//
//  Created by Maarten Engels on 09/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI

struct ConsoleWindowView: View {
    @State var myFrame: CGRect = CGRect.zero


    let fontSize: CGFloat = 24
    let lines: [String]
    
    var longestLineCount: Int {
        lines.reduce(0) { result, line in
            max(result, line.count)
        }
    }
    
    var topRow: String {
        var result = "\u{2554}"
        result += String(repeatElement("\u{2550}", count: longestLineCount + 2))
        result += "\u{2557}"
        return result
    }
    
    var bottomRow: String {
        var result = "\u{255A}"
        result += String(repeatElement("\u{2550}", count: longestLineCount + 2))
        result += "\u{255D}"
        return result
    }
    
    func paddedLine(_ line: String) -> String {
        let padding = longestLineCount - line.count
        return line + String(repeating: " ", count: padding)
    }
    
    var body: some View {
        VStack {
            Text(self.topRow).font(.custom("Menlo-Regular", size: fontSize))
            ForEach(self.lines, id: \.self) { line in
                Text("\u{2551} " + self.paddedLine(line) + " \u{2551}")
                    .font(.custom("Menlo-Regular", size: self.fontSize))
            }
                
            Text(self.bottomRow).font(.custom("Menlo-Regular", size: fontSize))
        }.background(Color.black.opacity(0.75))
            .foregroundColor(Color.white)
    }
}

struct ConsoleWindowView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleWindowView(lines: ["Line 1: Hello,", "Line 2: World!"])
    }
}
