//
//  ResponseViewModel.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/20/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit
import Foundation

protocol ResponseViewStructure {
    var text: String { get }
    var detailsText: String { get }
    var image: UIImage { get }
}

enum ResponseViewState: ResponseViewStructure {
    case Success
    case Failed
    case FailedConnection
    case Waiting
    var text: String {
        switch self {
        case .Success: return StateText.Success
        case .Failed : return StateText.Failed
        case .FailedConnection: return StateText.FailedConnection
        case .Waiting: return StateText.Waiting
        }
    }
    var detailsText: String {
        switch self {
        case .Success: return StateDetailsText.Success
        case .Failed : return StateDetailsText.Failed
        case .FailedConnection: return StateDetailsText.FailedConnection
        case .Waiting: return StateDetailsText.Waiting
        }
    }
    var image: UIImage {
        switch self {
        case .Success: return StateImage.Success
        case .Failed : return StateImage.Failed
        case .FailedConnection: return StateImage.Failed
        case .Waiting: return StateImage.Waiting
        }
    }
}

private struct StateText {
    static let Success = "成功！"
    static let Failed = "失敗！"
    static let FailedConnection = "糟糕！"
    static let Waiting = "請稍候..."
}

private struct StateDetailsText {
    static let Success = "回覆已加入您的「歷史紀錄」中。"
    static let Failed = "此車牌稍早已經被檢舉了喔！"
    static let FailedConnection = "對方網路連線異常，請稍候再試！"
    static let Waiting = ""
}


private struct StateImage {
    static let Success = #imageLiteral(resourceName: "success")
    static let Failed = #imageLiteral(resourceName: "error")
    static let Waiting = UIImage()
}
