//
//  ArticleTableViewCell.swift
//  NewsLater
//
//  Created by Mike on 4/30/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(rowHeight: CGFloat, frameWidth: CGFloat){
        let width = frameWidth
        let height = rowHeight
        
        let views = ["thumbnail": self.thumbnail, "title": self.title, "subtitle": self.subtitle]
        
        //Visual Format Language representation of needed constraints
        let imageHStr = "H:|-\(width / 10)-[thumbnail(\(height * 8 / 10))]-(>=\(width - ((8 * height / 10) + width / 10)))-|"
        let imageVStr = "V:|-\(height / 10)-[thumbnail(\(height * 8 / 10))]-(<=\(height / 10))-|"
        let titleHStr = "H:|-\((2 * width / 10) + (height * 8 / 10))-[title]-|"
        let subtitleHStr = "H:|-\((2 * width / 10) + (height * 8 / 10))-[subtitle]-|"
        let labelVStr = "V:|-\(height / 10)-[title][subtitle]-\(height / 10)-|"
        
        self.thumbnail.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.title.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.subtitle.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        var thumbnailConstrH = NSLayoutConstraint.constraintsWithVisualFormat(imageHStr, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var thumbnailConstrV =  NSLayoutConstraint.constraintsWithVisualFormat(imageVStr, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var titleConstrH = NSLayoutConstraint.constraintsWithVisualFormat(titleHStr, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var subtitleConstrH = NSLayoutConstraint.constraintsWithVisualFormat(subtitleHStr, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var labelConstrV = NSLayoutConstraint.constraintsWithVisualFormat(labelVStr, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        self.addConstraints(thumbnailConstrH)
        self.addConstraints(thumbnailConstrV)
        self.addConstraints(titleConstrH)
        self.addConstraints(subtitleConstrH)
        self.addConstraints(labelConstrV)
    }
}
