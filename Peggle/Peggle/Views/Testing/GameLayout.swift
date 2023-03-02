//
//  GameLayout.swift
//  Peggle
//
//  Created by James Chiu on 2/3/23.
//

import Foundation
import SwiftUI

struct TopView: View {
    var body: some View {
        HStack {
            ActionView(text: "MENU")
            Spacer()
            CountDown(timeLeft: 18)
            Spacer()
            BallView(ballCount: 10)
        }
        .padding(.top, 30)
        .padding(.bottom, 15)
        .padding(.horizontal, 20)
        .background(Color("dark grey"))
    }
}

struct EndView: View {
    var score: Int?
    var endState: String

    var body: some View {
        VStack {
            Text("YOU \(endState)")
                .fontWeight(.black)
                .fontDesign(.monospaced)
                .font(.largeTitle)
                .padding(.bottom, 5)

            if let score = score {
                Text("SCORE: \(score)")
                    .fontWeight(.black)
                    .fontDesign(.monospaced)
                    .font(.largeTitle)
            }

            HStack(spacing: 50) {
                ActionView(text: "EXIT", color: Color("dark green"))
                ActionView(text: "MENU", color: Color("dark green"))
            }
        }
        .padding(40)
        .background(Color("yellow"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
        )
    }
}

struct BottomView: View {

    var body: some View {
        HStack(alignment: .center) {
            CivView(civDeath: 3, allowedDeath: 5)
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                TargetView(targetScore: 12500)
                Scorer(score: 1300)
            }
            .padding()
            .background(Color("grey"))
            .cornerRadius(10)
        }
//        .padding(.bottom, 5)
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .background(Color("dark grey"))
    }
}

struct BallView: View {
    var ballCount: Int

    var body: some View {
        HStack {
            Image("volleyball")
                .resizable()
                .frame(width: 30, height: 30)

            Text("\(ballCount)")
                .font(.title3)
                .fontDesign(.monospaced)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct Scorer: View {
    var score: Int

    var body: some View {
        Text("Score: \(score)")
            .font(.title3)
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
}

struct CivView: View {
    var civDeath: Int
    var allowedDeath: Int

    var body: some View {
        HStack {
            Image("death")
                .resizable()
                .frame(width: 60, height: 60)
            Text("\(civDeath)/\(allowedDeath)")
                .font(.title3)
                .fontDesign(.monospaced)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct CountDown: View {
    var timeLeft: Int

    var body: some View {
        HStack {
            Image(systemName: "timer")
                .resizable()
                .frame(width: 20, height: 20)

            Text("\(timeLeft)")
                .font(.title3)
                .fontDesign(.monospaced)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red, lineWidth: 3)
        )
        .foregroundColor(.white)
    }
}

struct TargetView: View {
    var targetScore: Int

    var body: some View {
        Text("Target Score: \(targetScore)")
            .font(.title3)
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
}

struct GameComponents_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                TopView()
                Spacer()
                EndView(score: 1000, endState: "LOSE")
                Spacer()
                BottomView()
            }
            .background(Color("dull green"))
//            TargetView(targetScore: 17000)
//            ScoreView(score: 3400)
//            CountDown(timeLeft: 26)
//            CivView(civDeath: 3, allowedDeath: 5)
//            BallView(ballCount: 10)
        }
    }
}
