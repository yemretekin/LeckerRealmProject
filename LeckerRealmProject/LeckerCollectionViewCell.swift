//
//  LeckerCollectionViewCell.swift
//  LeckerRealmProject
//
//  Created by Emre Tekin on 16.06.2023.
//

import UIKit

class LeckerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var flowerImageView: UIImageView!
    @IBOutlet weak var flowerNameLabel: UILabel!
  
    func configure(with flower: RealFlower) {
        if let filename = Optional(flower.imagePath), !filename.isEmpty {
            if let imagePath = Optional(getDocumentsDirectory().appendingPathComponent(filename).path) {
                print(imagePath)
                if let image = UIImage(contentsOfFile: imagePath) {
                    flowerImageView.image = image
                } else {
                    flowerImageView.image = nil
                }
            } else {
                flowerImageView.image = nil
            }
        } else {
            flowerImageView.image = nil
        }
        flowerNameLabel.text = flower.firstName
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }



}

extension LeckerCollectionViewCell {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 8
    }
}

