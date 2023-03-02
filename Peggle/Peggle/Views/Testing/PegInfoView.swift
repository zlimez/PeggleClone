//
//  PegInfoView.swift
//  Peggle
//
//  Created by James Chiu on 3/3/23.
//

import Foundation
import SwiftUI

struct PegInfoView: View {
    let columns = [GridItem(.flexible())]
    var body: some View {
        layoutPalette(PegMapper.getPalette())
    }

    func layoutPalette(_ palette: [PegVariant]) -> some View {
        let groupCount = Int(ceil(Double(palette.count) / 2))
        return LazyVGrid(columns: columns) {
            ForEach(Array(PaletteView.adaptPalette(
                palette: palette,
                groupSize: 2).enumerated()), id: \.offset
            ) { grpOffset, variantGroup in
                HStack(spacing: 20) {
                    ForEach(Array(variantGroup.enumerated()), id: \.offset) { offset, variant in
                        PegDetailsView(
                            text: PegMapper.getPegDetails(variant),
                            pegVariant: variant
                        )
                        if offset.isMultiple(of: 2) {
                            Spacer()
                        }
                    }
                }
                .padding()
                if grpOffset < groupCount - 1 {
                    Divider()
                        .frame(height: 1)
                        .overlay(Color("grey"))
                        .opacity(0.5)
                }
            }
        }
        .fontDesign(.monospaced)
        .fontWeight(.medium)
        .font(.subheadline)
        .frame(width: 600)
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background(Color("dull green"))
        .cornerRadius(20)
        .zIndex(100)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black, lineWidth: 4)
        )
    }
}

struct PegDetailsView: View {
    var text: String
    var pegVariant: PegVariant

    var body: some View {
        VStack {
            Image(pegVariant.pegSprite)
                .resizable()
                .frame(width: 70, height: 70 * pegVariant.size.y / pegVariant.size.x)
            Spacer()
            Text(text)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

struct Info_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                PegInfoView()
                    .zIndex(10)
                Image("poster")
                    .resizable()
            }
        }
    }
}
