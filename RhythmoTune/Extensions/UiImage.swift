//
//  UiImage.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 13/03/25.
//

import UIKit

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
