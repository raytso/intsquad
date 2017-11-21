//
//  UserInfoInputTableViewCell.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/9/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

class UserInfoInputTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var userInfo: UserInformation?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var title: UILabel!
    
    // Mark: - Application Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
