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
                VStack {
                    Spacer()
                    Text("Display Selection").font(.title2)
                }
                .frame(height: 35)
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
                VStack {
                    Divider()
                    Button("Refresh Displays", action: refreshDisplays)
                    Spacer()
                }
                .frame(height: 35)
            }
            .frame(minWidth: 200, minHeight: 400)
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
