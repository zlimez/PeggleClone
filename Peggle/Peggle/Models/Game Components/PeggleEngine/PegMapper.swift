//
//  PegMapper.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

final class PegMapper {
    static var pegVariantToPegTable: [PegVariant: (Peg) -> DesignPeg] = [:]
    static var pegVariantToPegRbTable: [PegVariant: (Peg) -> PegRB] = [:]
}
