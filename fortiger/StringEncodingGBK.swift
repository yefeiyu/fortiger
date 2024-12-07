//
//  StringEncodingGBK.swift
//  FourFour
//
//  Created by Charles Thomas on 2024/5/18.
//

import Foundation

extension String.Encoding {
    static var gbk: String.Encoding {
        let gbkEncoding = CFStringEncodings.GB_18030_2000.rawValue
        let cfEncoding = CFStringEncoding(gbkEncoding)
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(cfEncoding))
        return encoding
    }
}
