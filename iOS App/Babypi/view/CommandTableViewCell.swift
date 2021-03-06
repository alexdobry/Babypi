//
//  CommandTableViewCell.swift
//  Babypi
//
//  Created by Alex on 17.02.18.
//  Copyright © 2018 Alexander Dobrynin. All rights reserved.
//

import UIKit

final class CommandTableViewCell: UITableViewCell {
    
    static let Identifier = "CommandTableViewCell"

    @IBOutlet weak private var commandLabel: UILabel!
    
    var title: String? {
        get { return commandLabel.text }
        set { return commandLabel.text = newValue }
    }
    
    override var reuseIdentifier: String? {
        return CommandTableViewCell.Identifier
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        commandLabel.text = nil
    }
}
