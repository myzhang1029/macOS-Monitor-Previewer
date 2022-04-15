//
//  ContentView.swift
//  Monitor Preview
//
//  Created by 张迈允 on 2022-04-15.
//

import SwiftUI


struct ContentView: View {
    @State private var displayList: [CGDirectDisplayID] = []
    @State private var error: Optional<String> = .none
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Display Selection").font(.title2)
                Spacer()
                List {
                    /* the display id is unique */
                    ForEach($displayList, id: \.self) {
                        let dId = $0.wrappedValue;
                        NavigationLink(
                            destination: DisplayPreviewView(displayId: dId),
                            label: {
                                VStack {
                                    HStack {
                                        Text(displayName(displayId: dId))
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(displayProp(displayId: dId)) @ \(dId)")
                                        Spacer()
                                    }
                                }
                            })
                    }
                }
                Spacer()
                Button("Refresh Displays", action: refreshDisplays)
                Spacer()
            }
        }
        .onAppear(perform: refreshDisplays)
    }
    
    /** Refresh list of displays */
    func refreshDisplays() {
        switch getDisplays() {
        case .success(let displays):
            displayList = displays
        case .failure(let cgerror):
            error = .some("CoreGraphics error \(cgerror)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
