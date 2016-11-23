//
//  SoundManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import AudioToolbox

struct SoundManager {
    func systemDing() {
        guard let url =
            URL(string: "/System/Library/Audio/UISounds/Modern/sms_alert_note.caf")
                as CFURL? else { return }
        let d = UnsafeMutablePointer<SystemSoundID>.allocate(capacity: 32)
        AudioServicesCreateSystemSoundID(url, d)
        AudioServicesPlaySystemSound(d.move())
    }
}
