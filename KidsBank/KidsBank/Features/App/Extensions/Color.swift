//
//  Color.swift
//  KidsBank
//
//  Created by Yoni Stein on 11/12/2025.
//

import SwiftUI

extension Color {
    var randomColor: Color  {
        let colors: [Color] = [
            Color(red: 0.9922, green: 0.3882, blue: 0.6235), // pink
            Color(red: 0.1647, green: 0.6431, blue: 0.9490), // blue
            Color(red: 0.9882, green: 0.7647, blue: 0.1059), // yellow
            Color(red: 0.2824, green: 0.8118, blue: 0.6784), // mint
            Color(red: 0.6157, green: 0.4588, blue: 0.9451), // soft purple
            Color(red: 1.0000, green: 0.5412, blue: 0.3961), // coral
            Color(red: 0.2784, green: 0.7490, blue: 1.0000), // aqua teal
            Color(red: 0.7843, green: 0.5608, blue: 1.0000), // lavender
            Color(red: 0.7137, green: 0.8980, blue: 0.2863), // light lime
            Color(red: 1.0000, green: 0.6902, blue: 0.4824)  // peach
        ]
        return colors.randomElement() ?? Color(red: 0.1647, green: 0.6431, blue: 0.9490)
    }

}
